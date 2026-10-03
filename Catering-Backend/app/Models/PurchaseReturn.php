<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;

class PurchaseReturn extends Model
{
    use HasUuids;

    protected $fillable = [
        'number', 'purchase_order_id', 'created_by', 'reviewed_by',
        'return_date', 'status', 'reason', 'reviewed_at',
    ];

    protected $casts = [
        'return_date' => 'date:Y-m-d',
        'reviewed_at' => 'datetime',
    ];

    public function items()
    {
        return $this->hasMany(PurchaseReturnItem::class);
    }
}
