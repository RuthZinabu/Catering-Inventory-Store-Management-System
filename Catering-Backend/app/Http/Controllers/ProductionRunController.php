<?php

namespace App\Http\Controllers;

use App\Models\ProductionRun;
use App\Models\Recipe;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ProductionRunController extends Controller
{
    public function index(Request $request)
    {
        $filters = $request->validate([
            'store_id' => 'required|uuid|exists:stores,id',
            'from' => 'nullable|date_format:Y-m-d',
            'to' => 'nullable|date_format:Y-m-d|after_or_equal:from',
            'per_page' => 'nullable|integer|min:1|max:100',
        ]);
        abort_unless($request->user()->canAccessStore($filters['store_id']), 403);

        $query = ProductionRun::query()
            ->with(['recipe:id,name', 'ingredients'])
            ->where('store_id', $filters['store_id']);
        if (!empty($filters['from'])) {
            $query->whereDate('production_date', '>=', $filters['from']);
        }
        if (!empty($filters['to'])) {
            $query->whereDate('production_date', '<=', $filters['to']);
        }
        $runs = $query->orderByDesc('production_date')->paginate($filters['per_page'] ?? 50);

        return $this->success([
            'items' => $runs->getCollection()->map(fn (ProductionRun $run) => $this->serialize($run))->values(),
            'pagination' => [
                'current_page' => $runs->currentPage(),
                'last_page' => $runs->lastPage(),
                'per_page' => $runs->perPage(),
                'total' => $runs->total(),
            ],
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'store_id' => 'required|uuid|exists:stores,id',
            'recipe_id' => 'required|uuid|exists:recipes,id',
            'production_date' => 'required|date_format:Y-m-d',
            'produced_servings' => 'required|numeric|gt:0|max:1000000',
            'notes' => 'nullable|string|max:2000',
        ]);
        abort_unless($request->user()->canAccessStore($validated['store_id']), 403);

        $recipe = Recipe::query()->with('ingredients')->findOrFail($validated['recipe_id']);
        if ($recipe->status !== 'Active') {
            return $this->error('Only active recipes can be recorded as production.', 422);
        }
        if ($recipe->ingredients->isEmpty()) {
            return $this->error('The selected recipe has no ingredients to calculate usage.', 422);
        }

        $run = DB::transaction(function () use ($request, $validated, $recipe) {
            $run = ProductionRun::create([
                'store_id' => $validated['store_id'],
                'recipe_id' => $recipe->id,
                'production_date' => $validated['production_date'],
                'produced_servings' => $validated['produced_servings'],
                'notes' => $validated['notes'] ?? null,
                'created_by' => $request->user()->id,
            ]);
            $scale = (float) $validated['produced_servings'] / max(1, (int) $recipe->servings);

            foreach ($recipe->ingredients as $ingredient) {
                $run->ingredients()->create([
                    'item_id' => $ingredient->item_id,
                    'ingredient_name' => $ingredient->ingredient_name,
                    'unit' => $ingredient->unit,
                    'theoretical_quantity' => round((float) $ingredient->quantity * $scale, 3),
                    'unit_cost' => $ingredient->unit_cost,
                ]);
            }

            return $run;
        });

        return $this->success(
            $this->serialize($run->load(['recipe:id,name', 'ingredients'])),
            'Production recorded successfully',
            201
        );
    }

    private function serialize(ProductionRun $run): array
    {
        return [
            'id' => $run->id,
            'store_id' => $run->store_id,
            'recipe_id' => $run->recipe_id,
            'recipe_name' => $run->recipe?->name ?? 'Deleted recipe',
            'production_date' => Carbon::parse($run->production_date)->toDateString(),
            'produced_servings' => (float) $run->produced_servings,
            'notes' => $run->notes,
            'ingredients' => $run->ingredients->map(fn ($ingredient) => [
                'item_id' => $ingredient->item_id,
                'name' => $ingredient->ingredient_name,
                'unit' => $ingredient->unit,
                'theoretical_quantity' => (float) $ingredient->theoretical_quantity,
                'unit_cost' => $ingredient->unit_cost === null ? null : (float) $ingredient->unit_cost,
            ])->values(),
            'created_at' => $run->created_at,
        ];
    }
}