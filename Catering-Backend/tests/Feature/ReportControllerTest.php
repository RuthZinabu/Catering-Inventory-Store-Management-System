<?php

namespace Tests\Feature;

use App\Enums\ItemType;
use App\Enums\MovementType;
use App\Enums\StockStatus;
use App\Models\Item;
use App\Models\KitchenIssue;
use App\Models\KitchenIssueItem;
use App\Models\PurchaseOrder;
use App\Models\PurchaseOrderItem;
use App\Models\StockMovement;
use App\Models\Store;
use App\Models\StoreStock;
use App\Models\Supplier;
use App\Models\User;
use App\Models\WasteRecord;
use Illuminate\Support\Str;
use Tests\TestCase;

class ReportControllerTest extends TestCase
{
    public function test_overview_aggregates_stock_and_restricts_the_report_to_assigned_stores(): void
    {
        [$user, $store, $item] = $this->createContext('overview');
        $otherStore = Store::create([
            'name' => 'Other Store',
            'code' => 'REPORT-OTHER',
            'store_type' => Store::TYPE_GENERAL,
        ]);
        $user->stores()->attach($store->id, ['id' => (string) Str::uuid(), 'role_in_store' => 'storekeeper']);

        StoreStock::create([
            'item_id' => $item->id,
            'store_id' => $store->id,
            'quantity' => 3,
            'min_quantity' => 5,
            'current_cost' => 12,
            'status' => StockStatus::LOW_STOCK,
        ]);
        StoreStock::create([
            'item_id' => $item->id,
            'store_id' => $otherStore->id,
            'quantity' => 90,
            'min_quantity' => 5,
            'current_cost' => 100,
            'status' => StockStatus::HEALTHY,
        ]);
        $supplier = Supplier::create([
            'name' => 'Apex Supplies',
            'company' => 'Apex Supplies Ltd',
        ]);
        $order = PurchaseOrder::create([
            'number' => 'REPORT-PO-001',
            'supplier_id' => $supplier->id,
            'destination_store_id' => $store->id,
            'created_by' => $user->id,
            'order_date' => now()->toDateString(),
            'expected_delivery_date' => now()->toDateString(),
            'status' => 'Received',
            'payment_status' => 'Paid',
            'subtotal' => 240,
            'total_amount' => 240,
            'received_at' => now(),
        ]);
        PurchaseOrderItem::create([
            'purchase_order_id' => $order->id,
            'item_id' => $item->id,
            'quantity' => 12,
            'unit' => 'kg',
            'unit_price' => 20,
            'line_total' => 240,
        ]);
        StockMovement::create([
            'item_id' => $item->id,
            'store_id' => $store->id,
            'type' => MovementType::STOCK_IN,
            'quantity' => 3,
            'unit' => 'kg',
            'quantity_before' => 0,
            'quantity_after' => 3,
            'performed_by' => $user->id,
        ]);

        $this->actingAs($user, 'sanctum')
            ->getJson('/api/reports/overview?period=daily')
            ->assertOk()
            ->assertJsonPath('data.kpis.total_items', 1)
            ->assertJsonPath('data.reports.current_stock.low_stock_items', 1)
            ->assertJsonPath('data.reports.inventory_valuation.total_value', 36)
            ->assertJsonPath('data.reports.stock_movement.inbound_quantity', 3)
            ->assertJsonPath('data.reports.purchases.items_ordered', 12)
            ->assertJsonPath('data.reports.purchases.total_spent', 240)
            ->assertJsonPath('data.reports.suppliers.top_suppliers.0.name', 'Apex Supplies')
            ->assertJsonPath('data.reports.suppliers.on_time_delivery_percent', 100);

        $this->getJson('/api/reports/stock/current?per_page=10')
            ->assertOk()
            ->assertJsonPath('data.pagination.total', 1);
        $this->getJson('/api/reports/stock/low-stock?per_page=10')
            ->assertOk()
            ->assertJsonPath('data.pagination.total', 1);

        $this->getJson('/api/reports/overview?store_id='.$otherStore->id)
            ->assertForbidden();
    }

    public function test_consumption_report_uses_issued_kitchen_quantities_and_confirmed_waste(): void
    {
        [$user, $store, $item] = $this->createContext('consumption');
        $user->stores()->attach($store->id, ['id' => (string) Str::uuid(), 'role_in_store' => 'storekeeper']);
        StoreStock::create([
            'item_id' => $item->id,
            'store_id' => $store->id,
            'quantity' => 20,
            'min_quantity' => 2,
            'current_cost' => 2.5,
            'status' => StockStatus::HEALTHY,
        ]);
        $issue = KitchenIssue::create([
            'number' => 'REPORT-ISSUE-001',
            'store_id' => $store->id,
            'department' => 'Kitchen',
            'kitchen' => 'Main Kitchen',
            'requested_by' => $user->id,
            'issued_by' => $user->id,
            'requested_date' => now()->toDateString(),
            'status' => 'Issued',
            'issued_at' => now(),
        ]);
        KitchenIssueItem::create([
            'kitchen_issue_id' => $issue->id,
            'item_id' => $item->id,
            'quantity_requested' => 9,
            'quantity_issued' => 10,
            'unit' => $item->unit,
        ]);
        WasteRecord::create([
            'number' => 'REPORT-WASTE-001',
            'item_id' => $item->id,
            'item' => $item->name,
            'category' => $item->category,
            'unit' => $item->unit,
            'quantity' => 2,
            'estimated_cost' => 5,
            'reason' => 'Spoilage',
            'recorded_by' => $user->name,
            'date' => now(),
            'status' => 'Confirmed',
            'store_id' => $store->id,
            'created_by' => $user->id,
        ]);

        $this->actingAs($user, 'sanctum')
            ->getJson('/api/reports/consumption?period=daily')
            ->assertOk()
            ->assertJsonPath('data.items.0.actual_quantity', 10)
            ->assertJsonPath('data.items.0.planned_quantity', 9)
            ->assertJsonPath('data.items.0.wastage_quantity', 2)
            ->assertJsonPath('data.items.0.variance_cost', 2.5)
            ->assertJsonPath('data.summary.theoretical_data_available', false);
    }

    private function createContext(string $suffix): array
    {
        $user = User::create([
            'name' => 'Report User',
            'email' => "report-{$suffix}@example.test",
            'password' => 'test-password',
            'role' => User::ROLE_STOREKEEPER,
            'permissions' => ['reports.view'],
        ]);
        $store = Store::create([
            'name' => 'Report Store',
            'code' => "REPORT-STORE-{$suffix}",
            'store_type' => Store::TYPE_GENERAL,
        ]);
        $item = Item::create([
            'code' => "REPORT-ITEM-{$suffix}",
            'name' => 'Rice',
            'category' => 'Grains',
            'item_type' => ItemType::FOOD,
            'unit' => 'kg',
            'default_purchase_price' => 3,
            'created_by' => $user->id,
        ]);

        return [$user, $store, $item];
    }
}
