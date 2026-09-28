<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Store extends Model
{
    use HasFactory, HasUuids, SoftDeletes;

    protected $fillable = [
        'name',
        'code',
        'description',
        'location',
        'phone',
        'email',
        'parent_store_id',
        'store_level',
        'manager_id',
        'store_type',
        'timezone',
        'operating_hours',
        'settings',
        'is_active',
    ];

    protected $casts = [
        'operating_hours' => 'array',
        'settings' => 'array',
        'is_active' => 'boolean',
        'store_level' => 'integer',
    ];

    const DELETED_AT = 'deleted_at';

    /**
     * Store types
     */
    const TYPE_MAIN_WAREHOUSE = 'main_warehouse';
    const TYPE_DRY_FOOD = 'dry_food';
    const TYPE_COLD_ROOM = 'cold_room';
    const TYPE_FREEZER = 'freezer';
    const TYPE_BEVERAGE = 'beverage';
    const TYPE_KITCHEN = 'kitchen';
    const TYPE_ELECTRONICS = 'electronics';
    const TYPE_GENERAL = 'general';

    /**
     * Get the parent store.
     */
    public function parentStore()
    {
        return $this->belongsTo(Store::class, 'parent_store_id');
    }

    /**
     * Get the child stores.
     */
    public function childStores()
    {
        return $this->hasMany(Store::class, 'parent_store_id');
    }

    /**
     * Get the store manager.
     */
    public function manager()
    {
        return $this->belongsTo(User::class, 'manager_id');
    }

    /**
     * Get users assigned to this store.
     */
    public function users()
    {
        return $this->belongsToMany(User::class, 'user_store_assignments')
                    ->withPivot(['role_in_store', 'can_transfer_to', 'can_transfer_from'])
                    ->withTimestamps();
    }

    /**
     * Get user store assignments.
     */
    public function userAssignments()
    {
        return $this->hasMany(UserStoreAssignment::class);
    }

    /**
     * Get stock items in this store.
     */
    public function stockItems()
    {
        return $this->hasMany(StoreStock::class);
    }

    /**
     * Get stock movements for this store.
     */
    public function stockMovements()
    {
        return $this->hasMany(StockMovement::class);
    }

    /**
     * Get transfers from this store.
     */
    public function transfersFrom()
    {
        return $this->hasMany(Transfer::class, 'from_store_id');
    }

    /**
     * Get transfers to this store.
     */
    public function transfersTo()
    {
        return $this->hasMany(Transfer::class, 'to_store_id');
    }

    /**
     * Get purchase orders for this store.
     */
    public function purchaseOrders()
    {
        return $this->hasMany(PurchaseOrder::class, 'destination_store_id');
    }

    /**
     * Get waste records for this store.
     */
    public function wasteRecords()
    {
        return $this->hasMany(WasteRecord::class);
    }

    /**
     * Scope to get active stores.
     */
    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    /**
     * Scope to get stores by type.
     */
    public function scopeOfType($query, $type)
    {
        return $query->where('store_type', $type);
    }

    /**
     * Get all descendant stores (children, grandchildren, etc.).
     */
    public function descendants()
    {
        $descendants = collect();
        
        foreach ($this->childStores as $child) {
            $descendants->push($child);
            $descendants = $descendants->merge($child->descendants());
        }
        
        return $descendants;
    }
}