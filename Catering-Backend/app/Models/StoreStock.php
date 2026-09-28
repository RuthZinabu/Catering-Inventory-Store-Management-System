<?php

namespace App\Models;

use App\Enums\StockStatus;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class StoreStock extends Model
{
    use HasFactory, HasUuids;

    protected $table = 'store_stock';

    protected $fillable = [
        'item_id',
        'store_id',
        'quantity',
        'reserved_quantity',
        'min_quantity',
        'max_quantity',
        'reorder_point',
        'location_code',
        'location_description',
        'current_cost',
        'last_cost',
        'status',
        'last_counted_at',
        'last_counted_by',
    ];

    protected $casts = [
        'quantity' => 'decimal:3',
        'reserved_quantity' => 'decimal:3',
        'min_quantity' => 'decimal:3',
        'max_quantity' => 'decimal:3',
        'reorder_point' => 'decimal:3',
        'current_cost' => 'decimal:2',
        'last_cost' => 'decimal:2',
        'status' => StockStatus::class,
        'last_counted_at' => 'datetime',
    ];

    /**
     * Get the item.
     */
    public function item()
    {
        return $this->belongsTo(Item::class);
    }

    /**
     * Get the store.
     */
    public function store()
    {
        return $this->belongsTo(Store::class);
    }

    /**
     * Get the user who last counted this stock.
     */
    public function lastCountedBy()
    {
        return $this->belongsTo(User::class, 'last_counted_by');
    }

    /**
     * Get stock movements for this store stock.
     */
    public function stockMovements()
    {
        return $this->hasMany(StockMovement::class, 'item_id', 'item_id')
                    ->where('store_id', $this->store_id);
    }

    /**
     * Calculate available quantity (computed column in DB, but also available as method).
     */
    public function getAvailableQuantityAttribute()
    {
        return $this->quantity - $this->reserved_quantity;
    }

    /**
     * Get stock value (quantity * current cost).
     */
    public function getStockValueAttribute()
    {
        return $this->quantity * $this->current_cost;
    }

    /**
     * Get stock fill percentage (quantity / max_quantity).
     */
    public function getStockFillPercentageAttribute()
    {
        if ($this->max_quantity <= 0) {
            return 0;
        }
        
        return ($this->quantity / $this->max_quantity) * 100;
    }

    /**
     * Update stock status based on current quantity.
     */
    public function updateStatus(): void
    {
        $status = StockStatus::HEALTHY;

        if ($this->quantity <= 0) {
            $status = StockStatus::OUT_OF_STOCK;
        } elseif ($this->quantity <= $this->min_quantity) {
            $status = StockStatus::LOW_STOCK;
        }

        $this->update(['status' => $status]);
    }

    /**
     * Reserve quantity for transfers or orders.
     */
    public function reserveQuantity(float $quantity): bool
    {
        if ($this->available_quantity < $quantity) {
            return false;
        }

        $this->increment('reserved_quantity', $quantity);
        return true;
    }

    /**
     * Release reserved quantity.
     */
    public function releaseQuantity(float $quantity): void
    {
        $this->decrement('reserved_quantity', $quantity);
    }

    /**
     * Adjust stock quantity.
     */
    public function adjustQuantity(float $quantity, User $user, string $reason = null): StockMovement
    {
        $oldQuantity = $this->quantity;
        $newQuantity = $oldQuantity + $quantity;

        $this->update(['quantity' => $newQuantity]);
        $this->updateStatus();

        return StockMovement::create([
            'item_id' => $this->item_id,
            'store_id' => $this->store_id,
            'type' => \App\Enums\MovementType::ADJUSTMENT,
            'quantity' => abs($quantity),
            'unit' => $this->item->unit,
            'quantity_before' => $oldQuantity,
            'quantity_after' => $newQuantity,
            'note' => $reason,
            'performed_by' => $user->id,
        ]);
    }

    /**
     * Scope to get low stock items.
     */
    public function scopeLowStock($query)
    {
        return $query->where('status', StockStatus::LOW_STOCK);
    }

    /**
     * Scope to get out of stock items.
     */
    public function scopeOutOfStock($query)
    {
        return $query->where('status', StockStatus::OUT_OF_STOCK);
    }

    /**
     * Scope to get items with available quantity.
     */
    public function scopeAvailable($query)
    {
        return $query->whereRaw('quantity - reserved_quantity > 0');
    }
}