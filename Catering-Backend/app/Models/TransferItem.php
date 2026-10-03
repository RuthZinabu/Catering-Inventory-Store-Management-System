<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TransferItem extends Model
{
    use HasFactory, HasUuids;

    protected $fillable = [
        'transfer_id', 'item_id', 'quantity_requested', 'quantity_approved',
        'quantity_shipped', 'quantity_received', 'unit_cost', 'notes',
    ];

    protected $casts = [
        'quantity_requested' => 'decimal:3',
        'quantity_approved' => 'decimal:3',
        'quantity_shipped' => 'decimal:3',
        'quantity_received' => 'decimal:3',
        'unit_cost' => 'decimal:2',
    ];

    public function transfer()
    {
        return $this->belongsTo(Transfer::class);
    }

    public function item()
    {
        return $this->belongsTo(Item::class);
    }
}