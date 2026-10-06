<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Carbon\Carbon;

class ElectronicsInventorySeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Find or create the "Electronics" store
        $store = DB::table('stores')->where('name', 'Electronics')->first();
        
        if (!$store) {
            $storeId = Str::uuid()->toString();
            DB::table('stores')->insert([
                'id' => $storeId,
                'code' => 'ELEC-001',
                'name' => 'Electronics',
                'location' => 'Electronics Section',
                'store_type' => 'electronics',
                'manager_name' => 'System',
                'is_active' => true,
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ]);
            $store = (object)['id' => $storeId];
        }

        // Get the first admin user as creator
        $creator = DB::table('users')->where('role', 'admin')->first();
        if (!$creator) {
            $creator = DB::table('users')->first();
        }
        
        if (!$creator) {
            $this->command->error('No users found. Please create a user first.');
            return;
        }

        $creatorId = $creator->id;
        $now = Carbon::now();

        // Electronics inventory data
        $inventoryData = [
            ['ተ.ቁ' => 1, 'የእቃው አይነት' => 'የሲሊንደር ምድጃ', 'ብዛት' => 1],
            ['ተ.ቁ' => 2, 'የእቃው አይነት' => 'የኤሌክትሪክ ድስት ትልቁ', 'ብዛት' => 3],
            ['ተ.ቁ' => 3, 'የእቃው አይነት' => 'የኤሌክትሪክ ድስት ትልቁ(የሩዝ)', 'ብዛት' => 4],
            ['ተ.ቁ' => 4, 'የእቃው አይነት' => 'ዲፕ ፍሪጅ', 'ብዛት' => 2],
            ['ተ.ቁ' => 5, 'የእቃው አይነት' => 'ስቶቭ', 'ብዛት' => 1],
            ['ተ.ቁ' => 6, 'የእቃው አይነት' => 'ሆቭን', 'ብዛት' => 3],
            ['ተ.ቁ' => 7, 'የእቃው አይነት' => 'ቶስተር', 'ብዛት' => 1],
            ['ተ.ቁ' => 8, 'የእቃው አይነት' => 'ላይት', 'ብዛት' => 15],
            ['ተ.ቁ' => 9, 'የእቃው አይነት' => 'የግሪል ማሽን', 'ብዛት' => 3],
            ['ተ.ቁ' => 10, 'የእቃው አይነት' => 'የኤልክትሪክ ድሰት', 'ብዛት' => 5],
            ['ተ.ቁ' => 11, 'የእቃው አይነት' => 'ፍሪጅ', 'ብዛት' => 7],
            ['ተ.ቁ' => 12, 'የእቃው አይነት' => 'የእንጀራ ምጣድ', 'ብዛት' => 3],
            ['ተ.ቁ' => 13, 'የእቃው አይነት' => 'የሸንኩርት መፍጫ', 'ብዛት' => 1],
            ['ተ.ቁ' => 14, 'የእቃው አይነት' => 'ስቶቭ ትንሹ', 'ብዛት' => 1],
            ['ተ.ቁ' => 15, 'የእቃው አይነት' => 'የችበስ መጥበሻ', 'ብዛት' => 1],
        ];

        $itemsInserted = 0;
        $stockInserted = 0;

        foreach ($inventoryData as $data) {
            $itemName = $data['የእቃው አይነት'];
            $quantity = (int)$data['ብዛት'];
            
            // Generate item code
            $itemCode = 'ELEC-' . str_pad($data['ተ.ቁ'], 4, '0', STR_PAD_LEFT);
            
            // Check if item already exists
            $existingItem = DB::table('items')->where('code', $itemCode)->first();
            
            if (!$existingItem) {
                // Create new item
                $itemId = Str::uuid()->toString();
                
                // Determine category based on item name
                $category = $this->categorizeElectronics($itemName);
                
                DB::table('items')->insert([
                    'id' => $itemId,
                    'code' => $itemCode,
                    'name' => $itemName,
                    'description' => 'Electronic equipment for kitchen operations',
                    'category' => $category,
                    'item_type' => 'electronics',
                    'unit' => 'piece',
                    'warranty_period_months' => 12, // Default 1 year warranty
                    'is_active' => true,
                    'created_by' => $creatorId,
                    'created_at' => $now,
                    'updated_at' => $now,
                ]);
                
                $itemsInserted++;
            } else {
                $itemId = $existingItem->id;
            }
            
            // Check if stock record exists for this item in this store
            $existingStock = DB::table('store_stock')
                ->where('item_id', $itemId)
                ->where('store_id', $store->id)
                ->first();
            
            if (!$existingStock) {
                // Create new stock record
                DB::table('store_stock')->insert([
                    'id' => Str::uuid()->toString(),
                    'item_id' => $itemId,
                    'store_id' => $store->id,
                    'quantity' => $quantity,
                    'reserved_quantity' => 0,
                    'min_quantity' => 1,
                    'max_quantity' => max($quantity * 2, 5), // Set max to 2x or minimum 5
                    'reorder_point' => max(1, floor($quantity * 0.3)), // 30% of quantity
                    'status' => $quantity > 0 ? 'Healthy' : 'Out of Stock',
                    'created_at' => $now,
                    'updated_at' => $now,
                ]);
                
                $stockInserted++;
            } else {
                // Update existing stock
                DB::table('store_stock')
                    ->where('id', $existingStock->id)
                    ->update([
                        'quantity' => $existingStock->quantity + $quantity,
                        'status' => ($existingStock->quantity + $quantity) > 0 ? 'Healthy' : 'Out of Stock',
                        'updated_at' => $now,
                    ]);
                
                $stockInserted++;
            }
        }

        // Refresh store data to get name
        $storeData = DB::table('stores')->where('id', $store->id)->first();
        
        $this->command->info("Successfully inserted:");
        $this->command->info("- $itemsInserted new electronic items");
        $this->command->info("- $stockInserted stock records");
        $this->command->info("Store: {$storeData->name} (ID: {$store->id})");
    }

    /**
     * Categorize electronics based on item name
     */
    private function categorizeElectronics(string $itemName): string
    {
        $lowerName = strtolower($itemName);
        
        if (str_contains($lowerName, 'ፍሪጅ') || str_contains($lowerName, 'fridge')) {
            return 'Refrigeration';
        }
        
        if (str_contains($lowerName, 'ስቶቭ') || str_contains($lowerName, 'ሆቭን') || 
            str_contains($lowerName, 'stove') || str_contains($lowerName, 'oven')) {
            return 'Cooking Appliances';
        }
        
        if (str_contains($lowerName, 'ድስት') || str_contains($lowerName, 'pot')) {
            return 'Electric Cookware';
        }
        
        if (str_contains($lowerName, 'ማሽን') || str_contains($lowerName, 'machine') || 
            str_contains($lowerName, 'መፍጫ') || str_contains($lowerName, 'grinder')) {
            return 'Food Processing';
        }
        
        if (str_contains($lowerName, 'ላይት') || str_contains($lowerName, 'light')) {
            return 'Lighting';
        }
        
        if (str_contains($lowerName, 'ቶስተር') || str_contains($lowerName, 'toaster') ||
            str_contains($lowerName, 'ምጣድ') || str_contains($lowerName, 'መጥበሻ')) {
            return 'Small Appliances';
        }
        
        if (str_contains($lowerName, 'ሲሊንደር') || str_contains($lowerName, 'cylinder')) {
            return 'Gas Equipment';
        }
        
        return 'Kitchen Electronics';
    }
}
