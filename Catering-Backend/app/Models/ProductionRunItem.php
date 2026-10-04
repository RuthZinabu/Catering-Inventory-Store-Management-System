<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;

class ProductionRunItem extends Model
{
    use HasUuids;

    protected $fillable = [
        'production_run_id',
        'item_id',
        'ingredient_name',
        'unit',
        'theoretical_quantity',
        'unit_cost',
    ];

    protected $casts = [
        'theoretical_quantity' => 'decimal:3',
        'unit_cost' => 'decimal:2',
    ];

    public function productionRun()
    {
        return $this->belongsTo(ProductionRun::class);
    }

    public function item()
    {
        return $this->belongsTo(Item::class);
    }
}