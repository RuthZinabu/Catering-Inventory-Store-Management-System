<?php

namespace App\Http\Controllers;

use App\Enums\MovementType;
use App\Enums\StockStatus;
use App\Models\InventoryBatch;
use App\Models\Item;
use App\Models\PurchaseOrder;
use App\Models\PurchaseOrderItem;
use App\Models\PurchaseReceipt;
use App\Models\PurchaseReceiptItem;
use App\Models\PurchaseReturn;
use App\Models\PurchaseReturnItem;
use App\Models\StockMovement;
use App\Models\StoreStock;
use App\Services\OperationalNotificationService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class PurchaseOrderController extends Controller
{
    private const ORDER_STATUSES = ['Draft', 'Pending', 'Approved', 'Partially Received', 'Received', 'Cancelled'];

    public function index(Request $request)
    {
        $validated = $request->validate([
            'store_id' => 'required|uuid|exists:stores,id',
            'search' => 'nullable|string|max:100',
            'status' => ['nullable', Rule::in(self::ORDER_STATUSES)],
            'per_page' => 'nullable|integer|min:1|max:100',
        ]);
        abort_unless($request->user()->canAccessStore($validated['store_id']), 403);

        $query = PurchaseOrder::with(['supplier:id,name,company,contact_person,phone,email', 'items.item:id,name,code,unit'])
            ->where('destination_store_id', $validated['store_id']);
        if (!empty($validated['search'])) {
            $search = '%' . $validated['search'] . '%';
            $query->where(function ($builder) use ($search) {
                $builder->where('number', 'like', $search)
                    ->orWhereHas('supplier', fn ($supplier) => $supplier->where('company', 'like', $search));
            });
        }
        if (!empty($validated['status'])) {
            $query->where('status', $validated['status']);
        }

        $orders = $query->latest('order_date')->paginate($validated['per_page'] ?? 50);
        return $this->success([
            'purchase_orders' => $orders->items(),
            'pagination' => [
                'current_page' => $orders->currentPage(),
                'last_page' => $orders->lastPage(),
                'per_page' => $orders->perPage(),
                'total' => $orders->total(),
            ],
        ]);
    }

    public function store(Request $request)
    {
        $validated = $this->validateOrder($request, true);
        abort_unless($request->user()->canAccessStore($validated['destination_store_id']), 403);

        $order = DB::transaction(function () use ($request, $validated) {
            $order = PurchaseOrder::create([
                'number' => $validated['number'] ?? $this->nextNumber(),
                'supplier_id' => $validated['supplier_id'],
                'destination_store_id' => $validated['destination_store_id'],
                'created_by' => $request->user()->id,
                'order_date' => $validated['order_date'],
                'expected_delivery_date' => $validated['expected_delivery_date'] ?? null,
                'status' => $validated['status'] ?? 'Pending',
                'payment_status' => 'Pending',
                'notes' => $validated['notes'] ?? null,
            ]);
            $this->replaceItems($order, $validated['items']);
            return $order;
        });

        if ($order->status === 'Pending') {
            app(OperationalNotificationService::class)->notifyStores(
                [$order->destination_store_id],
                $request->user(),
                'Purchase order needs review',
                "Purchase order {$order->number} was submitted for approval.",
                'purchases',
                'purchase_order',
                $order->id
            );
        }

        return $this->success($this->loadOrder($order), 'Purchase order created successfully', 201);
    }

    public function show(Request $request, PurchaseOrder $purchaseOrder)
    {
        abort_unless($request->user()->canAccessStore($purchaseOrder->destination_store_id), 403);
        return $this->success($this->loadOrder($purchaseOrder));
    }

    public function update(Request $request, PurchaseOrder $purchaseOrder)
    {
        abort_unless($request->user()->canAccessStore($purchaseOrder->destination_store_id), 403);
        if (!in_array($purchaseOrder->status, ['Draft', 'Pending'], true)) {
            return $this->error('Only draft or pending purchase orders can be updated.', 409);
        }
        $validated = $this->validateOrder($request, false);
        if (isset($validated['destination_store_id'])) {
            abort_unless($request->user()->canAccessStore($validated['destination_store_id']), 403);
        }

        DB::transaction(function () use ($purchaseOrder, $validated) {
            $purchaseOrder->update(collect($validated)->except('items')->all());
            if (array_key_exists('items', $validated)) {
                $this->replaceItems($purchaseOrder, $validated['items']);
            }
        });

        return $this->success($this->loadOrder($purchaseOrder->fresh()), 'Purchase order updated successfully');
    }

    public function destroy(Request $request, PurchaseOrder $purchaseOrder)
    {
        abort_unless($request->user()->canAccessStore($purchaseOrder->destination_store_id), 403);
        if (!in_array($purchaseOrder->status, ['Draft', 'Pending'], true)) {
            return $this->error('Only draft or pending purchase orders can be deleted.', 409);
        }
        $purchaseOrder->delete();
        return $this->success(null, 'Purchase order deleted successfully');
    }

    public function approve(Request $request, PurchaseOrder $purchaseOrder)
    {
        abort_unless($request->user()->canAccessStore($purchaseOrder->destination_store_id), 403);
        if (!in_array($purchaseOrder->status, ['Draft', 'Pending'], true)) {
            return $this->error('This purchase order cannot be approved in its current status.', 409);
        }
        $purchaseOrder->update([
            'status' => 'Approved',
            'approved_by' => $request->user()->id,
            'approved_at' => now(),
        ]);
        app(OperationalNotificationService::class)->notifyUser(
            $purchaseOrder->created_by,
            $request->user(),
            'Purchase order approved',
            "Purchase order {$purchaseOrder->number} was approved.",
            'purchases',
            $purchaseOrder->destination_store_id,
            'purchase_order',
            $purchaseOrder->id
        );
        return $this->success($this->loadOrder($purchaseOrder->fresh()), 'Purchase order approved successfully');
    }

    public function receive(Request $request, PurchaseOrder $purchaseOrder)
    {
        abort_unless($request->user()->canAccessStore($purchaseOrder->destination_store_id), 403);
        if (!in_array($purchaseOrder->status, ['Approved', 'Partially Received'], true)) {
            return $this->error('Approve the purchase order before receiving goods.', 409);
        }
        $validated = $request->validate([
            'delivery_date' => 'required|date',
            'driver_name' => 'nullable|string|max:255',
            'vehicle_number' => 'nullable|string|max:50',
            'notes' => 'nullable|string',
            'items' => 'required|array|min:1',
            'items.*.purchase_order_item_id' => ['required', 'uuid', 'distinct', Rule::exists('purchase_order_items', 'id')->where('purchase_order_id', $purchaseOrder->id)],
            'items.*.received_quantity' => 'required|numeric|min:0.001',
            'items.*.accepted_quantity' => 'required|numeric|min:0',
            'items.*.rejected_quantity' => 'required|numeric|min:0',
            'items.*.quality_status' => ['required', Rule::in(['Accepted', 'Partially Accepted', 'Rejected'])],
            'items.*.rejection_reason' => 'nullable|string',
            'items.*.expires_on' => 'nullable|date_format:Y-m-d',
            'items.*.lot_number' => 'nullable|string|max:100',
        ]);

        $totalRejectedQuantity = 0.0;
        $receipt = DB::transaction(function () use ($request, $purchaseOrder, $validated, &$totalRejectedQuantity) {
            $receipt = PurchaseReceipt::create([
                'purchase_order_id' => $purchaseOrder->id,
                'received_by' => $request->user()->id,
                'grn_number' => $this->nextNumber('GRN'),
                'delivery_date' => $validated['delivery_date'],
                'driver_name' => $validated['driver_name'] ?? null,
                'vehicle_number' => $validated['vehicle_number'] ?? null,
                'notes' => $validated['notes'] ?? null,
            ]);

            foreach ($validated['items'] as $received) {
                $line = PurchaseOrderItem::whereKey($received['purchase_order_item_id'])
                    ->where('purchase_order_id', $purchaseOrder->id)->lockForUpdate()->firstOrFail();
                $receivedQuantity = (float) $received['received_quantity'];
                $acceptedQuantity = (float) $received['accepted_quantity'];
                $rejectedQuantity = (float) $received['rejected_quantity'];
                $totalRejectedQuantity += $rejectedQuantity;
                if (abs($receivedQuantity - $acceptedQuantity - $rejectedQuantity) > 0.001) {
                    abort(422, 'Received quantity must equal accepted quantity plus rejected quantity.');
                }
                if ($receivedQuantity > (float) $line->quantity - (float) $line->received_quantity) {
                    abort(422, 'Received quantity cannot exceed the quantity still outstanding.');
                }

                $receiptItem = PurchaseReceiptItem::create([
                    'purchase_receipt_id' => $receipt->id,
                    'purchase_order_item_id' => $line->id,
                    'received_quantity' => $receivedQuantity,
                    'accepted_quantity' => $acceptedQuantity,
                    'rejected_quantity' => $rejectedQuantity,
                    'quality_status' => $received['quality_status'],
                    'rejection_reason' => $received['rejection_reason'] ?? null,
                ]);
                if ($acceptedQuantity > 0 && !empty($received['expires_on'])) {
                    InventoryBatch::create([
                        'store_id' => $purchaseOrder->destination_store_id,
                        'item_id' => $line->item_id,
                        'purchase_receipt_item_id' => $receiptItem->id,
                        'lot_number' => $received['lot_number'] ?? null,
                        'expires_on' => $received['expires_on'],
                        'received_quantity' => $acceptedQuantity,
                        'quantity_remaining' => $acceptedQuantity,
                        'unit_cost' => $line->unit_price,
                        'created_by' => $request->user()->id,
                    ]);
                }
                $line->increment('received_quantity', $receivedQuantity);

                if ($acceptedQuantity > 0) {
                    $stock = StoreStock::where('item_id', $line->item_id)
                        ->where('store_id', $purchaseOrder->destination_store_id)->lockForUpdate()->first();
                    if (!$stock) {
                        $stock = StoreStock::create([
                            'item_id' => $line->item_id,
                            'store_id' => $purchaseOrder->destination_store_id,
                            'quantity' => 0,
                            'reserved_quantity' => 0,
                            'current_cost' => $line->unit_price,
                            'last_cost' => $line->unit_price,
                            'status' => StockStatus::HEALTHY,
                        ]);
                    }
                    $before = (float) $stock->quantity;
                    $after = $before + $acceptedQuantity;
                    $stock->update([
                        'quantity' => $after,
                        'last_cost' => $line->unit_price,
                        'current_cost' => $line->unit_price,
                        'status' => $after <= (float) $stock->min_quantity ? StockStatus::LOW_STOCK : StockStatus::HEALTHY,
                    ]);
                    StockMovement::create([
                        'item_id' => $line->item_id,
                        'store_id' => $purchaseOrder->destination_store_id,
                        'type' => MovementType::STOCK_IN,
                        'quantity' => $acceptedQuantity,
                        'unit' => $line->unit,
                        'quantity_before' => $before,
                        'quantity_after' => $after,
                        'reference_type' => StockMovement::REFERENCE_PURCHASE_ORDER,
                        'reference_id' => $purchaseOrder->id,
                        'note' => 'Goods received on ' . $receipt->grn_number,
                        'performed_by' => $request->user()->id,
                    ]);
                }
            }

            $purchaseOrder->load('items');
            $fullyReceived = $purchaseOrder->items->every(
                fn ($line) => (float) $line->received_quantity >= (float) $line->quantity
            );
            $purchaseOrder->update([
                'status' => $fullyReceived ? 'Received' : 'Partially Received',
                'received_at' => $fullyReceived ? now() : null,
            ]);
            return $receipt;
        });

        if ($totalRejectedQuantity > 0) {
            app(OperationalNotificationService::class)->notifyStores(
                [$purchaseOrder->destination_store_id],
                $request->user(),
                'Goods rejected during receiving',
                "Some goods for purchase order {$purchaseOrder->number} were rejected during receiving.",
                'purchases',
                'purchase_order',
                $purchaseOrder->id
            );
        }

        return $this->success($receipt->load('items'), 'Goods received successfully', 201);
    }

    public function storeReturn(Request $request, PurchaseOrder $purchaseOrder)
    {
        abort_unless($request->user()->canAccessStore($purchaseOrder->destination_store_id), 403);
        $validated = $request->validate([
            'return_date' => 'required|date',
            'reason' => 'required|string|max:2000',
            'items' => 'required|array|min:1',
            'items.*.purchase_order_item_id' => ['required', 'uuid', 'distinct', Rule::exists('purchase_order_items', 'id')->where('purchase_order_id', $purchaseOrder->id)],
            'items.*.quantity' => 'required|numeric|min:0.001',
        ]);

        $purchaseReturn = DB::transaction(function () use ($request, $purchaseOrder, $validated) {
            $purchaseReturn = PurchaseReturn::create([
                'number' => $this->nextNumber('RET'),
                'purchase_order_id' => $purchaseOrder->id,
                'created_by' => $request->user()->id,
                'return_date' => $validated['return_date'],
                'status' => 'Pending Review',
                'reason' => $validated['reason'],
            ]);
            foreach ($validated['items'] as $returned) {
                $line = PurchaseOrderItem::with('item')->whereKey($returned['purchase_order_item_id'])
                    ->where('purchase_order_id', $purchaseOrder->id)->lockForUpdate()->firstOrFail();
                $alreadyReturned = PurchaseReturnItem::where('purchase_order_item_id', $line->id)
                    ->whereHas('purchaseReturn', fn ($query) => $query->where('status', 'Approved'))->sum('quantity');
                if ((float) $returned['quantity'] > (float) $line->received_quantity - (float) $alreadyReturned) {
                    abort(422, 'Return quantity cannot exceed the received quantity not already returned.');
                }
                PurchaseReturnItem::create([
                    'purchase_return_id' => $purchaseReturn->id,
                    'purchase_order_item_id' => $line->id,
                    'quantity' => $returned['quantity'],
                    'unit_price' => $line->unit_price,
                ]);
            }
            return $purchaseReturn;
        });

        return $this->success($purchaseReturn->load('items'), 'Purchase return submitted for review', 201);
    }

    public function approveReturn(Request $request, PurchaseOrder $purchaseOrder, PurchaseReturn $purchaseReturn)
    {
        abort_unless($request->user()->canAccessStore($purchaseOrder->destination_store_id), 403);
        abort_unless($purchaseReturn->purchase_order_id === $purchaseOrder->id, 404);
        if ($purchaseReturn->status !== 'Pending Review') {
            return $this->error('This return has already been reviewed.', 409);
        }

        DB::transaction(function () use ($request, $purchaseOrder, $purchaseReturn) {
            foreach ($purchaseReturn->items as $returned) {
                $line = PurchaseOrderItem::with('item')->findOrFail($returned->purchase_order_item_id);
                $stock = StoreStock::where('item_id', $line->item_id)
                    ->where('store_id', $purchaseOrder->destination_store_id)->lockForUpdate()->firstOrFail();
                $quantity = (float) $returned->quantity;
                if ((float) $stock->available_quantity < $quantity) {
                    abort(422, 'Returned quantity exceeds available stock.');
                }
                $before = (float) $stock->quantity;
                $after = $before - $quantity;
                $stock->update([
                    'quantity' => $after,
                    'status' => $after <= 0 ? StockStatus::OUT_OF_STOCK : ($after <= (float) $stock->min_quantity ? StockStatus::LOW_STOCK : StockStatus::HEALTHY),
                ]);
                StockMovement::create([
                    'item_id' => $line->item_id,
                    'store_id' => $purchaseOrder->destination_store_id,
                    'type' => MovementType::STOCK_OUT,
                    'quantity' => $quantity,
                    'unit' => $line->unit,
                    'quantity_before' => $before,
                    'quantity_after' => $after,
                    'reference_type' => StockMovement::REFERENCE_PURCHASE_ORDER,
                    'reference_id' => $purchaseOrder->id,
                    'note' => 'Supplier return ' . $purchaseReturn->number,
                    'performed_by' => $request->user()->id,
                ]);
            }
            $purchaseReturn->update([
                'status' => 'Approved',
                'reviewed_by' => $request->user()->id,
                'reviewed_at' => now(),
            ]);
        });
        return $this->success($purchaseReturn->fresh()->load('items'), 'Purchase return approved');
    }

    private function validateOrder(Request $request, bool $creating): array
    {
        return $request->validate([
            'number' => [$creating ? 'nullable' : 'sometimes', 'string', 'max:50', Rule::unique('purchase_orders', 'number')->ignore($request->route('purchaseOrder')?->id)],
            'supplier_id' => [$creating ? 'required' : 'sometimes', 'uuid', Rule::exists('suppliers', 'id')->where('status', 'Active')],
            'destination_store_id' => [$creating ? 'required' : 'sometimes', 'uuid', 'exists:stores,id'],
            'order_date' => [$creating ? 'required' : 'sometimes', 'date'],
            'expected_delivery_date' => 'nullable|date|after_or_equal:order_date',
            'status' => [$creating ? 'sometimes' : 'sometimes', Rule::in(['Draft', 'Pending'])],
            'notes' => 'nullable|string|max:5000',
            'items' => [$creating ? 'required' : 'sometimes', 'array', 'min:1'],
            'items.*.item_id' => 'required|uuid|distinct|exists:items,id',
            'items.*.quantity' => 'required|numeric|gt:0',
            'items.*.unit_price' => 'required|numeric|min:0',
            'items.*.vat_amount' => 'nullable|numeric|min:0',
            'items.*.discount_amount' => 'nullable|numeric|min:0',
        ]);
    }

    private function replaceItems(PurchaseOrder $order, array $items): void
    {
        $subtotal = 0;
        $vat = 0;
        $discount = 0;
        foreach ($items as $input) {
            $item = Item::active()->findOrFail($input['item_id']);
            $quantity = (float) $input['quantity'];
            $unitPrice = (float) $input['unit_price'];
            $itemSubtotal = $quantity * $unitPrice;
            $itemVat = (float) ($input['vat_amount'] ?? 0);
            $itemDiscount = (float) ($input['discount_amount'] ?? 0);
            if ($itemDiscount > $itemSubtotal + $itemVat) {
                abort(422, 'Line discount cannot exceed its subtotal and VAT.');
            }
            $subtotal += $itemSubtotal;
            $vat += $itemVat;
            $discount += $itemDiscount;
            PurchaseOrderItem::updateOrCreate(
                ['purchase_order_id' => $order->id, 'item_id' => $item->id],
                [
                    'quantity' => $quantity,
                    'received_quantity' => 0,
                    'unit' => $item->unit,
                    'unit_price' => $unitPrice,
                    'vat_amount' => $itemVat,
                    'discount_amount' => $itemDiscount,
                    'line_total' => $itemSubtotal + $itemVat - $itemDiscount,
                ]
            );
        }
        $itemIds = collect($items)->pluck('item_id');
        $order->items()->whereNotIn('item_id', $itemIds)->delete();
        $order->update([
            'subtotal' => $subtotal,
            'vat_amount' => $vat,
            'discount_amount' => $discount,
            'total_amount' => $subtotal + $vat - $discount,
        ]);
    }

    private function loadOrder(PurchaseOrder $order): PurchaseOrder
    {
        return $order->load([
            'supplier',
            'destinationStore:id,name,code',
            'creator:id,name',
            'items.item:id,code,name,unit,item_type',
            'receipts.items',
            'returns.items',
        ]);
    }

    private function nextNumber(string $prefix = 'PO'): string
    {
        return $prefix . '-' . now()->format('ymd') . '-' . Str::upper(Str::random(5));
    }
}
