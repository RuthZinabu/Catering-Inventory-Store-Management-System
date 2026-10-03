<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\Store;
use App\Models\Item;
use App\Models\StoreStock;
use App\Enums\StockStatus;

class StockSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $store = Store::first();
        $item = Item::first();
        
        if ($store && $item) {
            StoreStock::create([
                'item_id' => $item->id,
                'store_id' => $store->id,
                'quantity' => 50.0,
                'reserved_quantity' => 0.0,
                'min_quantity' => 10.0,
                'max_quantity' => 100.0,
                'reorder_point' => 20.0,
                'current_cost' => 280.00,
                'last_cost' => 275.00,
                'status' => StockStatus::HEALTHY,
                'location_code' => 'A-001',
                'location_description' => 'Main Storage Area',
            ]);
            
            $this->command->info('Sample stock data created successfully');
        } else {
            $this->command->warn('No store or item found to create stock data');
        }
    }
}