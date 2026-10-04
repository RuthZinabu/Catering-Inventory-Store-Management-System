<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;

class InventoryBatch extends Model
{
    use HasUuids;

    protected $fillable = [
        'store_id',
        'item_id',
        'purchase_receipt_item_id',
        'lot_number',
        'expires_on',
        'received_quantity',
        'quantity_remaining',
        'unit_cost',
        'created_by',
    ];

    protected $casts = [
        'expires_on' => 'date:Y-m-d',
        'received_quantity' => 'decimal:3',
        'quantity_remaining' => 'decimal:3',
        'unit_cost' => 'decimal:2',
    ];

    public function item()
    {
        return $this->belongsTo(Item::class);
    }

    public function store()
    {
        return $this->belongsTo(Store::class);
    }

    public function receiptItem()
    {
        return $this->belongsTo(PurchaseReceiptItem::class, 'purchase_receipt_item_id');
    }
}