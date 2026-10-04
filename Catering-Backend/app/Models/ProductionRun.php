<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;

class ProductionRun extends Model
{
    use HasUuids;

    protected $fillable = [
        'store_id',
        'recipe_id',
        'production_date',
        'produced_servings',
        'notes',
        'created_by',
    ];

    protected $casts = [
        'production_date' => 'date:Y-m-d',
        'produced_servings' => 'decimal:3',
    ];

    public function recipe()
    {
        return $this->belongsTo(Recipe::class);
    }

    public function store()
    {
        return $this->belongsTo(Store::class);
    }

    public function ingredients()
    {
        return $this->hasMany(ProductionRunItem::class);
    }
}