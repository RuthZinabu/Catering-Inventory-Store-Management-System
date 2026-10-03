<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Recipe extends Model
{
    use HasFactory, HasUuids, SoftDeletes;

    protected $fillable = [
        'name', 'category', 'description', 'servings', 'prep_time',
        'selling_price', 'status', 'total_food_cost', 'food_cost_percentage', 'created_by',
    ];

    protected $casts = [
        'servings' => 'integer',
        'selling_price' => 'decimal:2',
        'total_food_cost' => 'decimal:2',
        'food_cost_percentage' => 'decimal:2',
    ];

    public function ingredients()
    {
        return $this->hasMany(RecipeIngredient::class);
    }

    public function createdBy()
    {
        return $this->belongsTo(User::class, 'created_by');
    }
}