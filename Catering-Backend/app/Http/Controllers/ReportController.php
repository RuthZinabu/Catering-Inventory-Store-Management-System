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

        return $this->success([
            'kpis' => [
                'total_items' => $stock['total_skus'],
                'inventory_value' => $valuation['total_value'],
                'stock_movements' => $movements['movement_count'],
                'expiring_soon' => $expiry['expiring_soon_items'],
                'waste_value' => $waste['total_cost'],
                'waste_record_count' => $waste['record_count'],
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
            ->havingRaw('SUM(store_stock.quantity) > 0 AND SUM(store_stock.quantity) <= SUM(store_stock.min_quantity)')
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
            'variance' => $rows->sortByDesc(fn (array $row) => abs($row['variance_quantity']))->values(),
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
        $query = $this->stockQuery($storeIds);
        $expiring = (clone $query)->where('store_stock.status', 'Expiring Soon')->distinct('items.id')->count('items.id');
        $expired = (clone $query)->where('store_stock.status', 'Expired')->distinct('items.id')->count('items.id');

        return [
            'expiring_soon_items' => $expiring,
            'expired_items' => $expired,
            'total_at_risk_items' => $expiring,
            'tracking_basis' => 'store stock status',
            'lot_expiry_dates_available' => false,
            'day_buckets' => ['0_to_3_days' => null, '4_to_7_days' => null, '8_to_30_days' => null],
            'limitation' => 'The inventory schema stores an expiring status, but not per-lot expiration dates, so exact day buckets cannot be calculated.',
        ];
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
            ->select('items.id', 'items.name', 'items.category', 'items.unit')
            ->selectRaw('SUM(kitchen_issue_items.quantity_issued) AS actual_quantity')
            ->selectRaw('SUM(kitchen_issue_items.quantity_requested) AS planned_quantity')
            ->selectRaw(
                'SUM(kitchen_issue_items.quantity_issued * COALESCE(store_stock.current_cost, store_stock.last_cost, items.default_purchase_price, 0)) AS known_consumption_cost'
            )
            ->selectRaw(
                'SUM(CASE WHEN kitchen_issue_items.quantity_issued > 0 AND COALESCE(store_stock.current_cost, store_stock.last_cost, items.default_purchase_price) IS NULL THEN kitchen_issue_items.quantity_issued ELSE 0 END) AS unpriced_quantity'
            )
            ->groupBy('items.id', 'items.name', 'items.category', 'items.unit')
            ->get();

        $wasteQuery = DB::table('waste_records')
            ->whereNull('deleted_at')
            ->where('status', 'Confirmed')
            ->whereNotNull('item_id')
            ->whereBetween('date', [$from, $to]);
        if ($storeIds !== null) {
            $wasteQuery->whereIn('store_id', $storeIds);
        }
        if ($search !== null && trim($search) !== '') {
            $pattern = '%'.mb_strtolower(trim($search)).'%';
            $wasteQuery->join('items AS waste_items', 'waste_items.id', '=', 'waste_records.item_id')
                ->whereRaw('LOWER(waste_items.name) LIKE ?', [$pattern]);
        }
        $wasteByItem = $wasteQuery
            ->select('item_id')
            ->selectRaw('SUM(quantity) AS wastage_quantity')
            ->groupBy('item_id')
            ->get()
            ->keyBy('item_id');

        $rows = $records->map(function ($record) use ($wasteByItem): array {
            $actual = (float) $record->actual_quantity;
            $planned = (float) $record->planned_quantity;
            $variance = $actual - $planned;
            $unpriced = (float) $record->unpriced_quantity > 0;
            $knownCost = round((float) $record->known_consumption_cost, 2);
            $wastage = (float) ($wasteByItem[$record->id]->wastage_quantity ?? 0);
            $variancePercent = $planned > 0
                ? round($variance * 100 / $planned, 1)
                : ($actual > 0 ? 100.0 : 0.0);
            $status = abs($variancePercent) >= 10 ? 'high'
                : (abs($variancePercent) >= 5 ? 'moderate' : 'normal');
            $unitCost = $actual > 0 ? $knownCost / $actual : null;

            return [
                'id' => $record->id,
                'name' => $record->name,
                'category' => $record->category,
                'unit' => $record->unit,
                'actual_quantity' => round($actual, 3),
                'planned_quantity' => round($planned, 3),
                'theoretical_quantity' => null,
                'wastage_quantity' => round($wastage, 3),
                'variance_quantity' => round($variance, 3),
                'variance_percent' => $variancePercent,
                'status' => $status,
                'unit_cost' => $unitCost === null ? null : round($unitCost, 2),
                'consumption_cost' => $unpriced ? null : $knownCost,
                'variance_cost' => $unpriced ? null : round(max(0, $variance) * ($unitCost ?? 0), 2),
                'cost_complete' => ! $unpriced,
            ];
        })->values()->all();

        return ['summary' => $this->consumptionSummary($rows), 'items' => $rows];
    }

    private function consumptionSummary(array $rows): array
    {
        $byUnit = [];
        $knownCost = 0.0;
        $varianceCost = 0.0;
        $allCostsKnown = true;

        foreach ($rows as $row) {
            $unit = $row['unit'] ?: 'unspecified';
            $byUnit[$unit] ??= [
                'actual_quantity' => 0.0,
                'planned_quantity' => 0.0,
                'wastage_quantity' => 0.0,
                'variance_quantity' => 0.0,
            ];
            $byUnit[$unit]['actual_quantity'] += $row['actual_quantity'];
            $byUnit[$unit]['planned_quantity'] += $row['planned_quantity'];
            $byUnit[$unit]['wastage_quantity'] += $row['wastage_quantity'];
            $byUnit[$unit]['variance_quantity'] += $row['variance_quantity'];

            if ($row['consumption_cost'] === null || $row['variance_cost'] === null) {
                $allCostsKnown = false;
            } else {
                $knownCost += $row['consumption_cost'];
                $varianceCost += $row['variance_cost'];
            }
        }

        foreach ($byUnit as &$totals) {
            foreach ($totals as &$quantity) {
                $quantity = round($quantity, 3);
            }
            unset($quantity);
        }
        unset($totals);
        $singleUnit = count($byUnit) === 1 ? reset($byUnit) : null;

        return [
            'actual_quantity_by_unit' => $byUnit,
            'total_consumption_quantity' => $singleUnit['actual_quantity'] ?? null,
            'planned_quantity' => $singleUnit['planned_quantity'] ?? null,
            'theoretical_quantity' => null,
            'wastage_quantity' => $singleUnit['wastage_quantity'] ?? null,
            'variance_quantity' => $singleUnit['variance_quantity'] ?? null,
            'mixed_units' => count($byUnit) > 1,
            'consumption_cost' => $allCostsKnown ? round($knownCost, 2) : null,
            'variance_cost' => $allCostsKnown ? round($varianceCost, 2) : null,
            'currency' => 'ETB',
            'cost_complete' => $allCostsKnown,
            'variance_basis' => 'issued quantity minus requested quantity on kitchen issues marked Issued',
            'theoretical_data_available' => false,
            'limitation' => 'Kitchen issues record requested and issued quantities, but the system does not record meal production or recipe usage, so theoretical consumption is unavailable.',
        ];
    }
}
