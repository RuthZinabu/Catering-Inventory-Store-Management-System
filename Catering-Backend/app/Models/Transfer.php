<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Transfer extends Model
{
    use HasFactory, HasUuids;

    protected $fillable = [
        'transfer_number', 'from_store_id', 'to_store_id', 'status', 'priority',
        'requested_by', 'approved_by', 'shipped_by', 'received_by', 'requested_date',
        'required_date', 'approved_date', 'shipped_date', 'received_date', 'notes', 'shipping_notes',
    ];

    protected $casts = [
        'requested_date' => 'date',
        'required_date' => 'date',
        'approved_date' => 'date',
        'shipped_date' => 'date',
        'received_date' => 'date',
    ];

    public function fromStore()
    {
        return $this->belongsTo(Store::class, 'from_store_id');
    }

    public function toStore()
    {
        return $this->belongsTo(Store::class, 'to_store_id');
    }

    public function items()
    {
        return $this->hasMany(TransferItem::class);
    }

    public function requestedBy()
    {
        return $this->belongsTo(User::class, 'requested_by');
    }

    public function approvedBy()
    {
        return $this->belongsTo(User::class, 'approved_by');
    }
}