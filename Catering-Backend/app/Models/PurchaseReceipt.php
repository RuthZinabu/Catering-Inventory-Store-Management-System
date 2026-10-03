<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;

class PurchaseReceipt extends Model
{
    use HasUuids;

    protected $fillable = [
        'purchase_order_id', 'received_by', 'grn_number', 'delivery_date',
        'driver_name', 'vehicle_number', 'notes',
    ];

    protected $casts = ['delivery_date' => 'date:Y-m-d'];

    public function items()
    {
        return $this->hasMany(PurchaseReceiptItem::class);
    }
}
