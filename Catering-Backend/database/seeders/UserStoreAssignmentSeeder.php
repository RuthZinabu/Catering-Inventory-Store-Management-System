<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Store;
use App\Models\UserStoreAssignment;

class UserStoreAssignmentSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $admin = User::where('role', 'admin')->first();
        $store = Store::first();
        
        if ($admin && $store) {
            UserStoreAssignment::firstOrCreate([
                'user_id' => $admin->id,
                'store_id' => $store->id,
            ], [
                'role_in_store' => 'manager',
                'can_transfer_to' => true,
                'can_transfer_from' => true,
            ]);
            
            $this->command->info('Store assignment created/verified for admin user');
        } else {
            $this->command->warn('Admin user or store not found');
        }
    }
}