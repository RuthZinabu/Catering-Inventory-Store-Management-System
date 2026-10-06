<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Carbon\Carbon;

class FoodStockAdditionalSeeder extends Seeder
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

        // Additional food stock inventory data with categories
        $inventoryData = [
            // Fresh Produce - Vegetables
            ['amharic_name' => 'ድንች', 'english_name' => 'Potatoes', 'category' => 'Fresh Produce - Vegetables', 'quantity' => 150, 'unit' => 'kg', 'shelf_life_days' => 30, 'refrigeration' => false],
            ['amharic_name' => 'ካሮት', 'english_name' => 'Carrots', 'category' => 'Fresh Produce - Vegetables', 'quantity' => 80, 'unit' => 'kg', 'shelf_life_days' => 21, 'refrigeration' => true],
            ['amharic_name' => 'ቲማቲም', 'english_name' => 'Tomatoes', 'category' => 'Fresh Produce - Vegetables', 'quantity' => 100, 'unit' => 'kg', 'shelf_life_days' => 7, 'refrigeration' => false],
            ['amharic_name' => 'ጥቅል ጎመን', 'english_name' => 'Cabbage', 'category' => 'Fresh Produce - Vegetables', 'quantity' => 60, 'unit' => 'kg', 'shelf_life_days' => 14, 'refrigeration' => true],
            ['amharic_name' => 'ባሮ ሽንኩርት', 'english_name' => 'Leeks', 'category' => 'Fresh Produce - Vegetables', 'quantity' => 30, 'unit' => 'kg', 'shelf_life_days' => 10, 'refrigeration' => true],
            ['amharic_name' => 'የፈረንጅ ቃሪያ', 'english_name' => 'Bell Pepper', 'category' => 'Fresh Produce - Vegetables', 'quantity' => 40, 'unit' => 'kg', 'shelf_life_days' => 7, 'refrigeration' => true],
            ['amharic_name' => 'ሰላጣ', 'english_name' => 'Lettuce', 'category' => 'Fresh Produce - Vegetables', 'quantity' => 25, 'unit' => 'kg', 'shelf_life_days' => 5, 'refrigeration' => true],
            ['amharic_name' => 'ዝንጅብል', 'english_name' => 'Ginger', 'category' => 'Fresh Produce - Vegetables', 'quantity' => 20, 'unit' => 'kg', 'shelf_life_days' => 21, 'refrigeration' => false],
            ['amharic_name' => 'ነጭ ሽንኩርት', 'english_name' => 'Garlic', 'category' => 'Fresh Produce - Vegetables', 'quantity' => 35, 'unit' => 'kg', 'shelf_life_days' => 60, 'refrigeration' => false],
            ['amharic_name' => 'ቀይ ሽንኩርት', 'english_name' => 'Red Onion', 'category' => 'Fresh Produce - Vegetables', 'quantity' => 120, 'unit' => 'kg', 'shelf_life_days' => 30, 'refrigeration' => false],
            ['amharic_name' => 'ብሮኮሊ', 'english_name' => 'Broccoli', 'category' => 'Fresh Produce - Vegetables', 'quantity' => 30, 'unit' => 'kg', 'shelf_life_days' => 7, 'refrigeration' => true],
            ['amharic_name' => 'ቃሪያ', 'english_name' => 'Green Chili Pepper', 'category' => 'Fresh Produce - Vegetables', 'quantity' => 25, 'unit' => 'kg', 'shelf_life_days' => 10, 'refrigeration' => true],
            ['amharic_name' => 'አበባ ጎመን', 'english_name' => 'Cauliflower', 'category' => 'Fresh Produce - Vegetables', 'quantity' => 40, 'unit' => 'kg', 'shelf_life_days' => 10, 'refrigeration' => true],
            ['amharic_name' => 'ጎመን', 'english_name' => 'Ethiopian Mustard Greens', 'category' => 'Fresh Produce - Vegetables', 'quantity' => 50, 'unit' => 'kg', 'shelf_life_days' => 5, 'refrigeration' => true],
            ['amharic_name' => 'ደበርጃን', 'english_name' => 'Eggplant', 'category' => 'Fresh Produce - Vegetables', 'quantity' => 35, 'unit' => 'kg', 'shelf_life_days' => 7, 'refrigeration' => true],
            
            // Fresh Herbs
            ['amharic_name' => 'ሮዝመሪ', 'english_name' => 'Rosemary', 'category' => 'Fresh Herbs', 'quantity' => 5, 'unit' => 'kg', 'shelf_life_days' => 7, 'refrigeration' => true],
            ['amharic_name' => 'ናና', 'english_name' => 'Mint', 'category' => 'Fresh Herbs', 'quantity' => 8, 'unit' => 'kg', 'shelf_life_days' => 5, 'refrigeration' => true],
            ['amharic_name' => 'ድንብላል ቅጠል', 'english_name' => 'Coriander Leaves', 'category' => 'Fresh Herbs', 'quantity' => 10, 'unit' => 'kg', 'shelf_life_days' => 5, 'refrigeration' => true],
            
            // Fresh Produce - Fruits
            ['amharic_name' => 'ሎሚ', 'english_name' => 'Lemon', 'category' => 'Fresh Produce - Fruits', 'quantity' => 40, 'unit' => 'kg', 'shelf_life_days' => 21, 'refrigeration' => true],
            ['amharic_name' => 'ሀባብ', 'english_name' => 'Watermelon', 'category' => 'Fresh Produce - Fruits', 'quantity' => 80, 'unit' => 'kg', 'shelf_life_days' => 14, 'refrigeration' => true],
            ['amharic_name' => 'አናናስ', 'english_name' => 'Pineapple', 'category' => 'Fresh Produce - Fruits', 'quantity' => 60, 'unit' => 'kg', 'shelf_life_days' => 7, 'refrigeration' => true],
            ['amharic_name' => 'ስትሮቤሪ', 'english_name' => 'Strawberry', 'category' => 'Fresh Produce - Fruits', 'quantity' => 20, 'unit' => 'kg', 'shelf_life_days' => 3, 'refrigeration' => true],
            ['amharic_name' => 'ማንጎ', 'english_name' => 'Mango', 'category' => 'Fresh Produce - Fruits', 'quantity' => 50, 'unit' => 'kg', 'shelf_life_days' => 7, 'refrigeration' => false],
            ['amharic_name' => 'ሙዝ', 'english_name' => 'Banana', 'category' => 'Fresh Produce - Fruits', 'quantity' => 70, 'unit' => 'kg', 'shelf_life_days' => 7, 'refrigeration' => false],
            ['amharic_name' => 'ወይን', 'english_name' => 'Grapes', 'category' => 'Fresh Produce - Fruits', 'quantity' => 30, 'unit' => 'kg', 'shelf_life_days' => 7, 'refrigeration' => true],
            
            // Dairy & Fats
            ['amharic_name' => 'ቺዝ', 'english_name' => 'Cheese', 'category' => 'Dairy & Fats', 'quantity' => 30, 'unit' => 'kg', 'shelf_life_days' => 30, 'refrigeration' => true],
            ['amharic_name' => 'አቼ ቅቤ', 'english_name' => 'Margarine/Shortening', 'category' => 'Dairy & Fats', 'quantity' => 40, 'unit' => 'kg', 'shelf_life_days' => 180, 'refrigeration' => false],
            
            // Baking & Desserts
            ['amharic_name' => 'ኬክቶ', 'english_name' => 'Cake Topping Mix', 'category' => 'Baking & Desserts', 'quantity' => 50, 'unit' => 'packet', 'shelf_life_days' => 365, 'refrigeration' => false],
            
            // Prepared Foods
            ['amharic_name' => 'ብርገዝ', 'english_name' => 'Burger Patties', 'category' => 'Prepared Foods', 'quantity' => 100, 'unit' => 'piece', 'shelf_life_days' => 90, 'refrigeration' => true],
            
            // Disposables
            ['amharic_name' => 'ጓንት', 'english_name' => 'Gloves', 'category' => 'Disposables', 'quantity' => 500, 'unit' => 'piece', 'shelf_life_days' => 1825, 'refrigeration' => false],
            ['amharic_name' => 'የጁስ ቴካዌ ካፕ', 'english_name' => 'Plastic Juice Cups', 'category' => 'Disposables', 'quantity' => 1000, 'unit' => 'piece', 'shelf_life_days' => 1825, 'refrigeration' => false],
            ['amharic_name' => 'የሻይ ቴካዌ ካፕ', 'english_name' => 'Disposable Tea Cups', 'category' => 'Disposables', 'quantity' => 1000, 'unit' => 'piece', 'shelf_life_days' => 1825, 'refrigeration' => false],
            ['amharic_name' => 'የምግብ ቴካዌ እቃ', 'english_name' => 'Food Takeaway Containers', 'category' => 'Disposables', 'quantity' => 500, 'unit' => 'piece', 'shelf_life_days' => 1825, 'refrigeration' => false],
            
            // Cleaning Supplies
            ['amharic_name' => 'ጥጥ', 'english_name' => 'Cotton Wool', 'category' => 'Cleaning Supplies', 'quantity' => 100, 'unit' => 'pack', 'shelf_life_days' => 1825, 'refrigeration' => false],
            ['amharic_name' => 'አልኮል', 'english_name' => 'Rubbing Alcohol', 'category' => 'Cleaning Supplies', 'quantity' => 50, 'unit' => 'liter', 'shelf_life_days' => 730, 'refrigeration' => false],
            ['amharic_name' => 'ቪንቶ', 'english_name' => 'Vim Cleaning Powder', 'category' => 'Cleaning Supplies', 'quantity' => 80, 'unit' => 'packet', 'shelf_life_days' => 730, 'refrigeration' => false],
            ['amharic_name' => 'ብረት', 'english_name' => 'Steel Wool', 'category' => 'Cleaning Supplies', 'quantity' => 200, 'unit' => 'piece', 'shelf_life_days' => 1825, 'refrigeration' => false],
            
            // Other Ingredients
            ['amharic_name' => 'የበቆሎ ዱቄት', 'english_name' => 'Cornstarch', 'category' => 'Other Ingredients', 'quantity' => 50, 'unit' => 'kg', 'shelf_life_days' => 730, 'refrigeration' => false],
            ['amharic_name' => 'ቆጮ', 'english_name' => 'Kocho', 'category' => 'Other Ingredients', 'quantity' => 30, 'unit' => 'kg', 'shelf_life_days' => 90, 'refrigeration' => false],
            ['amharic_name' => 'ውሃ', 'english_name' => 'Bottled Water', 'category' => 'Other Ingredients', 'quantity' => 500, 'unit' => 'bottle', 'shelf_life_days' => 365, 'refrigeration' => false],
            ['amharic_name' => 'የቻይና ጨው', 'english_name' => 'MSG', 'category' => 'Other Ingredients', 'quantity' => 10, 'unit' => 'kg', 'shelf_life_days' => 730, 'refrigeration' => false],
            ['amharic_name' => 'የጨርቃ ጨርቅ ዘይት', 'english_name' => 'Fabric Oil', 'category' => 'Other Ingredients', 'quantity' => 15, 'unit' => 'liter', 'shelf_life_days' => 730, 'refrigeration' => false],
        ];

        $itemsInserted = 0;
        $stockInserted = 0;
        $categoryCounts = [];

        foreach ($inventoryData as $index => $data) {
            $itemNameAmharic = $data['amharic_name'];
            $itemNameEnglish = $data['english_name'];
            $fullName = "$itemNameAmharic ($itemNameEnglish)";
            $category = $data['category'];
            $quantity = $data['quantity'];
            $unit = $data['unit'];
            $shelfLifeDays = $data['shelf_life_days'];
            $requiresRefrigeration = $data['refrigeration'];
            
            // Track category counts
            if (!isset($categoryCounts[$category])) {
                $categoryCounts[$category] = 0;
            }
            $categoryCounts[$category]++;
            
            // Generate item code based on category
            $categoryCode = $this->getCategoryCode($category);
            $itemCode = $categoryCode . '-' . str_pad($index + 1, 4, '0', STR_PAD_LEFT);
            
            // Calculate reorder point and min quantity
            $reorderPoint = $this->calculateReorderPoint($quantity, $shelfLifeDays);
            $minQuantity = max(1, floor($quantity * 0.15));
            
            // Check if item already exists
            $existingItem = DB::table('items')->where('code', $itemCode)->first();
            
            if (!$existingItem) {
                // Create new item
                $itemId = Str::uuid()->toString();
                
                DB::table('items')->insert([
                    'id' => $itemId,
                    'code' => $itemCode,
                    'name' => $fullName,
                    'description' => $itemNameEnglish,
                    'category' => $category,
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
            
            // Check if stock record exists
            $existingStock = DB::table('store_stock')
                ->where('item_id', $itemId)
                ->where('store_id', $store->id)
                ->first();
            
            if (!$existingStock) {
                // Determine stock status
                $status = $this->determineStockStatus($quantity, $reorderPoint);
                
                // Create new stock record
                DB::table('store_stock')->insert([
                    'id' => Str::uuid()->toString(),
                    'item_id' => $itemId,
                    'store_id' => $store->id,
                    'quantity' => $quantity,
                    'reserved_quantity' => 0,
                    'min_quantity' => $minQuantity,
                    'max_quantity' => $quantity * 2.5,
                    'reorder_point' => $reorderPoint,
                    'status' => $status,
                    'created_at' => $now,
                    'updated_at' => $now,
                ]);
                
                $stockInserted++;
            } else {
                // Update existing stock
                $newQuantity = $existingStock->quantity + $quantity;
                $status = $this->determineStockStatus($newQuantity, $reorderPoint);
                
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
        $this->command->info("- $itemsInserted new items");
        $this->command->info("- $stockInserted stock records");
        $this->command->info("\nItems by Category:");
        foreach ($categoryCounts as $cat => $count) {
            $this->command->info("  • $cat: $count items");
        }
        $this->command->info("\nStore: {$storeData->name} (ID: {$store->id})");
    }

    /**
     * Get category code for item numbering
     */
    private function getCategoryCode(string $category): string
    {
        $codes = [
            'Fresh Produce - Vegetables' => 'VEG',
            'Fresh Produce - Fruits' => 'FRUIT',
            'Fresh Herbs' => 'HERB',
            'Dairy & Fats' => 'DAIRY',
            'Baking & Desserts' => 'BAKE',
            'Prepared Foods' => 'PREP',
            'Disposables' => 'DISP',
            'Cleaning Supplies' => 'CLEAN',
            'Other Ingredients' => 'OTHER',
        ];
        
        return $codes[$category] ?? 'FOOD';
    }

    /**
     * Calculate appropriate reorder point based on quantity and shelf life
     */
    private function calculateReorderPoint(int $quantity, int $shelfLifeDays): int
    {
        // For items with short shelf life, higher reorder point
        if ($shelfLifeDays <= 7) {
            return max(1, floor($quantity * 0.5)); // 50%
        } elseif ($shelfLifeDays <= 30) {
            return max(1, floor($quantity * 0.3)); // 30%
        } else {
            return max(1, floor($quantity * 0.2)); // 20%
        }
    }

    /**
     * Determine stock status
     */
    private function determineStockStatus(float $quantity, float $reorderPoint): string
    {
        if ($quantity == 0) {
            return 'Out of Stock';
        } elseif ($quantity <= $reorderPoint) {
            return 'Low Stock';
        }
        return 'Healthy';
    }
}
