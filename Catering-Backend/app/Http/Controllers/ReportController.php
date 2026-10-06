<?php

namespace App\Http\Controllers;

use App\Models\StockMovement;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Database\Query\Builder;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;

class ReportController extends Controller
{
    public function overview(Request $request)
    {
        [$from, $to, $period] = $this->dateRange($request);
        $storeIds = $this->storeIds($request);

        $stock = $this->stockSummary($storeIds);
        $valuation = $this->valuationReport($storeIds);
        $movements = $this->movementReport($storeIds, $from, $to);
        $purchases = $this->purchaseReport($storeIds, $from, $to);
        $suppliers = $this->supplierReport($storeIds, $from, $to);
        $expiry = $this->expiryReport($storeIds);
        $waste = $this->wasteReport($storeIds, $from, $to);
        $consumption = $this->consumptionReport($storeIds, $from, $to);

        return $this->success([
            'period' => [
                'type' => $period,
                'from' => $from->toDateString(),
                'to' => $to->toDateString(),
            ],
            'kpis' => [
                'total_items' => $stock['total_skus'],
                'inventory_value' => $valuation['total_value'],
                'stock_movements' => $movements['movement_count'],
                'expiring_soon' => $expiry['expiring_soon_items'],
                'waste_value' => $waste['total_cost'],
                'waste_record_count' => $waste['record_count'],
            ],
            'reports' => [
                'current_stock' => $stock,
                'inventory_valuation' => $valuation,
                'stock_movement' => $movements,
                'purchases' => $purchases,
                'suppliers' => $suppliers,
                'expiry' => $expiry,
                'waste' => $waste,
                'consumption' => [
                    'summary' => $consumption['summary'],
                    'top_items' => array_slice($consumption['items'], 0, 5),
                ],
            ],
        ]);
    }

    public function dashboardKpis(Request $request)
    {
        [$from, $to] = $this->dateRange($request);
        $storeIds = $this->storeIds($request);
        $stock = $this->stockSummary($storeIds);
        $valuation = $this->valuationReport($storeIds);
        $movements = $this->movementReport($storeIds, $from, $to);
        $expiry = $this->expiryReport($storeIds);
        $waste = $this->wasteReport($storeIds, $from, $to);
        $expiryAlerts = $this->dashboardExpiryAlerts($storeIds);

        return $this->success([
            'kpis' => [
                'total_items' => $stock['total_skus'],
                'low_stock_items' => $stock['low_stock_items'],
                'out_of_stock_items' => $stock['out_of_stock_items'],
                'stock_health_percent' => $stock['stock_health_percent'],
                'inventory_value' => $valuation['total_value'],
                'stock_movements' => $movements['movement_count'],
                'expiring_soon' => $expiry['expiring_soon_items'],
                'expired_items' => $expiry['expired_items'],
                'untracked_expiry_items' => $expiry['untracked_stock_items_count'],
                'waste_value' => $waste['total_cost'],
                'waste_record_count' => $waste['record_count'],
            ],
            'alerts' => [
                'expiring_batches' => $expiryAlerts,
            ],
            'period' => ['from' => $from->toDateString(), 'to' => $to->toDateString()],
        ]);
    }

    public function currentStock(Request $request)
    {
        $storeIds = $this->storeIds($request);
        $filters = $request->validate(['per_page' => 'nullable|integer|min:1|max:100']);
        $items = $this->stockItemsQuery($storeIds)
            ->orderBy('items.name')
            ->paginate($filters['per_page'] ?? 50);

        return $this->success([
            'items' => $items->items(),
            'summary' => $this->stockSummary($storeIds),
            'pagination' => [
                'current_page' => $items->currentPage(),
                'last_page' => $items->lastPage(),
                'per_page' => $items->perPage(),
                'total' => $items->total(),
            ],
        ]);
    }

    public function lowStock(Request $request)
    {
        $storeIds = $this->storeIds($request);
        $filters = $request->validate(['per_page' => 'nullable|integer|min:1|max:100']);
        $items = $this->stockItemsQuery($storeIds)
            ->havingRaw(
                'SUM(store_stock.quantity) <= SUM(store_stock.min_quantity) AND (SUM(store_stock.min_quantity) > 0 OR SUM(store_stock.quantity) <= 0)'
            )
            ->orderByRaw('SUM(store_stock.quantity) ASC')
            ->paginate($filters['per_page'] ?? 50);

        return $this->success([
            'items' => $items->items(),
            'summary' => $this->stockSummary($storeIds),
            'pagination' => [
                'current_page' => $items->currentPage(),
                'last_page' => $items->lastPage(),
                'per_page' => $items->perPage(),
                'total' => $items->total(),
            ],
        ]);
    }

    public function consumption(Request $request)
    {
        [$from, $to] = $this->dateRange($request);
        $storeIds = $this->storeIds($request);
        $filters = $request->validate([
            'search' => 'nullable|string|max:255',
            'filter' => ['nullable', Rule::in(['all', 'high_variance', 'moderate', 'normal', 'wastage', 'high_usage'])],
            'sort' => ['nullable', Rule::in(['consumption', 'variance', 'wastage', 'name'])],
            'page' => 'nullable|integer|min:1',
            'per_page' => 'nullable|integer|min:1|max:100',
        ]);

        $report = $this->consumptionReport($storeIds, $from, $to, $filters['search'] ?? null);
        $rows = collect($report['items']);
        $filter = $filters['filter'] ?? 'all';

        if ($filter !== 'all') {
            $rows = $rows->filter(function (array $row) use ($filter): bool {
                return match ($filter) {
                    'high_variance' => $row['status'] === 'high',
                    'moderate' => $row['status'] === 'moderate',
                    'normal' => $row['status'] === 'normal',
                    'wastage' => $row['wastage_quantity'] > 3,
                    'high_usage' => $row['actual_quantity'] > 100,
                    default => true,
                };
            });
        }

        $sort = $filters['sort'] ?? 'consumption';
        $rows = match ($sort) {
            'variance' => $rows->sortByDesc(fn (array $row) => abs((float) ($row['variance_quantity'] ?? 0)))->values(),
            'wastage' => $rows->sortByDesc('wastage_quantity')->values(),
            'name' => $rows->sortBy('name')->values(),
            default => $rows->sortByDesc('actual_quantity')->values(),
        };
        $perPage = $filters['per_page'] ?? 50;
        $page = $filters['page'] ?? 1;
        $total = $rows->count();

        return $this->success([
            'period' => ['from' => $from->toDateString(), 'to' => $to->toDateString()],
            'summary' => $report['summary'],
            'items' => $rows->forPage($page, $perPage)->values(),
            'pagination' => [
                'current_page' => $page,
                'last_page' => max(1, (int) ceil($total / $perPage)),
                'per_page' => $perPage,
                'total' => $total,
            ],
            'filters' => [
                'search' => $filters['search'] ?? null,
                'filter' => $filter,
                'sort' => $sort,
            ],
        ]);
    }

    /**
     * Null means an administrator's all-store scope. An empty array means
     * that a user has no assignments and therefore sees no store data.
     */
    private function storeIds(Request $request): ?array
    {
        $filters = $request->validate([
            'store_id' => 'nullable|uuid|exists:stores,id',
        ]);
        $user = $request->user();

        if (! empty($filters['store_id'])) {
            abort_unless($user->canAccessStore($filters['store_id']), 403, 'You do not have access to this store.');

            return [$filters['store_id']];
        }

        return $user->role === User::ROLE_ADMIN
            ? null
            : $user->stores()->pluck('stores.id')->all();
    }

    /**
     * @return array{0: Carbon, 1: Carbon, 2: string}
     */
    private function dateRange(Request $request): array
    {
        $filters = $request->validate([
            'period' => ['nullable', Rule::in(['daily', 'weekly', 'monthly', 'Daily', 'Weekly', 'Monthly'])],
            'from' => 'nullable|date_format:Y-m-d',
            'to' => 'nullable|date_format:Y-m-d|after_or_equal:from',
        ]);
        $period = strtolower($filters['period'] ?? 'weekly');
        $to = Carbon::parse($filters['to'] ?? now())->endOfDay();
        $from = ! empty($filters['from'])
            ? Carbon::parse($filters['from'])->startOfDay()
            : match ($period) {
                'daily' => $to->copy()->startOfDay(),
                'monthly' => $to->copy()->startOfMonth(),
                default => $to->copy()->startOfWeek(Carbon::MONDAY),
            };

        return [$from, $to, $period];
    }

    private function stockQuery(?array $storeIds): Builder
    {
        $query = DB::table('store_stock')
            ->join('items', 'items.id', '=', 'store_stock.item_id')
            ->whereNull('items.deleted_at')
            ->where('items.is_active', true);

        if ($storeIds !== null) {
            $query->whereIn('store_stock.store_id', $storeIds);
        }

        return $query;
    }

    private function stockItemsQuery(?array $storeIds): Builder
    {
        return $this->stockQuery($storeIds)
            ->select('items.id', 'items.code', 'items.name', 'items.category', 'items.item_type', 'items.unit')
            ->selectRaw('SUM(store_stock.quantity) AS quantity')
            ->selectRaw('SUM(store_stock.reserved_quantity) AS reserved_quantity')
            ->selectRaw('SUM(store_stock.min_quantity) AS minimum_quantity')
            ->selectRaw(
                'SUM(store_stock.quantity * COALESCE(store_stock.current_cost, store_stock.last_cost, items.default_purchase_price, 0)) AS stock_value'
            )
            ->groupBy('items.id', 'items.code', 'items.name', 'items.category', 'items.item_type', 'items.unit');
    }

    private function stockSummary(?array $storeIds): array
    {
        $summary = DB::query()
            ->fromSub($this->stockItemsQuery($storeIds), 'stock_items')
            ->selectRaw('COUNT(*) AS total_skus')
            ->selectRaw('SUM(CASE WHEN quantity > 0 THEN 1 ELSE 0 END) AS in_stock_items')
            ->selectRaw('SUM(CASE WHEN quantity > 0 AND quantity <= minimum_quantity THEN 1 ELSE 0 END) AS low_stock_items')
            ->selectRaw('SUM(CASE WHEN quantity <= 0 THEN 1 ELSE 0 END) AS out_of_stock_items')
            ->selectRaw('SUM(CASE WHEN quantity > minimum_quantity THEN 1 ELSE 0 END) AS healthy_items')
            ->first();

        $total = (int) ($summary->total_skus ?? 0);
        $healthy = (int) ($summary->healthy_items ?? 0);

        return [
            'total_skus' => $total,
            'in_stock_items' => (int) ($summary->in_stock_items ?? 0),
            'low_stock_items' => (int) ($summary->low_stock_items ?? 0),
            'out_of_stock_items' => (int) ($summary->out_of_stock_items ?? 0),
            'stock_health_percent' => $total === 0 ? 0 : round($healthy * 100 / $total, 1),
        ];
    }

    private function valuationReport(?array $storeIds): array
    {
        $typeRows = $this->stockQuery($storeIds)
            ->select('items.item_type')
            ->selectRaw('COUNT(DISTINCT items.id) AS sku_count')
            ->selectRaw(
                'SUM(store_stock.quantity * COALESCE(store_stock.current_cost, store_stock.last_cost, items.default_purchase_price, 0)) AS stock_value'
            )
            ->groupBy('items.item_type')
            ->get();
        $byType = $typeRows->mapWithKeys(fn ($row) => [
            $row->item_type => [
                'sku_count' => (int) $row->sku_count,
                'value' => round((float) $row->stock_value, 2),
            ],
        ])->all();
        $totalValue = round((float) $typeRows->sum('stock_value'), 2);
        $skuCount = $this->stockSummary($storeIds)['total_skus'];

        return [
            'total_value' => $totalValue,
            'average_value_per_item' => $skuCount === 0 ? 0 : round($totalValue / $skuCount, 2),
            'currency' => 'ETB',
            'by_item_type' => $byType,
            'basis' => 'quantity multiplied by current cost, last cost, or item default purchase price, in that order',
        ];
    }

    private function movementReport(?array $storeIds, Carbon $from, Carbon $to): array
    {
        $query = StockMovement::query()->whereBetween('created_at', [$from, $to]);
        if ($storeIds !== null) {
            $query->whereIn('store_id', $storeIds);
        }

        $byUnit = (clone $query)
            ->select('unit')
            ->selectRaw("SUM(CASE WHEN type IN ('Stock In', 'Return') THEN quantity ELSE 0 END) AS inbound_quantity")
            ->selectRaw("SUM(CASE WHEN type = 'Stock Out' THEN quantity ELSE 0 END) AS outbound_quantity")
            ->selectRaw('SUM(quantity_after - quantity_before) AS net_quantity_change')
            ->groupBy('unit')
            ->get()
            ->mapWithKeys(fn ($row) => [
                $row->unit => [
                    'inbound_quantity' => round((float) $row->inbound_quantity, 3),
                    'outbound_quantity' => round((float) $row->outbound_quantity, 3),
                    'net_quantity_change' => round((float) $row->net_quantity_change, 3),
                ],
            ])
            ->all();
        $singleUnit = count($byUnit) === 1 ? reset($byUnit) : null;

        return [
            'movement_count' => (clone $query)->count(),
            'inbound_quantity' => $singleUnit['inbound_quantity'] ?? (empty($byUnit) ? 0 : null),
            'outbound_quantity' => $singleUnit['outbound_quantity'] ?? (empty($byUnit) ? 0 : null),
            'transfer_count' => (clone $query)->where('type', 'Transfer')->count(),
            'net_quantity_change' => $singleUnit['net_quantity_change'] ?? (empty($byUnit) ? 0 : null),
            'quantity_by_unit' => $byUnit,
            'mixed_units' => count($byUnit) > 1,
        ];
    }

    private function purchaseQuery(?array $storeIds, Carbon $from, Carbon $to): Builder
    {
        $query = DB::table('purchase_orders')
            ->whereNull('purchase_orders.deleted_at')
            ->whereBetween('purchase_orders.order_date', [$from->toDateString(), $to->toDateString()]);
        if ($storeIds !== null) {
            $query->whereIn('destination_store_id', $storeIds);
        }

        return $query;
    }

    private function purchaseReport(?array $storeIds, Carbon $from, Carbon $to): array
    {
        $orders = $this->purchaseQuery($storeIds, $from, $to);
        $count = (clone $orders)->count();
        $amount = round((float) (clone $orders)->sum('total_amount'), 2);
        $itemsQuery = DB::table('purchase_order_items')
            ->join('purchase_orders', 'purchase_orders.id', '=', 'purchase_order_items.purchase_order_id')
            ->whereNull('purchase_orders.deleted_at')
            ->whereBetween('purchase_orders.order_date', [$from->toDateString(), $to->toDateString()]);
        if ($storeIds !== null) {
            $itemsQuery->whereIn('purchase_orders.destination_store_id', $storeIds);
        }
        $itemsByUnit = (clone $itemsQuery)
            ->select('purchase_order_items.unit')
            ->selectRaw('SUM(purchase_order_items.quantity) AS quantity')
            ->groupBy('purchase_order_items.unit')
            ->get()
            ->mapWithKeys(fn ($row) => [$row->unit => round((float) $row->quantity, 3)])
            ->all();
        $singleUnitQuantity = count($itemsByUnit) === 1 ? reset($itemsByUnit) : null;

        return [
            'orders_placed' => $count,
            'items_ordered' => $singleUnitQuantity ?? (empty($itemsByUnit) ? 0 : null),
            'items_ordered_by_unit' => $itemsByUnit,
            'mixed_units' => count($itemsByUnit) > 1,
            'total_spent' => $amount,
            'average_order_value' => $count === 0 ? 0 : round($amount / $count, 2),
            'currency' => 'ETB',
            'spend_basis' => 'sum of order totals for purchase orders placed in the selected period',
        ];
    }

    private function supplierReport(?array $storeIds, Carbon $from, Carbon $to): array
    {
        $query = $this->purchaseQuery($storeIds, $from, $to);
        $suppliers = (clone $query)
            ->join('suppliers', 'suppliers.id', '=', 'purchase_orders.supplier_id')
            ->select('suppliers.id', 'suppliers.name')
            ->selectRaw('SUM(purchase_orders.total_amount) AS total_spend')
            ->groupBy('suppliers.id', 'suppliers.name')
            ->orderByDesc('total_spend')
            ->limit(5)
            ->get()
            ->map(fn ($supplier) => [
                'id' => $supplier->id,
                'name' => $supplier->name,
                'total_spend' => round((float) $supplier->total_spend, 2),
                'currency' => 'ETB',
            ])
            ->values();

        $receivedOrders = (clone $query)
            ->whereNotNull('received_at')
            ->whereNotNull('expected_delivery_date')
            ->get(['received_at', 'expected_delivery_date']);
        $eligible = $receivedOrders->count();
        $onTime = $receivedOrders->filter(fn ($order) => Carbon::parse($order->received_at)->toDateString() <= Carbon::parse($order->expected_delivery_date)->toDateString()
        )->count();

        return [
            'top_suppliers' => $suppliers,
            'on_time_delivery_percent' => $eligible === 0 ? null : round($onTime * 100 / $eligible, 1),
            'on_time_delivery_sample_size' => $eligible,
        ];
    }

    private function expiryReport(?array $storeIds): array
    {
        $query = DB::table('inventory_batches')->where('quantity_remaining', '>', 0);
        if ($storeIds !== null) {
            $query->whereIn('store_id', $storeIds);
        }
        $today = Carbon::today();
        $threeDays = $today->copy()->addDays(3);
        $sevenDays = $today->copy()->addDays(7);
        $thirtyDays = $today->copy()->addDays(30);
        $countBetween = fn (Carbon $start, Carbon $end): int => (int) (clone $query)
            ->whereBetween('expires_on', [$start->toDateString(), $end->toDateString()])
            ->distinct()
            ->count('item_id');
        $trackedByUnit = (clone $query)
            ->join('items', 'items.id', '=', 'inventory_batches.item_id')
            ->select('items.unit')
            ->selectRaw('SUM(inventory_batches.quantity_remaining) AS quantity')
            ->groupBy('items.unit')
            ->get()
            ->mapWithKeys(fn ($row) => [$row->unit => round((float) $row->quantity, 3)])
            ->all();
        $trackedSubquery = DB::table('inventory_batches')
            ->select('store_id', 'item_id')
            ->selectRaw('SUM(quantity_remaining) AS tracked_quantity')
            ->groupBy('store_id', 'item_id');
        $untrackedStock = DB::table('store_stock')
            ->leftJoinSub($trackedSubquery, 'tracked_batches', function ($join) {
                $join->on('tracked_batches.store_id', '=', 'store_stock.store_id')
                    ->on('tracked_batches.item_id', '=', 'store_stock.item_id');
            })
            ->whereRaw('store_stock.quantity > COALESCE(tracked_batches.tracked_quantity, 0) + 0.0005');
        if ($storeIds !== null) {
            $untrackedStock->whereIn('store_stock.store_id', $storeIds);
        }
        $expiring = $countBetween($today, $sevenDays);

        return [
            'expiring_soon_items' => $expiring,
            'expired_items' => (int) (clone $query)->whereDate('expires_on', '<', $today->toDateString())->distinct()->count('item_id'),
            'total_at_risk_items' => $countBetween($today, $thirtyDays),
            'tracked_batch_count' => (clone $query)->count(),
            'tracked_quantity_by_unit' => $trackedByUnit,
            'untracked_stock_items_count' => (int) $untrackedStock->distinct()->count('store_stock.item_id'),
            'tracking_basis' => 'remaining inventory-batch quantity and its exact expiry date',
            'lot_expiry_dates_available' => true,
            'day_buckets' => [
                '0_to_3_days' => $countBetween($today, $threeDays),
                '4_to_7_days' => $countBetween($today->copy()->addDays(4), $sevenDays),
                '8_to_30_days' => $countBetween($today->copy()->addDays(8), $thirtyDays),
            ],
        ];
    }

    private function dashboardExpiryAlerts(?array $storeIds): array
    {
        $today = Carbon::today();
        $withinSevenDays = $today->copy()->addDays(7);
        $query = DB::table('inventory_batches')
            ->join('items', 'items.id', '=', 'inventory_batches.item_id')
            ->join('stores', 'stores.id', '=', 'inventory_batches.store_id')
            ->whereNull('items.deleted_at')
            ->where('inventory_batches.quantity_remaining', '>', 0)
            ->whereBetween('inventory_batches.expires_on', [
                $today->copy()->subDays(7)->toDateString(),
                $withinSevenDays->toDateString(),
            ]);

        if ($storeIds !== null) {
            $query->whereIn('inventory_batches.store_id', $storeIds);
        }

        return $query
            ->orderByRaw(
                'CASE WHEN inventory_batches.expires_on >= ? THEN 0 ELSE 1 END',
                [$today->toDateString()]
            )
            ->orderBy('inventory_batches.expires_on')
            ->limit(5)
            ->get([
                'inventory_batches.id',
                'inventory_batches.lot_number',
                'inventory_batches.expires_on',
                'inventory_batches.quantity_remaining',
                'items.name as item_name',
                'items.unit',
                'stores.name as store_name',
            ])
            ->map(function ($batch) use ($today): array {
                $expiresOn = Carbon::parse($batch->expires_on)->startOfDay();
                $daysUntilExpiry = (int) $today->diffInDays($expiresOn, false);

                return [
                    'id' => $batch->id,
                    'item' => $batch->item_name,
                    'store' => $batch->store_name,
                    'batch_number' => $batch->lot_number,
                    'quantity' => (float) $batch->quantity_remaining,
                    'unit' => $batch->unit,
                    'expiry_date' => $expiresOn->toDateString(),
                    'days_until_expiry' => $daysUntilExpiry,
                    'status' => $daysUntilExpiry < 0 ? 'Expired' : 'Expiring soon',
                ];
            })
            ->values()
            ->all();
    }

    private function wasteReport(?array $storeIds, Carbon $from, Carbon $to): array
    {
        $query = DB::table('waste_records')
            ->whereNull('deleted_at')
            ->where('status', 'Confirmed')
            ->whereBetween('date', [$from, $to]);
        if ($storeIds !== null) {
            $query->whereIn('store_id', $storeIds);
        }

        $groupedReasons = (clone $query)
            ->select('reason')
            ->selectRaw('COUNT(*) AS record_count')
            ->selectRaw('SUM(quantity) AS quantity')
            ->selectRaw('SUM(estimated_cost) AS estimated_cost')
            ->groupBy('reason')
            ->get();
        $byReason = ['spoilage' => 0.0, 'damaged' => 0.0, 'expired' => 0.0, 'other' => 0.0];
        $byUnit = (clone $query)
            ->select('unit')
            ->selectRaw('SUM(quantity) AS quantity')
            ->groupBy('unit')
            ->get()
            ->mapWithKeys(fn ($row) => [$row->unit => round((float) $row->quantity, 3)])
            ->all();

        foreach ($groupedReasons as $row) {
            $reason = strtolower((string) $row->reason);
            $key = str_contains($reason, 'spoil') ? 'spoilage'
                : (str_contains($reason, 'damag') ? 'damaged'
                    : (str_contains($reason, 'expir') ? 'expired' : 'other'));
            $byReason[$key] += (float) $row->estimated_cost;
        }

        return [
            'record_count' => (int) (clone $query)->count(),
            'total_cost' => round((float) (clone $query)->sum('estimated_cost'), 2),
            'currency' => 'ETB',
            'quantity_by_unit' => $byUnit,
            'cost_by_reason' => array_map(fn ($amount) => round($amount, 2), $byReason),
            'waste_as_percent_of_sales' => null,
            'sales_data_available' => false,
            'basis' => 'confirmed waste records only',
        ];
    }

    private function consumptionReport(?array $storeIds, Carbon $from, Carbon $to, ?string $search = null): array
    {
        $issues = DB::table('kitchen_issue_items')
            ->join('kitchen_issues', 'kitchen_issues.id', '=', 'kitchen_issue_items.kitchen_issue_id')
            ->join('items', 'items.id', '=', 'kitchen_issue_items.item_id')
            ->leftJoin('store_stock', function ($join) {
                $join->on('store_stock.item_id', '=', 'kitchen_issue_items.item_id')
                    ->on('store_stock.store_id', '=', 'kitchen_issues.store_id');
            })
            ->whereNull('kitchen_issues.deleted_at')
            ->whereNull('items.deleted_at')
            ->where('kitchen_issues.status', 'Issued')
            ->whereNotNull('kitchen_issues.issued_at')
            ->whereNotNull('kitchen_issue_items.quantity_issued')
            ->whereBetween('kitchen_issues.issued_at', [$from, $to]);

        if ($storeIds !== null) {
            $issues->whereIn('kitchen_issues.store_id', $storeIds);
        }
        if ($search !== null && trim($search) !== '') {
            $pattern = '%'.mb_strtolower(trim($search)).'%';
            $issues->whereRaw('LOWER(items.name) LIKE ?', [$pattern]);
        }

        $records = $issues
            ->select('items.id', 'items.name', 'items.category', 'kitchen_issue_items.unit')
            ->selectRaw('SUM(kitchen_issue_items.quantity_issued) AS actual_quantity')
            ->selectRaw('SUM(kitchen_issue_items.quantity_requested) AS planned_quantity')
            ->selectRaw(
                'SUM(kitchen_issue_items.quantity_issued * COALESCE(store_stock.current_cost, store_stock.last_cost, items.default_purchase_price, 0)) AS known_consumption_cost'
            )
            ->selectRaw(
                'SUM(CASE WHEN kitchen_issue_items.quantity_issued > 0 AND COALESCE(store_stock.current_cost, store_stock.last_cost, items.default_purchase_price) IS NULL THEN kitchen_issue_items.quantity_issued ELSE 0 END) AS unpriced_quantity'
            )
            ->groupBy('items.id', 'items.name', 'items.category', 'kitchen_issue_items.unit')
            ->get();

        $production = DB::table('production_run_items')
            ->join('production_runs', 'production_runs.id', '=', 'production_run_items.production_run_id')
            ->leftJoin('items AS production_items', 'production_items.id', '=', 'production_run_items.item_id')
            ->whereBetween('production_runs.production_date', [$from->toDateString(), $to->toDateString()]);
        if ($storeIds !== null) {
            $production->whereIn('production_runs.store_id', $storeIds);
        }
        if ($search !== null && trim($search) !== '') {
            $pattern = '%'.mb_strtolower(trim($search)).'%';
            $production->whereRaw('LOWER(COALESCE(production_items.name, production_run_items.ingredient_name)) LIKE ?', [$pattern]);
        }
        $theoreticalRecords = $production
            ->select('production_run_items.item_id', 'production_run_items.ingredient_name', 'production_run_items.unit')
            ->selectRaw("COALESCE(production_items.name, production_run_items.ingredient_name) AS name")
            ->selectRaw("COALESCE(production_items.category, 'Unlinked recipe ingredient') AS category")
            ->selectRaw('SUM(production_run_items.theoretical_quantity) AS theoretical_quantity')
            ->selectRaw('SUM(production_run_items.theoretical_quantity * COALESCE(production_run_items.unit_cost, 0)) AS theoretical_cost')
            ->selectRaw('SUM(CASE WHEN production_run_items.unit_cost IS NULL THEN production_run_items.theoretical_quantity ELSE 0 END) AS unpriced_theoretical_quantity')
            ->groupBy(
                'production_run_items.item_id',
                'production_run_items.ingredient_name',
                'production_run_items.unit',
                'production_items.name',
                'production_items.category'
            )
            ->get();
        $productionRuns = DB::table('production_runs')
            ->whereBetween('production_date', [$from->toDateString(), $to->toDateString()]);
        if ($storeIds !== null) {
            $productionRuns->whereIn('store_id', $storeIds);
        }
        $productionTotals = (clone $productionRuns)
            ->selectRaw('COUNT(*) AS run_count')
            ->selectRaw('COALESCE(SUM(produced_servings), 0) AS produced_servings')
            ->first();

        $wasteQuery = DB::table('waste_records')
            ->leftJoin('items AS waste_items', 'waste_items.id', '=', 'waste_records.item_id')
            ->whereNull('waste_records.deleted_at')
            ->where('waste_records.status', 'Confirmed')
            ->whereBetween('waste_records.date', [$from, $to]);
        if ($storeIds !== null) {
            $wasteQuery->whereIn('waste_records.store_id', $storeIds);
        }
        if ($search !== null && trim($search) !== '') {
            $pattern = '%'.mb_strtolower(trim($search)).'%';
            $wasteQuery->whereRaw('LOWER(COALESCE(waste_items.name, waste_records.item)) LIKE ?', [$pattern]);
        }
        $wasteRecords = $wasteQuery
            ->select('waste_records.item_id', 'waste_records.item', 'waste_records.unit')
            ->selectRaw('COALESCE(waste_items.name, waste_records.item) AS name')
            ->selectRaw("COALESCE(waste_items.category, 'Uncategorized') AS category")
            ->selectRaw('SUM(waste_records.quantity) AS wastage_quantity')
            ->groupBy('waste_records.item_id', 'waste_records.item', 'waste_records.unit', 'waste_items.name', 'waste_items.category')
            ->get()
            ;

        $rows = [];
        $ensureRow = function (?string $itemId, string $name, string $category, string $unit) use (&$rows): string {
            $identity = $itemId ? 'item:'.$itemId : 'name:'.mb_strtolower(trim($name));
            $key = $identity.'|'.mb_strtolower(trim($unit));
            if (!isset($rows[$key])) {
                $rows[$key] = [
                    'id' => $itemId ?: 'ingredient:'.substr(sha1($identity.'|'.$unit), 0, 16),
                    'name' => $name,
                    'category' => $category,
                    'unit' => $unit,
                    'actual_quantity' => 0.0,
                    'planned_quantity' => 0.0,
                    'theoretical_quantity' => null,
                    'wastage_quantity' => 0.0,
                    'known_consumption_cost' => 0.0,
                    'unpriced_actual_quantity' => 0.0,
                    'theoretical_cost' => 0.0,
                    'unpriced_theoretical_quantity' => 0.0,
                ];
            }

            return $key;
        };

        foreach ($records as $record) {
            $key = $ensureRow($record->id, $record->name, $record->category ?? '', $record->unit ?? '');
            $rows[$key]['actual_quantity'] += (float) $record->actual_quantity;
            $rows[$key]['planned_quantity'] += (float) $record->planned_quantity;
            $rows[$key]['known_consumption_cost'] += (float) $record->known_consumption_cost;
            $rows[$key]['unpriced_actual_quantity'] += (float) $record->unpriced_quantity;
        }
        foreach ($theoreticalRecords as $record) {
            $key = $ensureRow($record->item_id, $record->name, $record->category, $record->unit);
            $rows[$key]['theoretical_quantity'] = ($rows[$key]['theoretical_quantity'] ?? 0) + (float) $record->theoretical_quantity;
            $rows[$key]['theoretical_cost'] += (float) $record->theoretical_cost;
            $rows[$key]['unpriced_theoretical_quantity'] += (float) $record->unpriced_theoretical_quantity;
        }
        foreach ($wasteRecords as $record) {
            $key = $ensureRow($record->item_id, $record->name, $record->category, $record->unit);
            $rows[$key]['wastage_quantity'] += (float) $record->wastage_quantity;
        }

        $rows = array_map(function (array $row): array {
            $actual = (float) $row['actual_quantity'];
            $theoretical = $row['theoretical_quantity'] === null
                ? null
                : (float) $row['theoretical_quantity'];
            $variance = $theoretical === null ? null : $actual - $theoretical;
            $variancePercent = $theoretical === null
                ? null
                : ($theoretical > 0
                    ? round($variance * 100 / $theoretical, 1)
                    : ($actual > 0 ? 100.0 : 0.0));
            $status = $variancePercent === null ? 'unavailable'
                : (abs($variancePercent) >= 10 ? 'high'
                    : (abs($variancePercent) >= 5 ? 'moderate' : 'normal'));
            $actualCostComplete = (float) $row['unpriced_actual_quantity'] <= 0;
            $theoreticalCostComplete = (float) $row['unpriced_theoretical_quantity'] <= 0;
            $unitCost = $actual > 0 && $actualCostComplete
                ? (float) $row['known_consumption_cost'] / $actual
                : ($theoretical !== null && $theoretical > 0 && $theoreticalCostComplete
                    ? (float) $row['theoretical_cost'] / $theoretical
                    : null);

            return [
                'id' => $row['id'],
                'name' => $row['name'],
                'category' => $row['category'],
                'unit' => $row['unit'],
                'actual_quantity' => round($actual, 3),
                'planned_quantity' => round((float) $row['planned_quantity'], 3),
                'theoretical_quantity' => $theoretical === null ? null : round($theoretical, 3),
                'wastage_quantity' => round((float) $row['wastage_quantity'], 3),
                'variance_quantity' => $variance === null ? null : round($variance, 3),
                'variance_percent' => $variancePercent,
                'status' => $status,
                'unit_cost' => $unitCost === null ? null : round($unitCost, 2),
                'consumption_cost' => $actualCostComplete ? round((float) $row['known_consumption_cost'], 2) : null,
                'variance_cost' => $variance === null || $unitCost === null
                    ? null
                    : round(max(0, $variance) * $unitCost, 2),
                'cost_complete' => $actualCostComplete,
                'theoretical_available' => $theoretical !== null,
            ];
        }, array_values($rows));

        $summary = $this->consumptionSummary($rows);
        $summary['production_run_count'] = (int) ($productionTotals->run_count ?? 0);
        $summary['produced_servings'] = round((float) ($productionTotals->produced_servings ?? 0), 3);
        $summary['production_data_available'] = $summary['production_run_count'] > 0;
        $summary['production_summary_basis'] = 'count and sum of production runs recorded for the selected period';

        return ['summary' => $summary, 'items' => $rows];
    }

    private function consumptionSummary(array $rows): array
    {
        $byUnit = [];
        $knownCost = 0.0;
        $knownVarianceCost = 0.0;
        $allCostsKnown = true;
        $allVarianceCostsKnown = true;
        $hasTheoretical = false;
        $hasActualWithoutTheoretical = false;
        $actualItemCount = 0;
        $actualItemCountWithTheoretical = 0;

        foreach ($rows as $row) {
            $unit = $row['unit'] ?: 'unspecified';
            $byUnit[$unit] ??= [
                'actual_quantity' => 0.0,
                'planned_quantity' => 0.0,
                'theoretical_quantity' => 0.0,
                'wastage_quantity' => 0.0,
                'variance_quantity' => 0.0,
                'item_count' => 0,
                'theoretical_item_count' => 0,
                'actual_items_without_theoretical' => 0,
                'actual_item_count' => 0,
                'actual_items_with_theoretical' => 0,
            ];
            $byUnit[$unit]['item_count']++;
            $byUnit[$unit]['actual_quantity'] += $row['actual_quantity'];
            $byUnit[$unit]['planned_quantity'] += $row['planned_quantity'];
            $byUnit[$unit]['wastage_quantity'] += $row['wastage_quantity'];
            if ($row['theoretical_quantity'] !== null) {
                $hasTheoretical = true;
                $byUnit[$unit]['theoretical_quantity'] += $row['theoretical_quantity'];
                $byUnit[$unit]['variance_quantity'] += $row['variance_quantity'];
                $byUnit[$unit]['theoretical_item_count']++;
                if ($row['actual_quantity'] > 0) {
                    $actualItemCountWithTheoretical++;
                    $byUnit[$unit]['actual_items_with_theoretical']++;
                }
            } elseif ($row['actual_quantity'] > 0) {
                $hasActualWithoutTheoretical = true;
                $byUnit[$unit]['actual_items_without_theoretical']++;
            }
            if ($row['actual_quantity'] > 0) {
                $actualItemCount++;
                $byUnit[$unit]['actual_item_count']++;
            }

            if ($row['consumption_cost'] === null) {
                $allCostsKnown = false;
            } else {
                $knownCost += $row['consumption_cost'];
            }
            if ($row['theoretical_quantity'] !== null) {
                if ($row['variance_cost'] === null) {
                    $allVarianceCostsKnown = false;
                } else {
                    $knownVarianceCost += $row['variance_cost'];
                }
            }
        }

        foreach ($byUnit as &$totals) {
            foreach (['actual_quantity', 'planned_quantity', 'theoretical_quantity', 'wastage_quantity', 'variance_quantity'] as $quantityKey) {
                $totals[$quantityKey] = round($totals[$quantityKey], 3);
            }
        }
        unset($totals);
        $singleUnit = count($byUnit) === 1 ? reset($byUnit) : null;
        $theoreticalComplete = !$hasActualWithoutTheoretical;
        $theoreticalValue = $singleUnit !== null && $hasTheoretical && $theoreticalComplete
            ? $singleUnit['theoretical_quantity']
            : null;
        $varianceValue = $singleUnit !== null && $hasTheoretical && $theoreticalComplete
            ? $singleUnit['variance_quantity']
            : null;

        return [
            'actual_quantity_by_unit' => $byUnit,
            'total_consumption_quantity' => $singleUnit['actual_quantity'] ?? (empty($byUnit) ? 0 : null),
            'planned_quantity' => $singleUnit['planned_quantity'] ?? (empty($byUnit) ? 0 : null),
            'theoretical_quantity_by_unit' => $hasTheoretical
                ? collect($byUnit)->map(fn ($totals) => $totals['actual_items_without_theoretical'] > 0
                    ? null
                    : $totals['theoretical_quantity'])->all()
                : [],
            'theoretical_quantity' => $theoreticalValue,
            'wastage_quantity' => $singleUnit['wastage_quantity'] ?? (empty($byUnit) ? 0 : null),
            'variance_quantity' => $varianceValue,
            'mixed_units' => count($byUnit) > 1,
            'consumption_cost' => $allCostsKnown ? round($knownCost, 2) : null,
            'variance_cost' => $hasTheoretical && $theoreticalComplete && $allVarianceCostsKnown
                ? round($knownVarianceCost, 2)
                : null,
            'currency' => 'ETB',
            'cost_complete' => $allCostsKnown,
            'variance_basis' => 'issued kitchen quantity minus recipe ingredient quantities scaled to recorded production servings',
            'actual_quantity_basis' => 'quantity issued to the kitchen; not a direct measurement of ingredients consumed during preparation',
            'theoretical_data_available' => $hasTheoretical,
            'theoretical_complete' => $theoreticalComplete,
            'theoretical_coverage_percent' => $actualItemCount === 0
                ? null
                : round($actualItemCountWithTheoretical * 100 / $actualItemCount, 1),
            'limitation' => $hasTheoretical
                ? null
                : 'No production runs have been recorded for this period. Record recipe production to calculate theoretical ingredient usage.',
        ];
    }
}
