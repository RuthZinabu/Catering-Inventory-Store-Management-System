<?php

namespace App\Http\Controllers;

use App\Models\Item;
use App\Models\User;
use App\Models\WasteRecord;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class WasteRecordController extends Controller
{
    /**
     * Display a listing of waste records visible to the authenticated user.
     */
    public function index(Request $request)
    {
        $validated = $request->validate([
            'store_id' => 'sometimes|uuid|exists:stores,id',
            'search' => 'sometimes|nullable|string|max:255',
            'from_date' => 'sometimes|nullable|date',
            'to_date' => 'sometimes|nullable|date|after_or_equal:from_date',
            'per_page' => 'sometimes|integer|min:1|max:100',
        ]);

        $user = $request->user();
        if (
            isset($validated['store_id']) &&
            $user->role !== User::ROLE_ADMIN &&
            !$user->canAccessStore($validated['store_id'])
        ) {
            return $this->forbidden('Access denied to this store');
        }

        $query = $this->recordsVisibleTo($request);

        if (isset($validated['store_id'])) {
            $query->where('store_id', $validated['store_id']);
        }

        if (!empty($validated['search'])) {
            $search = '%' . strtolower($validated['search']) . '%';
            $query->where(function ($searchQuery) use ($search) {
                $searchQuery
                    ->whereRaw('LOWER(number) LIKE ?', [$search])
                    ->orWhereRaw('LOWER(item) LIKE ?', [$search])
                    ->orWhereRaw('LOWER(category) LIKE ?', [$search])
                    ->orWhereRaw('LOWER(reason) LIKE ?', [$search]);
            });
        }

        if (!empty($validated['from_date'])) {
            $query->whereDate('date', '>=', $validated['from_date']);
        }

        if (!empty($validated['to_date'])) {
            $query->whereDate('date', '<=', $validated['to_date']);
        }

        $records = $query
            ->orderByDesc('date')
            ->orderByDesc('created_at')
            ->paginate($validated['per_page'] ?? 50);

        return $this->success([
            'items' => $records->getCollection()
                ->map(fn (WasteRecord $record) => $this->toApiArray($record))
                ->values()
                ->all(),
            'pagination' => [
                'current_page' => $records->currentPage(),
                'last_page' => $records->lastPage(),
                'per_page' => $records->perPage(),
                'total' => $records->total(),
            ],
        ]);
    }

    /**
     * Store a newly created waste record.
     */
    public function store(Request $request)
    {
        $validated = $request->validate($this->recordRules());
        $user = $request->user();

        $storeId = $validated['store_id'] ?? $user->stores()->value('stores.id');
        if (
            $storeId !== null &&
            $user->role !== User::ROLE_ADMIN &&
            !$user->canAccessStore($storeId)
        ) {
            return $this->forbidden('Access denied to this store');
        }

        $id = (string) Str::uuid();
        $record = WasteRecord::create([
            'id' => $id,
            'number' => 'WS-' . strtoupper($id),
            'item_id' => $validated['item_id']
                ?? Item::where('name', $validated['item'])->value('id'),
            'store_id' => $storeId,
            'item' => $validated['item'],
            'category' => $validated['category'],
            'unit' => $validated['unit'],
            'quantity' => $validated['quantity'],
            'estimated_cost' => $validated['estimated_cost'],
            'reason' => $validated['reason'],
            'recorded_by' => $validated['recorded_by'],
            'date' => $validated['date'],
            'status' => $validated['status'] ?? WasteRecord::STATUS_CONFIRMED,
            'notes' => $validated['notes'] ?? null,
            'created_by' => $user->id,
        ]);

        return $this->success(
            $this->toApiArray($record),
            'Waste record created successfully',
            201
        );
    }

    /**
     * Display a waste record.
     */
    public function show(Request $request, WasteRecord $wasteRecord)
    {
        if (!$this->userCanAccessRecord($request, $wasteRecord)) {
            return $this->notFound('Waste record not found');
        }

        return $this->success($this->toApiArray($wasteRecord));
    }

    /**
     * Update the specified waste record.
     */
    public function update(Request $request, WasteRecord $wasteRecord)
    {
        if (!$this->userCanAccessRecord($request, $wasteRecord)) {
            return $this->notFound('Waste record not found');
        }

        $validated = $request->validate($this->recordRules(true));

        if (
            array_key_exists('item', $validated) &&
            !array_key_exists('item_id', $validated)
        ) {
            $validated['item_id'] = Item::where('name', $validated['item'])->value('id');
        }

        $wasteRecord->update($validated);

        return $this->success(
            $this->toApiArray($wasteRecord->refresh()),
            'Waste record updated successfully'
        );
    }

    /**
     * Remove the specified waste record.
     */
    public function destroy($wasteRecord)
    {
        return $this->error('Waste record deletion is not implemented', 501);
    }

    /**
     * Approve a waste record.
     */
    public function approve(Request $request, $wasteRecord)
    {
        return $this->error('Waste record approval is not implemented', 501);
    }

    private function recordRules(bool $partial = false): array
    {
        $required = $partial ? 'sometimes|required' : 'required';

        $rules = [
            'item' => "$required|string|max:255",
            'item_id' => 'sometimes|nullable|uuid|exists:items,id',
            'category' => "$required|string|max:100",
            'unit' => "$required|string|max:20",
            'quantity' => "$required|numeric|gt:0",
            'estimated_cost' => "$required|numeric|gte:0",
            'reason' => "$required|string|max:255",
            'recorded_by' => "$required|string|max:255",
            'date' => "$required|date",
            'status' => 'sometimes|required|string|in:Confirmed,Pending Review',
            'notes' => 'sometimes|nullable|string|max:5000',
            'store_id' => 'sometimes|nullable|uuid|exists:stores,id',
        ];

        if ($partial) {
            // A record's store is chosen on creation and cannot be reassigned
            // through the update endpoint.
            unset($rules['item_id'], $rules['store_id']);
        }

        return $rules;
    }

    /**
     * Apply store visibility rules used by the other store-scoped endpoints.
     */
    private function recordsVisibleTo(Request $request): Builder
    {
        $user = $request->user();
        $query = WasteRecord::query();

        if ($user->role !== User::ROLE_ADMIN) {
            $storeIds = $user->stores()->pluck('stores.id');
            $query->where(function ($scope) use ($storeIds, $user) {
                if ($storeIds->isNotEmpty()) {
                    $scope->whereIn('store_id', $storeIds->all());
                }

                $scope->orWhere(function ($ownRecords) use ($user) {
                    $ownRecords
                        ->whereNull('store_id')
                        ->where('created_by', $user->id);
                });
            });
        }

        return $query;
    }

    private function userCanAccessRecord(Request $request, WasteRecord $record): bool
    {
        $user = $request->user();

        if ($user->role === User::ROLE_ADMIN) {
            return true;
        }

        if ($record->store_id !== null) {
            return $user->canAccessStore($record->store_id);
        }

        return $record->created_by === $user->id;
    }

    /**
     * Return only fields consumed by the Flutter WasteRecord model.
     */
    private function toApiArray(WasteRecord $record): array
    {
        return [
            'id' => (string) $record->id,
            'number' => $record->number,
            'item' => $record->item,
            'category' => $record->category,
            'unit' => $record->unit,
            'quantity' => $record->quantity,
            'estimated_cost' => $record->estimated_cost,
            'reason' => $record->reason,
            'recorded_by' => $record->recorded_by,
            'date' => $record->date->toIso8601String(),
            'status' => $record->status,
            'notes' => $record->notes ?? '',
        ];
    }
}