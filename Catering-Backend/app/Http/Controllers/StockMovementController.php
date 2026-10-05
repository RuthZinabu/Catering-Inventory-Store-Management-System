<?php

namespace App\Http\Controllers;

use App\Models\StockMovement;
use App\Services\OperationalNotificationService;
use App\Enums\MovementType;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class StockMovementController extends Controller
{
    /**
     * Display a listing of stock movements
     */
    public function index(Request $request)
    {
        $user = $request->user();
        $query = StockMovement::with([
            'item:id,code,name,unit,item_type',
            'store:id,name,code',
            'performedBy:id,name',
            'approvedBy:id,name'
        ]);

        // If not admin, filter to user's accessible stores
        if ($user->role !== 'admin') {
            $userStoreIds = $user->stores->pluck('id')->toArray();
            $query->whereIn('store_id', $userStoreIds);
        }

        // Filter by store
        if ($request->has('store_id')) {
            $query->where('store_id', $request->store_id);
        }

        // Filter by item
        if ($request->has('item_id')) {
            $query->where('item_id', $request->item_id);
        }

        // Filter by movement type
        if ($request->has('type')) {
            $query->where('type', $request->type);
        }

        // Filter by date range
        if ($request->has('from_date')) {
            $query->whereDate('created_at', '>=', $request->from_date);
        }

        if ($request->has('to_date')) {
            $query->whereDate('created_at', '<=', $request->to_date);
        }

        // Filter by pending approval
        if ($request->boolean('pending_approval')) {
            $query->pendingApproval();
        }

        // Filter by corrections
        if ($request->boolean('corrections_only')) {
            $query->corrections();
        }

        // Search by reference or note
        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('note', 'ILIKE', "%{$search}%")
                  ->orWhere('reference_id', 'ILIKE', "%{$search}%");
            });
        }

        $movements = $query->orderBy('created_at', 'desc')
            ->paginate($request->get('per_page', 15));

        return $this->success([
            'items' => $movements->items(),
            'pagination' => [
                'current_page' => $movements->currentPage(),
                'last_page' => $movements->lastPage(),
                'per_page' => $movements->perPage(),
                'total' => $movements->total(),
            ],
        ]);
    }

    /**
     * Store a new stock movement (manual adjustment)
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'item_id' => 'required|uuid|exists:items,id',
            'store_id' => 'required|uuid|exists:stores,id',
            'type' => 'required|string|in:Stock In,Stock Out,Adjustment',
            'quantity' => 'required|numeric',
            'note' => 'nullable|string|max:500',
            'reference_type' => 'nullable|string|in:manual,purchase_order,transfer,waste_record,kitchen_issue',
            'reference_id' => 'nullable|uuid',
        ]);

        $quantity = (float) $validated['quantity'];
        if (abs($quantity) < 0.001 || ($validated['type'] !== 'Adjustment' && $quantity < 0)) {
            return $this->validationError([
                'quantity' => 'Quantity must be non-zero, and can be negative only for an adjustment.',
            ]);
        }

        $user = $request->user();

        // Check store access
        if ($user->role !== 'admin' && !$user->canAccessStore($validated['store_id'])) {
            return $this->forbidden('Access denied to this store');
        }

        $movementType = MovementType::from($validated['type']);
        $movement = DB::transaction(function () use ($validated, $movementType, $quantity, $user) {
            $storeStock = \App\Models\StoreStock::where('item_id', $validated['item_id'])
                ->where('store_id', $validated['store_id'])
                ->lockForUpdate()
                ->first();

            if (!$storeStock) {
                return null;
            }

            $oldQuantity = (float) $storeStock->quantity;
            $quantityChange = match ($movementType) {
                MovementType::STOCK_IN, MovementType::RETURN => $quantity,
                MovementType::STOCK_OUT => -$quantity,
                MovementType::ADJUSTMENT => $quantity,
                default => 0,
            };
            $newQuantity = $oldQuantity + $quantityChange;

            if ($newQuantity < (float) $storeStock->reserved_quantity) {
                return false;
            }

            $storeStock->update(['quantity' => $newQuantity]);
            $storeStock->updateStatus();

            return StockMovement::create([
                'item_id' => $validated['item_id'],
                'store_id' => $validated['store_id'],
                'type' => $movementType,
                'quantity' => abs($quantityChange),
                'unit' => $storeStock->item->unit,
                'quantity_before' => $oldQuantity,
                'quantity_after' => $newQuantity,
                'note' => $validated['note'] ?? null,
                'reference_type' => $validated['reference_type'] ?? StockMovement::REFERENCE_MANUAL,
                'reference_id' => $validated['reference_id'] ?? null,
                'performed_by' => $user->id,
            ]);
        });

        if ($movement === null) {
            return $this->error('Stock item not found in this store', 404);
        }
        if ($movement === false) {
            return $this->error('Insufficient unreserved stock for this operation', 422);
        }

        $movement->load([
            'item:id,code,name,unit',
            'store:id,name,code',
            'performedBy:id,name'
        ]);

        return $this->success($movement, 'Stock movement recorded successfully', 201);
    }

    /**
     * Display the specified stock movement
     */
    public function show(Request $request, StockMovement $movement)
    {
        $user = $request->user();

        // Check store access
        if ($user->role !== 'admin' && !$user->canAccessStore($movement->store_id)) {
            return $this->forbidden('Access denied to this store');
        }

        $movement->load([
            'item:id,code,name,unit,item_type',
            'store:id,name,code',
            'fromStore:id,name,code',
            'toStore:id,name,code',
            'performedBy:id,name',
            'approvedBy:id,name',
            'deletedBy:id,name',
            'correctsMovement:id,type,quantity,created_at',
            'corrections:id,type,quantity,correction_reason,created_at'
        ]);

        return $this->success($movement);
    }

    /**
     * Create a correction for a stock movement
     */
    public function correct(Request $request, StockMovement $movement)
    {
        $validated = $request->validate([
            'correction_quantity' => 'required|numeric',
            'reason' => 'required|string|max:500',
        ]);

        if (abs((float) $validated['correction_quantity']) < 0.001) {
            return $this->validationError([
                'correction_quantity' => 'Correction quantity must be at least 0.001 in magnitude.',
            ]);
        }

        $user = $request->user();

        // Check store access
        if ($user->role !== 'admin' && !$user->canAccessStore($movement->store_id)) {
            return $this->forbidden('Access denied to this store');
        }

        // Check if movement can be corrected
        if ($movement->is_correction) {
            return $this->error('Cannot correct a correction movement', 422);
        }

        // Create the correction
        $correction = $movement->createCorrection(
            $user,
            $validated['correction_quantity'],
            $validated['reason']
        );

        $correction->load([
            'item:id,code,name,unit',
            'store:id,name,code',
            'performedBy:id,name',
            'correctsMovement:id,type,quantity'
        ]);

        app(OperationalNotificationService::class)->notifyStores(
            [$movement->store_id],
            $user,
            'Stock movement corrected',
            "A stock movement for {$correction->item->name} was corrected: {$validated['reason']}",
            'inventory',
            'stock_movement',
            $correction->id
        );

        return $this->success($correction, 'Stock movement corrected successfully', 201);
    }
}