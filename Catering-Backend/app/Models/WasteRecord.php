<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class WasteRecord extends Model
{
    use HasFactory, HasUuids, SoftDeletes;

    public const STATUS_CONFIRMED = 'Confirmed';
    public const STATUS_PENDING_REVIEW = 'Pending Review';

    protected $fillable = [
        'id',
        'number',
        'item_id',
        'store_id',
        'item',
        'category',
        'unit',
        'quantity',
        'estimated_cost',
        'reason',
        'recorded_by',
        'date',
        'status',
        'notes',
        'created_by',
    ];

    protected $casts = [
        'quantity' => 'decimal:3',
        'estimated_cost' => 'decimal:2',
        'date' => 'datetime',
    ];

    public function item()
    {
        return $this->belongsTo(Item::class);
    }

    public function store()
    {
        return $this->belongsTo(Store::class);
    }

    public function creator()
    {
        return $this->belongsTo(User::class, 'created_by');
    }
}