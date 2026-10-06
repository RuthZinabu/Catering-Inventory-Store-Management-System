<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Carbon\Carbon;

class CateringTemporaryCleaningSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Find or create the "Catering Temporary" store
        $store = DB::table('stores')->where('name', 'Catering Temporary')->first();
        
        if (!$store) {
            $storeId = Str::uuid()->toString();
            DB::table('stores')->insert([
                'id' => $storeId,
                'code' => 'CAT-TEMP',
                'name' => 'Catering Temporary',
                'location' => 'Temporary Catering Section',
                'store_type' => 'catering',
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

        // Cleaning items inventory data
        $inventoryData = [
            [
                'ተ.ቁ' => 1,
                'amharic_name' => 'የእቃ ሸቦ',
                'english_name' => 'Steel Wool',
                'description' => 'Metal pot scourer for heavy duty cleaning',
                'quantity' => 150,
                'unit' => 'piece',
                'min_quantity' => 30,
                'reorder_point' => 50,
            ],
            [
                'ተ.ቁ' => 2,
                'amharic_name' => 'ስፖንጅ',
                'english_name' => 'Sponge',
                'description' => 'Cleaning sponge for general dishwashing',
                'quantity' => 200,
                'unit' => 'piece',
                'min_quantity' => 40,
                'reorder_point' => 60,
            ],
            [
                'ተ.ቁ' => 3,
                'amharic_name' => 'የልብስ ፈሳሽ ሳሙና',
                'english_name' => 'Liquid Laundry Detergent',
                'description' => 'Liquid detergent for washing fabrics',
                'quantity' => 40,
                'unit' => 'liter',
                'min_quantity' => 10,
                'reorder_point' => 15,
            ],
            [
                'ተ.ቁ' => 4,
                'amharic_name' => 'የእቃ ፈሳሽ ሳሙና',
                'english_name' => 'Dish Soap',
                'description' => 'Liquid dishwashing soap',
                'quantity' => 60,
                'unit' => 'liter',
                'min_quantity' => 15,
                'reorder_point' => 20,
            ],
            [
                'ተ.ቁ' => 5,
                'amharic_name' => 'በረኪና',
                'english_name' => 'Bleach',
                'description' => 'Chlorine bleach for sanitization and whitening',
                'quantity' => 30,
                'unit' => 'liter',
                'min_quantity' => 8,
                'reorder_point' => 12,
            ],
            [
                'ተ.ቁ' => 6,
                'amharic_name' => 'መጥረጊያ',
                'english_name' => 'Broom',
                'description' => 'Floor broom for sweeping',
                'quantity' => 15,
                'unit' => 'piece',
                'min_quantity' => 3,
                'reorder_point' => 5,
            ],
            [
                'ተ.ቁ' => 7,
                'amharic_name' => 'መውለወያ',
                'english_name' => 'Mop',
                'description' => 'Floor mop for wet cleaning',
                'quantity' => 12,
                'unit' => 'piece',
                'min_quantity' => 3,
                'reorder_point' => 5,
            ],
            [
                'ተ.ቁ' => 8,
                'amharic_name' => 'ፎጣ',
                'english_name' => 'Towel',
                'description' => 'Cleaning cloth/towel for wiping',
                'quantity' => 100,
                'unit' => 'piece',
                'min_quantity' => 20,
                'reorder_point' => 30,
            ],
            [
                'ተ.ቁ' => 9,
                'amharic_name' => 'ዲቶል',
                'english_name' => 'Dettol',
                'description' => 'Antiseptic disinfectant liquid',
                'quantity' => 25,
                'unit' => 'bottle',
                'min_quantity' => 5,
                'reorder_point' => 10,
            ],
            [
                'ተ.ቁ' => 10,
                'amharic_name' => 'የገላ ሳሙና',
                'english_name' => 'Body Soap',
                'description' => 'Bath soap bars',
                'quantity' => 80,
                'unit' => 'piece',
                'min_quantity' => 15,
                'reorder_point' => 25,
            ],
            [
                'ተ.ቁ' => 11,
                'amharic_name' => 'የእጅ መታጠቢያ ፈሳሽ ሳሙና',
                'english_name' => 'Liquid Hand Soap',
                'description' => 'Liquid hand wash soap',
                'quantity' => 50,
                'unit' => 'bottle',
                'min_quantity' => 10,
                'reorder_point' => 15,
            ],
        ];

        $itemsInserted = 0;
        $stockInserted = 0;

        foreach ($inventoryData as $data) {
            $itemNameAmharic = $data['amharic_name'];
            $itemNameEnglish = $data['english_name'];
            $fullName = "$itemNameAmharic ($itemNameEnglish)";
            $description = $data['description'];
            $quantity = $data['quantity'];
            $unit = $data['unit'];
            $minQuantity = $data['min_quantity'];
            $reorderPoint = $data['reorder_point'];
            
            // Generate item code
            $itemCode = 'CLEAN-TEMP-' . str_pad($data['ተ.ቁ'], 3, '0', STR_PAD_LEFT);
            
            // Check if item already exists
            $existingItem = DB::table('items')->where('code', $itemCode)->first();
            
            if (!$existingItem) {
                // Create new item
                $itemId = Str::uuid()->toString();
                
                DB::table('items')->insert([
                    'id' => $itemId,
                    'code' => $itemCode,
                    'name' => $fullName,
                    'description' => $description,
                    'category' => 'Cleaning Supplies',
                    'item_type' => 'catering',
                    'unit' => $unit,
                    'catering_subtype' => 'temporary',
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
                // Determine stock status
                $status = 'Healthy';
                if ($quantity == 0) {
                    $status = 'Out of Stock';
                } elseif ($quantity <= $reorderPoint) {
                    $status = 'Low Stock';
                }
                
                // Create new stock record
                DB::table('store_stock')->insert([
                    'id' => Str::uuid()->toString(),
                    'item_id' => $itemId,
                    'store_id' => $store->id,
                    'quantity' => $quantity,
                    'reserved_quantity' => 0,
                    'min_quantity' => $minQuantity,
                    'max_quantity' => $quantity * 3, // Set max to 3x current quantity
                    'reorder_point' => $reorderPoint,
                    'status' => $status,
                    'created_at' => $now,
                    'updated_at' => $now,
                ]);
                
                $stockInserted++;
            } else {
                // Update existing stock
                $newQuantity = $existingStock->quantity + $quantity;
                $status = 'Healthy';
                if ($newQuantity == 0) {
                    $status = 'Out of Stock';
                } elseif ($newQuantity <= $reorderPoint) {
                    $status = 'Low Stock';
                }
                
                DB::table('store_stock')
                    ->where('id', $existingStock->id)
                    ->update([
                        'quantity' => $newQuantity,
                        'min_quantity' => $minQuantity,
                        'reorder_point' => $reorderPoint,
                        'status' => $status,
                        'updated_at' => $now,
                    ]);
                
                $stockInserted++;
            }
        }

        $storeData = DB::table('stores')->where('id', $store->id)->first();
        
        $this->command->info("Successfully inserted:");
        $this->command->info("- $itemsInserted new cleaning items");
        $this->command->info("- $stockInserted stock records");
        $this->command->info("Category: Cleaning Supplies");
        $this->command->info("Subtype: Temporary Catering");
        $this->command->info("Store: {$storeData->name} (ID: {$store->id})");
    }
}
