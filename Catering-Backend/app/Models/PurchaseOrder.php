<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class PurchaseOrder extends Model
{
    use HasUuids, SoftDeletes;

    protected $fillable = [
        'number', 'supplier_id', 'destination_store_id', 'created_by', 'approved_by',
        'order_date', 'expected_delivery_date', 'status', 'payment_status',
        'subtotal', 'vat_amount', 'discount_amount', 'total_amount', 'notes',
        'approved_at', 'received_at',
    ];

    protected $casts = [
        'order_date' => 'date:Y-m-d',
        'expected_delivery_date' => 'date:Y-m-d',
        'subtotal' => 'decimal:2',
        'vat_amount' => 'decimal:2',
        'discount_amount' => 'decimal:2',
        'total_amount' => 'decimal:2',
        'approved_at' => 'datetime',
        'received_at' => 'datetime',
    ];

    public function supplier()
    {
        return $this->belongsTo(Supplier::class);
    }

    public function destinationStore()
    {
        return $this->belongsTo(Store::class, 'destination_store_id');
    }

    public function creator()
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    public function items()
    {
        return $this->hasMany(PurchaseOrderItem::class);
    }

    public function receipts()
    {
        return $this->hasMany(PurchaseReceipt::class);
    }

    public function returns()
    {
        return $this->hasMany(PurchaseReturn::class);
    }
}
