<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class KitchenIssueItem extends Model
{
    use HasFactory, HasUuids;

    protected $fillable = [
        'kitchen_issue_id', 'item_id', 'quantity_requested', 'quantity_issued', 'unit',
    ];

    protected $casts = [
        'quantity_requested' => 'decimal:3',
        'quantity_issued' => 'decimal:3',
    ];

    public function kitchenIssue()
    {
        return $this->belongsTo(KitchenIssue::class);
    }

    public function item()
    {
        return $this->belongsTo(Item::class);
    }
}