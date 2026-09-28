<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Store;
use App\Models\Supplier;
use App\Models\Item;
use App\Enums\ItemType;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Create admin user
        $admin = User::create([
            'name' => 'System Administrator',
            'email' => 'admin@cateringinventory.com',
            'password' => Hash::make('password123'),
            'role' => User::ROLE_ADMIN,
            'department' => 'Management',
            'status' => User::STATUS_ACTIVE,
            'permissions' => [
                'inventory.view', 'inventory.create', 'inventory.update', 'inventory.delete',
                'suppliers.view', 'suppliers.create', 'suppliers.update', 'suppliers.delete',
                'purchases.view', 'purchases.create', 'purchases.update', 'purchases.delete',
                'users.view', 'users.create', 'users.update', 'users.delete',
                'stores.view', 'stores.create', 'stores.update', 'stores.delete',
                'reports.view', 'reports.export',
                'dashboard.view',
            ],
            'password_changed_at' => now(),
        ]);

        // Create main warehouse store
        $mainStore = Store::create([
            'name' => 'Main Warehouse',
            'code' => 'MW-001',
            'description' => 'Primary storage facility',
            'location' => 'Main Building, Ground Floor',
            'phone' => '+251911123456',
            'email' => 'warehouse@cateringinventory.com',
            'manager_id' => $admin->id,
            'store_type' => Store::TYPE_MAIN_WAREHOUSE,
            'store_level' => 0,
            'timezone' => 'Africa/Addis_Ababa',
            'operating_hours' => [
                'monday' => ['open' => '08:00', 'close' => '18:00'],
                'tuesday' => ['open' => '08:00', 'close' => '18:00'],
                'wednesday' => ['open' => '08:00', 'close' => '18:00'],
                'thursday' => ['open' => '08:00', 'close' => '18:00'],
                'friday' => ['open' => '08:00', 'close' => '18:00'],
                'saturday' => ['open' => '09:00', 'close' => '17:00'],
                'sunday' => ['open' => null, 'close' => null],
            ],
            'is_active' => true,
        ]);

        // Create cold room store
        $coldStore = Store::create([
            'name' => 'Cold Storage Room',
            'code' => 'CS-001', 
            'description' => 'Refrigerated storage for perishables',
            'location' => 'Main Building, Basement Level',
            'parent_store_id' => $mainStore->id,
            'store_level' => 1,
            'store_type' => Store::TYPE_COLD_ROOM,
            'timezone' => 'Africa/Addis_Ababa',
            'is_active' => true,
        ]);

        // Create store manager user
        $storeManager = User::create([
            'name' => 'Store Manager',
            'email' => 'manager@cateringinventory.com',
            'password' => Hash::make('password123'),
            'role' => User::ROLE_STORE_MANAGER,
            'department' => 'Main Store',
            'status' => User::STATUS_ACTIVE,
            'permissions' => [
                'inventory.view', 'inventory.create', 'inventory.update',
                'suppliers.view', 'suppliers.create', 'suppliers.update',
                'purchases.view', 'purchases.create', 'purchases.update',
                'reports.view', 'dashboard.view',
            ],
            'password_changed_at' => now(),
        ]);

        // Assign store manager to stores
        $storeManager->stores()->attach($mainStore->id, [
            'role_in_store' => 'manager',
            'can_transfer_to' => true,
            'can_transfer_from' => true,
        ]);

        $storeManager->stores()->attach($coldStore->id, [
            'role_in_store' => 'manager',
            'can_transfer_to' => true,
            'can_transfer_from' => true,
        ]);

        // Create suppliers
        $supplier1 = Supplier::create([
            'name' => 'Fresh Foods PLC',
            'company' => 'Fresh Foods PLC',
            'contact_person' => 'Ahmed Ibrahim',
            'phone' => '+251911234567',
            'email' => 'ahmed@freshfoods.com.et',
            'address' => 'Merkato, Addis Ababa',
            'tax_number' => 'TIN-001234567',
            'status' => Supplier::STATUS_ACTIVE,
            'payment_terms' => 'Net 30 days',
            'credit_limit' => 50000.00,
        ]);

        $supplier2 = Supplier::create([
            'name' => 'Urban Pantry Supplies',
            'company' => 'Urban Pantry Supplies Ltd.',
            'contact_person' => 'Fatima Hassan',
            'phone' => '+251922345678',
            'email' => 'fatima@urbanpantry.com',
            'address' => 'Bole, Addis Ababa',
            'tax_number' => 'TIN-002345678',
            'status' => Supplier::STATUS_ACTIVE,
            'payment_terms' => 'Net 15 days',
            'credit_limit' => 30000.00,
        ]);

        // Create sample items
        $items = [
            [
                'code' => 'FOOD-MEAT-001',
                'name' => 'Chicken Breast (Boneless)',
                'description' => 'Fresh boneless chicken breast',
                'category' => 'Meat & Poultry',
                'item_type' => ItemType::FOOD,
                'unit' => 'kg',
                'default_purchase_price' => 150.00,
                'shelf_life_days' => 7,
                'requires_refrigeration' => true,
                'created_by' => $admin->id,
            ],
            [
                'code' => 'FOOD-GRAIN-001', 
                'name' => 'Basmati Rice',
                'description' => 'Premium basmati rice',
                'category' => 'Grains & Cereals',
                'item_type' => ItemType::FOOD,
                'unit' => 'kg',
                'default_purchase_price' => 85.00,
                'shelf_life_days' => 365,
                'requires_refrigeration' => false,
                'created_by' => $admin->id,
            ],
            [
                'code' => 'CATERING-TABLE-001',
                'name' => 'Banquet Table (Round)',
                'description' => '6-seater round banquet table',
                'category' => 'Tables',
                'item_type' => ItemType::CATERING,
                'unit' => 'piece',
                'default_purchase_price' => 2500.00,
                'catering_subtype' => 'permanent',
                'created_by' => $admin->id,
            ],
            [
                'code' => 'ELECTRONICS-POS-001',
                'name' => 'POS Terminal',
                'description' => 'Point of sale terminal system',
                'category' => 'POS Equipment',
                'item_type' => ItemType::ELECTRONICS,
                'unit' => 'piece',
                'default_purchase_price' => 12000.00,
                'brand' => 'Ingenico',
                'model' => 'iWL220',
                'warranty_period_months' => 24,
                'created_by' => $admin->id,
            ],
        ];

        foreach ($items as $itemData) {
            Item::create($itemData);
        }

        $this->command->info('Database seeded successfully!');
        $this->command->info('Admin credentials: admin@cateringinventory.com / password123');
        $this->command->info('Manager credentials: manager@cateringinventory.com / password123');
    }
}