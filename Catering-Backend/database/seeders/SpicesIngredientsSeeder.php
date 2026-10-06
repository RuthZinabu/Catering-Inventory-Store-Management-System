<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Carbon\Carbon;

class SpicesIngredientsSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Find or create the "Food Stock" store
        $store = DB::table('stores')->where('store_type', 'food')->first();
        
        if (!$store) {
            $storeId = Str::uuid()->toString();
            DB::table('stores')->insert([
                'id' => $storeId,
                'code' => 'FOOD-001',
                'name' => 'Food Stock',
                'location' => 'Main Food Storage',
                'store_type' => 'food',
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

        // Spices and Ingredients inventory data with realistic quantities
        $inventoryData = [
            [
                'ተ.ቁ' => 1,
                'amharic_name' => 'ከኖረ',
                'english_name' => 'Knorr',
                'description' => 'Bouillon/seasoning cube',
                'quantity' => 150,
                'unit' => 'box',
                'shelf_life_days' => 730,
                'requires_refrigeration' => false,
                'min_quantity' => 20,
                'reorder_point' => 30,
            ],
            [
                'ተ.ቁ' => 2,
                'amharic_name' => 'እርድ',
                'english_name' => 'Turmeric',
                'description' => 'Ground turmeric powder',
                'quantity' => 25,
                'unit' => 'kg',
                'shelf_life_days' => 365,
                'requires_refrigeration' => false,
                'min_quantity' => 5,
                'reorder_point' => 8,
            ],
            [
                'ተ.ቁ' => 3,
                'amharic_name' => 'ኮረሪማ',
                'english_name' => 'Korerima',
                'description' => 'Ethiopian Cardamom (Black Cardamom)',
                'quantity' => 15,
                'unit' => 'kg',
                'shelf_life_days' => 365,
                'requires_refrigeration' => false,
                'min_quantity' => 3,
                'reorder_point' => 5,
            ],
            [
                'ተ.ቁ' => 4,
                'amharic_name' => 'ከሙን',
                'english_name' => 'Cumin',
                'description' => 'Ground cumin powder',
                'quantity' => 20,
                'unit' => 'kg',
                'shelf_life_days' => 365,
                'requires_refrigeration' => false,
                'min_quantity' => 4,
                'reorder_point' => 6,
            ],
            [
                'ተ.ቁ' => 5,
                'amharic_name' => 'መከለሻ',
                'english_name' => 'Mekelesha',
                'description' => 'Traditional finishing spice blend combo',
                'quantity' => 30,
                'unit' => 'kg',
                'shelf_life_days' => 180,
                'requires_refrigeration' => false,
                'min_quantity' => 5,
                'reorder_point' => 10,
            ],
            [
                'ተ.ቁ' => 6,
                'amharic_name' => 'በርበሬ',
                'english_name' => 'Berbere',
                'description' => 'Ethiopian hot pepper spice blend',
                'quantity' => 50,
                'unit' => 'kg',
                'shelf_life_days' => 180,
                'requires_refrigeration' => false,
                'min_quantity' => 10,
                'reorder_point' => 15,
            ],
            [
                'ተ.ቁ' => 7,
                'amharic_name' => 'ቀረፋ',
                'english_name' => 'Cinnamon',
                'description' => 'Ground cinnamon powder',
                'quantity' => 12,
                'unit' => 'kg',
                'shelf_life_days' => 365,
                'requires_refrigeration' => false,
                'min_quantity' => 2,
                'reorder_point' => 4,
            ],
            [
                'ተ.ቁ' => 8,
                'amharic_name' => 'ህል',
                'english_name' => 'Cardamom',
                'description' => 'Green cardamom pods',
                'quantity' => 8,
                'unit' => 'kg',
                'shelf_life_days' => 365,
                'requires_refrigeration' => false,
                'min_quantity' => 2,
                'reorder_point' => 3,
            ],
            [
                'ተ.ቁ' => 9,
                'amharic_name' => 'ሽንኩርት',
                'english_name' => 'Onion',
                'description' => 'Fresh onions',
                'quantity' => 200,
                'unit' => 'kg',
                'shelf_life_days' => 30,
                'requires_refrigeration' => false,
                'min_quantity' => 30,
                'reorder_point' => 50,
            ],
            [
                'ተ.ቁ' => 10,
                'amharic_name' => 'ነጭ አዝሙድ',
                'english_name' => 'White Cumin',
                'description' => 'Bishop\'s weed (Ajwain)',
                'quantity' => 10,
                'unit' => 'kg',
                'shelf_life_days' => 365,
                'requires_refrigeration' => false,
                'min_quantity' => 2,
                'reorder_point' => 3,
            ],
            [
                'ተ.ቁ' => 11,
                'amharic_name' => 'ጥቁር አዝሙድ',
                'english_name' => 'Black Cumin',
                'description' => 'Nigella sativa',
                'quantity' => 10,
                'unit' => 'kg',
                'shelf_life_days' => 365,
                'requires_refrigeration' => false,
                'min_quantity' => 2,
                'reorder_point' => 3,
            ],
            [
                'ተ.ቁ' => 12,
                'amharic_name' => 'ቅርንፉድ',
                'english_name' => 'Cloves',
                'description' => 'Whole cloves',
                'quantity' => 5,
                'unit' => 'kg',
                'shelf_life_days' => 730,
                'requires_refrigeration' => false,
                'min_quantity' => 1,
                'reorder_point' => 2,
            ],
            [
                'ተ.ቁ' => 13,
                'amharic_name' => 'የድንብላል ፍሬ',
                'english_name' => 'Coriander Seeds',
                'description' => 'Whole coriander seeds',
                'quantity' => 15,
                'unit' => 'kg',
                'shelf_life_days' => 365,
                'requires_refrigeration' => false,
                'min_quantity' => 3,
                'reorder_point' => 5,
            ],
            [
                'ተ.ቁ' => 14,
                'amharic_name' => 'ጦስኝ',
                'english_name' => 'Thyme',
                'description' => 'Dried thyme',
                'quantity' => 8,
                'unit' => 'kg',
                'shelf_life_days' => 365,
                'requires_refrigeration' => false,
                'min_quantity' => 2,
                'reorder_point' => 3,
            ],
            [
                'ተ.ቁ' => 15,
                'amharic_name' => 'ሚጥሚጣ',
                'english_name' => 'Mitmita',
                'description' => 'Very hot orange-red spiced chili powder blend',
                'quantity' => 25,
                'unit' => 'kg',
                'shelf_life_days' => 180,
                'requires_refrigeration' => false,
                'min_quantity' => 5,
                'reorder_point' => 8,
            ],
            [
                'ተ.ቁ' => 16,
                'amharic_name' => 'አቼቶ',
                'english_name' => 'Vinegar',
                'description' => 'White vinegar',
                'quantity' => 40,
                'unit' => 'liter',
                'shelf_life_days' => 730,
                'requires_refrigeration' => false,
                'min_quantity' => 10,
                'reorder_point' => 15,
            ],
            [
                'ተ.ቁ' => 17,
                'amharic_name' => 'ቀይ የሩዝ ከለር',
                'english_name' => 'Red Rice Color',
                'description' => 'Red food coloring for rice',
                'quantity' => 20,
                'unit' => 'bottle',
                'shelf_life_days' => 730,
                'requires_refrigeration' => false,
                'min_quantity' => 5,
                'reorder_point' => 8,
            ],
            [
                'ተ.ቁ' => 18,
                'amharic_name' => 'ቢጫ የሩዝ ከለር',
                'english_name' => 'Yellow Rice Color',
                'description' => 'Yellow food coloring for rice',
                'quantity' => 20,
                'unit' => 'bottle',
                'shelf_life_days' => 730,
                'requires_refrigeration' => false,
                'min_quantity' => 5,
                'reorder_point' => 8,
            ],
            [
                'ተ.ቁ' => 19,
                'amharic_name' => 'አረንጓዴ የሩዝ ከለር',
                'english_name' => 'Green Rice Color',
                'description' => 'Green food coloring for rice',
                'quantity' => 20,
                'unit' => 'bottle',
                'shelf_life_days' => 730,
                'requires_refrigeration' => false,
                'min_quantity' => 5,
                'reorder_point' => 8,
            ],
            [
                'ተ.ቁ' => 20,
                'amharic_name' => 'ቁንዶ በርበሬ',
                'english_name' => 'Black Pepper',
                'description' => 'Whole or ground black pepper',
                'quantity' => 18,
                'unit' => 'kg',
                'shelf_life_days' => 365,
                'requires_refrigeration' => false,
                'min_quantity' => 3,
                'reorder_point' => 5,
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
            $shelfLifeDays = $data['shelf_life_days'];
            $requiresRefrigeration = $data['requires_refrigeration'];
            $minQuantity = $data['min_quantity'];
            $reorderPoint = $data['reorder_point'];
            
            // Generate item code
            $itemCode = 'SPICE-' . str_pad($data['ተ.ቁ'], 4, '0', STR_PAD_LEFT);
            
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
                    'category' => 'Spices/Ingredients',
                    'item_type' => 'food',
                    'unit' => $unit,
                    'shelf_life_days' => $shelfLifeDays,
                    'requires_refrigeration' => $requiresRefrigeration,
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
        $this->command->info("- $itemsInserted new spices/ingredients items");
        $this->command->info("- $stockInserted stock records");
        $this->command->info("Category: Spices/Ingredients");
        $this->command->info("Store: {$storeData->name} (ID: {$store->id})");
    }
}
