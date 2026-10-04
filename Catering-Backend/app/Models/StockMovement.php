<?php

namespace App\Models;

use App\Enums\MovementType;
use App\Services\InventoryBatchService;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class StockMovement extends Model
{
    use HasFactory, HasUuids, SoftDeletes;

    protected $fillable = [
        'item_id',
        'store_id',
        'type',
        'quantity',
        'unit',
        'quantity_before',
        'quantity_after',
        'reference_type',
        'reference_id',
        'note',
        'from_store_id',
        'to_store_id',
        'is_correction',
        'corrects_movement_id',
        'correction_reason',
        'requires_approval',
        'approved_by',
        'approved_at',
        'rejection_reason',
        'deleted_by',
        'deletion_reason',
        'offline_sync_id',
        'offline_created_at',
        'sync_status',
        'performed_by',
    ];

    protected $casts = [
        'type' => MovementType::class,
        'quantity' => 'decimal:3',
        'quantity_before' => 'decimal:3',
        'quantity_after' => 'decimal:3',
        'is_correction' => 'boolean',
        'requires_approval' => 'boolean',
        'approved_at' => 'datetime',
        'offline_created_at' => 'datetime',
    ];

    const DELETED_AT = 'deleted_at';

    /**
     * Reference types
     */
    const REFERENCE_PURCHASE_ORDER = 'purchase_order';
    const REFERENCE_TRANSFER = 'transfer';
    const REFERENCE_WASTE_RECORD = 'waste_record';
    const REFERENCE_MANUAL = 'manual';
    const REFERENCE_KITCHEN_ISSUE = 'kitchen_issue';

    /**
     * Sync statuses
     */
    const SYNC_SYNCED = 'synced';
    const SYNC_PENDING = 'pending';
    const SYNC_CONFLICT = 'conflict';

    protected static function booted(): void
    {
        static::created(function (StockMovement $movement): void {
            $decrease = (float) $movement->quantity_before - (float) $movement->quantity_after;
            if ($decrease > 0) {
                app(InventoryBatchService::class)->consume(
                    $movement->store_id,
                    $movement->item_id,
                    $decrease
                );
            }
        });
    }

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
     * Get the from store (for transfers).
     */
    public function fromStore()
    {
        return $this->belongsTo(Store::class, 'from_store_id');
    }

    /**
     * Get the to store (for transfers).
     */
    public function toStore()
    {
        return $this->belongsTo(Store::class, 'to_store_id');
    }

    /**
     * Get the user who performed this movement.
     */
    public function performedBy()
    {
        return $this->belongsTo(User::class, 'performed_by');
    }

    /**
     * Get the user who approved this movement.
     */
    public function approvedBy()
    {
        return $this->belongsTo(User::class, 'approved_by');
    }

    /**
     * Get the user who deleted this movement.
     */
    public function deletedBy()
    {
        return $this->belongsTo(User::class, 'deleted_by');
    }

    /**
     * Get the original movement that this corrects.
     */
    public function correctsMovement()
    {
        return $this->belongsTo(StockMovement::class, 'corrects_movement_id');
    }

    /**
     * Get correction movements for this movement.
     */
    public function corrections()
    {
        return $this->hasMany(StockMovement::class, 'corrects_movement_id');
    }

    /**
     * Get the reference object (polymorphic relationship).
     */
    public function reference()
    {
        return match($this->reference_type) {
            self::REFERENCE_PURCHASE_ORDER => $this->belongsTo(PurchaseOrder::class, 'reference_id'),
            self::REFERENCE_TRANSFER => $this->belongsTo(Transfer::class, 'reference_id'),
            self::REFERENCE_WASTE_RECORD => $this->belongsTo(WasteRecord::class, 'reference_id'),
            self::REFERENCE_KITCHEN_ISSUE => $this->belongsTo(KitchenIssue::class, 'reference_id'),
            default => null,
        };
    }

    /**
     * Check if movement is approved.
     */
    public function isApproved(): bool
    {
        return !$this->requires_approval || $this->approved_at !== null;
    }

    /**
     * Check if movement is pending approval.
     */
    public function isPendingApproval(): bool
    {
        return $this->requires_approval && $this->approved_at === null;
    }

    /**
     * Approve the movement.
     */
    public function approve(User $user): void
    {
        $this->update([
            'approved_by' => $user->id,
            'approved_at' => now(),
        ]);
    }

    /**
     * Reject the movement.
     */
    public function reject(User $user, string $reason): void
    {
        $this->update([
            'approved_by' => $user->id,
            'rejection_reason' => $reason,
        ]);
    }

    /**
     * Create a correction for this movement.
     */
    public function createCorrection(User $user, float $correctionQuantity, string $reason): StockMovement
    {
        return DB::transaction(function () use ($user, $correctionQuantity, $reason) {
            $storeStock = StoreStock::where('item_id', $this->item_id)
                ->where('store_id', $this->store_id)
                ->lockForUpdate()
                ->firstOrFail();

            $oldQuantity = (float) $storeStock->quantity;
            $newQuantity = $oldQuantity + $correctionQuantity;
            if ($newQuantity < (float) $storeStock->reserved_quantity) {
                throw ValidationException::withMessages([
                    'correction_quantity' => 'Correction cannot reduce stock below its reserved quantity.',
                ]);
            }

            $storeStock->update(['quantity' => $newQuantity]);
            $storeStock->updateStatus();

            return self::create([
                'item_id' => $this->item_id,
                'store_id' => $this->store_id,
                'type' => MovementType::CORRECTION,
                'quantity' => abs($correctionQuantity),
                'unit' => $this->unit,
                'quantity_before' => $oldQuantity,
                'quantity_after' => $newQuantity,
                'is_correction' => true,
                'corrects_movement_id' => $this->id,
                'correction_reason' => $reason,
                'performed_by' => $user->id,
            ]);
        });
    }

    /**
     * Scope for pending approval.
     */
    public function scopePendingApproval($query)
    {
        return $query->where('requires_approval', true)
                     ->whereNull('approved_at');
    }

    /**
     * Scope for corrections.
     */
    public function scopeCorrections($query)
    {
        return $query->where('is_correction', true);
    }

    /**
     * Scope for sync status.
     */
    public function scopeSyncStatus($query, $status)
    {
        return $query->where('sync_status', $status);
    }
}