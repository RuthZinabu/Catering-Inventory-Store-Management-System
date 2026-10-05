<?php

namespace App\Http\Controllers;

use App\Models\User;
use Carbon\Carbon;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;

class UserActivityController extends Controller
{
    public function index(User $user)
    {
        $activities = collect();

        $this->append(
            $activities,
            'item-created',
            DB::table('items')
                ->where('created_by', $user->id)
                ->orderByDesc('created_at')
                ->limit(30)
                ->get(['id', 'name', 'code', 'created_at']),
            'inventory',
            'Created inventory item',
            fn ($row) => "{$row->name} ({$row->code})"
        );

        $this->append(
            $activities,
            'stock-movement',
            DB::table('stock_movements')
                ->leftJoin('items', 'items.id', '=', 'stock_movements.item_id')
                ->where('stock_movements.performed_by', $user->id)
                ->orderByDesc('stock_movements.created_at')
                ->limit(30)
                ->get([
                    'stock_movements.id',
                    'stock_movements.type as movement_type',
                    'stock_movements.quantity',
                    'stock_movements.unit',
                    'items.name as item_name',
                    'stock_movements.created_at',
                ]),
            'inventory',
            'Recorded stock movement',
            fn ($row) => $this->joinDetails(
                "{$row->movement_type} · {$row->quantity} {$row->unit}",
                $row->item_name
            )
        );

        $this->append(
            $activities,
            'stock-movement-approved',
            DB::table('stock_movements')
                ->where('approved_by', $user->id)
                ->whereNotNull('approved_at')
                ->orderByDesc('approved_at')
                ->limit(30)
                ->get(['id', 'type as movement_type', 'quantity', 'unit', 'approved_at as activity_at']),
            'inventory',
            'Approved stock movement',
            fn ($row) => "{$row->movement_type} · {$row->quantity} {$row->unit}",
            'activity_at'
        );

        $this->append(
            $activities,
            'purchase-order-created',
            DB::table('purchase_orders')
                ->where('created_by', $user->id)
                ->orderByDesc('created_at')
                ->limit(30)
                ->get(['id', 'number', 'status', 'created_at']),
            'purchases',
            'Created purchase order',
            fn ($row) => "{$row->number} · {$row->status}"
        );

        $this->append(
            $activities,
            'purchase-order-approved',
            DB::table('purchase_orders')
                ->where('approved_by', $user->id)
                ->orderByDesc('updated_at')
                ->limit(30)
                ->get(['id', 'number', 'status', 'updated_at as activity_at']),
            'purchases',
            'Approved purchase order',
            fn ($row) => "{$row->number} · {$row->status}",
            'activity_at'
        );

        $this->append(
            $activities,
            'purchase-received',
            DB::table('purchase_receipts')
                ->where('received_by', $user->id)
                ->orderByDesc('created_at')
                ->limit(30)
                ->get(['id', 'grn_number', 'created_at']),
            'purchases',
            'Received purchase delivery',
            fn ($row) => $row->grn_number
        );

        $this->append(
            $activities,
            'transfer-requested',
            DB::table('transfers')
                ->where('requested_by', $user->id)
                ->orderByDesc('created_at')
                ->limit(30)
                ->get(['id', 'transfer_number', 'status', 'created_at']),
            'transfers',
            'Requested stock transfer',
            fn ($row) => "{$row->transfer_number} · {$row->status}"
        );

        $this->append(
            $activities,
            'transfer-approved',
            DB::table('transfers')
                ->where('approved_by', $user->id)
                ->whereNotNull('approved_date')
                ->orderByDesc('approved_date')
                ->limit(30)
                ->get(['id', 'transfer_number', 'status', 'approved_date as activity_at']),
            'transfers',
            'Approved stock transfer',
            fn ($row) => "{$row->transfer_number} · {$row->status}",
            'activity_at'
        );

        $this->append(
            $activities,
            'transfer-shipped',
            DB::table('transfers')
                ->where('shipped_by', $user->id)
                ->whereNotNull('shipped_date')
                ->orderByDesc('shipped_date')
                ->limit(30)
                ->get(['id', 'transfer_number', 'status', 'shipped_date as activity_at']),
            'transfers',
            'Shipped stock transfer',
            fn ($row) => "{$row->transfer_number} · {$row->status}",
            'activity_at'
        );

        $this->append(
            $activities,
            'transfer-received',
            DB::table('transfers')
                ->where('received_by', $user->id)
                ->whereNotNull('received_date')
                ->orderByDesc('received_date')
                ->limit(30)
                ->get(['id', 'transfer_number', 'status', 'received_date as activity_at']),
            'transfers',
            'Received stock transfer',
            fn ($row) => "{$row->transfer_number} · {$row->status}",
            'activity_at'
        );

        $this->append(
            $activities,
            'kitchen-issue-requested',
            DB::table('kitchen_issues')
                ->where('requested_by', $user->id)
                ->orderByDesc('created_at')
                ->limit(30)
                ->get(['id', 'number', 'status', 'created_at']),
            'kitchen',
            'Requested kitchen issue',
            fn ($row) => "{$row->number} · {$row->status}"
        );

        $this->append(
            $activities,
            'kitchen-issue-approved',
            DB::table('kitchen_issues')
                ->where('approved_by', $user->id)
                ->whereNotNull('approved_at')
                ->orderByDesc('approved_at')
                ->limit(30)
                ->get(['id', 'number', 'status', 'approved_at as activity_at']),
            'kitchen',
            'Approved kitchen issue',
            fn ($row) => "{$row->number} · {$row->status}",
            'activity_at'
        );

        $this->append(
            $activities,
            'kitchen-issue-issued',
            DB::table('kitchen_issues')
                ->where('issued_by', $user->id)
                ->whereNotNull('issued_at')
                ->orderByDesc('issued_at')
                ->limit(30)
                ->get(['id', 'number', 'status', 'issued_at as activity_at']),
            'kitchen',
            'Issued kitchen stock',
            fn ($row) => "{$row->number} · {$row->status}",
            'activity_at'
        );

        $this->append(
            $activities,
            'waste-recorded',
            DB::table('waste_records')
                ->leftJoin('items', 'items.id', '=', 'waste_records.item_id')
                ->where('waste_records.created_by', $user->id)
                ->orderByDesc('waste_records.created_at')
                ->limit(30)
                ->get([
                    'waste_records.id',
                    'waste_records.number',
                    'items.name as item_name',
                    'waste_records.created_at',
                ]),
            'waste',
            'Recorded waste',
            fn ($row) => $this->joinDetails($row->number, $row->item_name)
        );

        $this->append(
            $activities,
            'inventory-batch-created',
            DB::table('inventory_batches')
                ->leftJoin('items', 'items.id', '=', 'inventory_batches.item_id')
                ->where('inventory_batches.created_by', $user->id)
                ->orderByDesc('inventory_batches.created_at')
                ->limit(30)
                ->get([
                    'inventory_batches.id',
                    'inventory_batches.lot_number',
                    'items.name as item_name',
                    'inventory_batches.created_at',
                ]),
            'inventory',
            'Created inventory batch',
            fn ($row) => $this->joinDetails($row->item_name, $row->lot_number)
        );

        $this->append(
            $activities,
            'production-run-created',
            DB::table('production_runs')
                ->leftJoin('recipes', 'recipes.id', '=', 'production_runs.recipe_id')
                ->where('production_runs.created_by', $user->id)
                ->orderByDesc('production_runs.created_at')
                ->limit(30)
                ->get([
                    'production_runs.id',
                    'recipes.name as recipe_name',
                    'production_runs.produced_servings',
                    'production_runs.created_at',
                ]),
            'production',
            'Recorded production',
            fn ($row) => trim("{$row->recipe_name} · {$row->produced_servings} servings", ' ·')
        );

        $this->append(
            $activities,
            'recipe-created',
            DB::table('recipes')
                ->where('created_by', $user->id)
                ->orderByDesc('created_at')
                ->limit(30)
                ->get(['id', 'name', 'created_at']),
            'production',
            'Created recipe',
            fn ($row) => $row->name
        );

        $this->append(
            $activities,
            'purchase-return-created',
            DB::table('purchase_returns')
                ->where('created_by', $user->id)
                ->orderByDesc('created_at')
                ->limit(30)
                ->get(['id', 'number', 'status', 'created_at']),
            'purchases',
            'Created purchase return',
            fn ($row) => "{$row->number} · {$row->status}"
        );

        $this->append(
            $activities,
            'purchase-return-reviewed',
            DB::table('purchase_returns')
                ->where('reviewed_by', $user->id)
                ->whereNotNull('reviewed_at')
                ->orderByDesc('reviewed_at')
                ->limit(30)
                ->get(['id', 'number', 'status', 'reviewed_at as activity_at']),
            'purchases',
            'Reviewed purchase return',
            fn ($row) => "{$row->number} · {$row->status}",
            'activity_at'
        );

        return $this->success([
            'activities' => $activities
                ->sortByDesc('occurred_at')
                ->take(30)
                ->values(),
        ]);
    }

    private function append(
        Collection $activities,
        string $source,
        iterable $records,
        string $category,
        string $title,
        callable $description,
        string $timeField = 'created_at'
    ): void {
        foreach ($records as $record) {
            $timestamp = $record->{$timeField} ?? null;
            if (!$timestamp) {
                continue;
            }

            $activities->push([
                'id' => "{$source}:{$record->id}",
                'title' => $title,
                'description' => $description($record),
                'category' => $category,
                'occurred_at' => Carbon::parse($timestamp)->toIso8601String(),
            ]);
        }
    }

    private function joinDetails(...$parts): string
    {
        return implode(' · ', array_values(array_filter(
            $parts,
            fn ($part) => $part !== null && $part !== ''
        )));
    }
}
