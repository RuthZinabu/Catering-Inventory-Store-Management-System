<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;

class PurchaseReceiptItem extends Model
{
    use HasUuids;

    protected $fillable = [
        'purchase_receipt_id', 'purchase_order_item_id', 'received_quantity',
        'accepted_quantity', 'rejected_quantity', 'quality_status', 'rejection_reason',
    ];

    protected $casts = [
        'received_quantity' => 'decimal:3',
        'accepted_quantity' => 'decimal:3',
        'rejected_quantity' => 'decimal:3',
    ];
}
