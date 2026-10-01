<?php

namespace App\Http\Controllers;

use App\Models\Supplier;
use Illuminate\Http\Request;

class SupplierController extends Controller
{
    /**
     * Display a listing of suppliers
     */
    public function index(Request $request)
    {
        $query = Supplier::query();

        // Search
        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('name', 'ILIKE', "%{$search}%")
                  ->orWhere('company', 'ILIKE', "%{$search}%")
                  ->orWhere('contact_person', 'ILIKE', "%{$search}%");
            });
        }

        // Filter by active status
        if ($request->has('active')) {
            $query->where('is_active', $request->boolean('active'));
        }

        $suppliers = $query->orderBy('name')
            ->paginate($request->get('per_page', 15));

        return $this->success([
            'suppliers' => $suppliers->items(),
            'pagination' => [
                'current_page' => $suppliers->currentPage(),
                'last_page' => $suppliers->lastPage(),
                'per_page' => $suppliers->perPage(),
                'total' => $suppliers->total(),
            ],
        ]);
    }

    /**
     * Store a newly created supplier
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'company' => 'nullable|string|max:255',
            'contact_person' => 'nullable|string|max:255',
            'phone' => 'nullable|string|max:50',
            'email' => 'nullable|string|email|max:255',
            'address' => 'nullable|string',
            'tax_number' => 'nullable|string|max:100',
            'payment_terms' => 'nullable|string|max:255',
            'notes' => 'nullable|string',
            'is_active' => 'boolean',
        ]);

        $supplier = Supplier::create($validated);

        return $this->success($supplier, 'Supplier created successfully', 201);
    }

    /**
     * Display the specified supplier
     */
    public function show(Supplier $supplier)
    {
        return $this->success($supplier);
    }

    /**
     * Update the specified supplier
     */
    public function update(Request $request, Supplier $supplier)
    {
        $validated = $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'company' => 'nullable|string|max:255',
            'contact_person' => 'nullable|string|max:255',
            'phone' => 'nullable|string|max:50',
            'email' => 'nullable|string|email|max:255',
            'address' => 'nullable|string',
            'tax_number' => 'nullable|string|max:100',
            'payment_terms' => 'nullable|string|max:255',
            'notes' => 'nullable|string',
            'is_active' => 'boolean',
        ]);

        $supplier->update($validated);

        return $this->success($supplier, 'Supplier updated successfully');
    }

    /**
     * Remove the specified supplier
     */
    public function destroy(Supplier $supplier)
    {
        // TODO: Check for existing purchase orders or other references
        $supplier->delete();

        return $this->success(null, 'Supplier deleted successfully');
    }
}