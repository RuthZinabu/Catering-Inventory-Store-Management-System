<?php

namespace App\Http\Controllers;

use App\Models\Recipe;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;

class RecipeController extends Controller
{
    public function index(Request $request)
    {
        $validated = $request->validate([
            'search' => 'nullable|string|max:100',
            'category' => 'nullable|string|max:100',
            'status' => ['nullable', Rule::in(['Active', 'Inactive'])],
            'per_page' => 'nullable|integer|min:1|max:100',
        ]);

        $query = Recipe::with('ingredients');
        if (!empty($validated['search'])) {
            $search = '%' . $validated['search'] . '%';
            $query->where(function ($builder) use ($search) {
                $builder->where('name', 'like', $search)
                    ->orWhere('category', 'like', $search);
            });
        }
        if (!empty($validated['category'])) {
            $query->where('category', $validated['category']);
        }
        if (!empty($validated['status'])) {
            $query->where('status', $validated['status']);
        }

        $recipes = $query->orderBy('name')->paginate($validated['per_page'] ?? 50);

        return $this->success([
            'items' => $recipes->getCollection()->map(fn (Recipe $recipe) => $this->serializeRecipe($recipe)),
            'pagination' => [
                'current_page' => $recipes->currentPage(),
                'last_page' => $recipes->lastPage(),
                'per_page' => $recipes->perPage(),
                'total' => $recipes->total(),
            ],
        ]);
    }

    public function store(Request $request)
    {
        $validated = $this->validateRecipe($request, true);
        $recipe = DB::transaction(function () use ($request, $validated) {
            $recipe = Recipe::create([
                ...collect($validated)->except('ingredients')->all(),
                'description' => $validated['description'] ?? null,
                'prep_time' => $validated['prep_time'] ?? null,
                'status' => $validated['status'] ?? 'Active',
                'created_by' => $request->user()->id,
            ]);
            $this->replaceIngredients($recipe, $validated['ingredients']);
            return $recipe;
        });

        return $this->success($this->serializeRecipe($recipe->load('ingredients')), 'Recipe created successfully', 201);
    }

    public function show(Recipe $recipe)
    {
        return $this->success($this->serializeRecipe($recipe->load('ingredients')));
    }

    public function update(Request $request, Recipe $recipe)
    {
        $validated = $this->validateRecipe($request, false);
        DB::transaction(function () use ($recipe, $validated) {
            $recipe->update(collect($validated)->except('ingredients')->all());
            if (array_key_exists('ingredients', $validated)) {
                $this->replaceIngredients($recipe, $validated['ingredients']);
            } else {
                $this->updateCalculatedCosts($recipe, (float) $recipe->total_food_cost);
            }
        });

        return $this->success($this->serializeRecipe($recipe->fresh()->load('ingredients')), 'Recipe updated successfully');
    }

    public function destroy(Recipe $recipe)
    {
        $recipe->delete();
        return $this->success(null, 'Recipe deleted successfully');
    }

    private function validateRecipe(Request $request, bool $creating): array
    {
        $required = $creating ? ['required'] : ['sometimes', 'required'];
        return $request->validate([
            'name' => [...$required, 'string', 'max:255'],
            'category' => [...$required, 'string', 'max:100'],
            'description' => 'nullable|string',
            'servings' => [...$required, 'integer', 'min:1'],
            'prep_time' => 'nullable|string|max:50',
            'selling_price' => [...$required, 'numeric', 'min:0'],
            'status' => ['sometimes', 'string', Rule::in(['Active', 'Inactive'])],
            'ingredients' => [...($creating ? ['required'] : ['sometimes']), 'array', 'min:1'],
            'ingredients.*.item_id' => [
                'nullable', 'uuid',
                Rule::exists('items', 'id')->whereNull('deleted_at')->where('is_active', true),
            ],
            'ingredients.*.name' => 'required_with:ingredients|string|max:255',
            'ingredients.*.quantity' => 'required_with:ingredients|numeric|gt:0',
            'ingredients.*.unit' => 'required_with:ingredients|string|max:20',
            'ingredients.*.unit_cost' => 'required_with:ingredients|numeric|min:0',
        ]);
    }

    private function replaceIngredients(Recipe $recipe, array $ingredients): void
    {
        $recipe->ingredients()->delete();
        $totalFoodCost = 0;
        foreach ($ingredients as $ingredient) {
            $quantity = (float) $ingredient['quantity'];
            $unitCost = (float) $ingredient['unit_cost'];
            $totalCost = round($quantity * $unitCost, 2);
            $totalFoodCost += $totalCost;
            $recipe->ingredients()->create([
                'item_id' => $ingredient['item_id'] ?? null,
                'ingredient_name' => $ingredient['name'],
                'quantity' => $quantity,
                'unit' => $ingredient['unit'],
                'unit_cost' => $unitCost,
                'total_cost' => $totalCost,
            ]);
        }
        $this->updateCalculatedCosts($recipe, round($totalFoodCost, 2));
    }

    private function updateCalculatedCosts(Recipe $recipe, float $totalFoodCost): void
    {
        $sellingPrice = (float) $recipe->selling_price;
        $recipe->update([
            'total_food_cost' => $totalFoodCost,
            'food_cost_percentage' => $sellingPrice > 0
                ? round(($totalFoodCost / $sellingPrice) * 100, 2)
                : 0,
        ]);
    }

    private function serializeRecipe(Recipe $recipe): array
    {
        return [
            'id' => $recipe->id,
            'name' => $recipe->name,
            'category' => $recipe->category,
            'description' => $recipe->description ?? '',
            'servings' => (int) $recipe->servings,
            'ingredients' => $recipe->ingredients->map(fn ($ingredient) => [
                'name' => $ingredient->ingredient_name,
                'quantity' => (float) $ingredient->quantity,
                'unit' => $ingredient->unit,
                'unit_cost' => (float) $ingredient->unit_cost,
            ])->values(),
            'selling_price' => (float) $recipe->selling_price,
            'prep_time' => $recipe->prep_time ?? '',
            'status' => $recipe->status,
            'total_food_cost' => (float) $recipe->total_food_cost,
            'food_cost_percentage' => (float) $recipe->food_cost_percentage,
            'created_at' => $recipe->created_at,
            'updated_at' => $recipe->updated_at,
        ];
    }
}