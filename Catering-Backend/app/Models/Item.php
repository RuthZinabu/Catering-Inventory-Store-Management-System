<?php

namespace App\Models;

use App\Enums\ItemType;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Item extends Model
{
    use HasFactory, HasUuids, SoftDeletes;

    protected $fillable = [
        'code',
        'name',
        'description',
        'category',
        'item_type',
        'unit',
        'default_purchase_price',
        'shelf_life_days',
        'requires_refrigeration',
        'catering_subtype',
        'brand',
        'model',
        'warranty_period_months',
        'supplier_id',
        'is_active',
        'created_by',
    ];

    protected $casts = [
        'item_type' => ItemType::class,
        'default_purchase_price' => 'decimal:2',
        'shelf_life_days' => 'integer',
        'requires_refrigeration' => 'boolean',
        'warranty_period_months' => 'integer',
        'is_active' => 'boolean',
    ];

    const DELETED_AT = 'deleted_at';

    /**
     * Catering subtypes
     */
    const CATERING_PERMANENT = 'permanent';
    const CATERING_TEMPORARY = 'temporary';

    /**
     * Get the user who created this item.
     */
    public function creator()
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    public function supplier()
    {
        return $this->belongsTo(Supplier::class);
    }

    /**
     * Get stock levels across all stores for this item.
     */
    public function storeStock()
    {
        return $this->hasMany(StoreStock::class);
    }

    /**
     * Get stock movements for this item.
     */
    public function stockMovements()
    {
        return $this->hasMany(StockMovement::class);
    }

    /**
     * Get purchase order items for this item.
     */
    public function purchaseOrderItems()
    {
        return $this->hasMany(PurchaseOrderItem::class);
    }

    /**
     * Get recipe ingredients using this item.
     */
    public function recipeIngredients()
    {
        return $this->hasMany(RecipeIngredient::class);
    }

    /**
     * Get waste records for this item.
     */
    public function wasteRecords()
    {
        return $this->hasMany(WasteRecord::class);
    }

    /**
     * Get transfer items for this item.
     */
    public function transferItems()
    {
        return $this->hasMany(TransferItem::class);
    }

    /**
     * Scope to get active items.
     */
    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    /**
     * Scope to get items by type.
     */
    public function scopeOfType($query, ItemType $type)
    {
        return $query->where('item_type', $type);
    }

    /**
     * Scope to search items by name or code.
     */
    public function scopeSearch($query, $search)
    {
                $pattern = '%' . mb_strtolower($search) . '%';

        return $query->where(function ($q) use ($search) {
                        $pattern = '%' . mb_strtolower($search) . '%';
                        $q->whereRaw('LOWER(name) LIKE ?', [$pattern])
                            ->orWhereRaw('LOWER(code) LIKE ?', [$pattern])
                            ->orWhereRaw('LOWER(description) LIKE ?', [$pattern]);
        });
    }

    /**
     * Scope to filter by category.
     */
    public function scopeOfCategory($query, $category)
    {
        return $query->where('category', $category);
    }

    /**
     * Get total stock across all stores.
     */
    public function getTotalStockAttribute()
    {
        return $this->storeStock()->sum('quantity');
    }

    /**
     * Get available stock across all stores.
     */
    public function getAvailableStockAttribute()
    {
        return $this->storeStock()->sum('available_quantity');
    }

    /**
     * Check if item is food type.
     */
    public function isFoodType(): bool
    {
        return $this->item_type === ItemType::FOOD;
    }

    /**
     * Check if item is catering type.
     */
    public function isCateringType(): bool
    {
        return $this->item_type === ItemType::CATERING;
    }

    /**
     * Check if item is electronics type.
     */
    public function isElectronicsType(): bool
    {
        return $this->item_type === ItemType::ELECTRONICS;
    }
}