<?php

namespace App\Http\Controllers;

use App\Models\Supplier;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;

class SupplierController extends Controller
{
    public function index(Request $request)
    {
        $query = Supplier::query();
        if ($request->filled('search')) {
            $search = '%' . $request->string('search') . '%';
            $query->where(function ($builder) use ($search) {
                $builder->where('company', 'like', $search)
                    ->orWhere('name', 'like', $search)
                    ->orWhere('contact_person', 'like', $search)
                    ->orWhere('phone', 'like', $search);
            });
        }
        if ($request->filled('status')) {
            $query->where('status', $request->string('status'));
        }

        $suppliers = $query->orderBy('company')->paginate($request->integer('per_page', 50));
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

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'nullable|string|max:255',
            'company' => 'required|string|max:255',
            'contact_person' => 'required|string|max:255',
            'phone' => 'required|string|max:50',
            'email' => 'required|email|max:255',
            'address' => 'required|string',
            'tax_number' => 'required|string|max:50',
            'category' => 'required|string|max:100',
            'registration_number' => 'nullable|string|max:100',
            'notes' => 'nullable|string',
            'status' => ['sometimes', Rule::in([Supplier::STATUS_ACTIVE, Supplier::STATUS_PENDING, Supplier::STATUS_INACTIVE])],
            'payment_terms' => 'nullable|string|max:100',
            'credit_limit' => 'nullable|numeric|min:0',
        ]);

        $validated['name'] = $validated['name'] ?? $validated['company'];
        $supplier = Supplier::create($validated);
        return $this->success($supplier, 'Supplier created successfully', 201);
    }

    public function show(Supplier $supplier)
    {
        return $this->success($supplier->load('purchaseOrders:id,supplier_id,number,order_date,status,total_amount'));
    }

    public function update(Request $request, Supplier $supplier)
    {
        $validated = $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'company' => 'sometimes|required|string|max:255',
            'contact_person' => 'sometimes|required|string|max:255',
            'phone' => 'sometimes|required|string|max:50',
            'email' => 'sometimes|required|email|max:255',
            'address' => 'sometimes|required|string',
            'tax_number' => 'sometimes|required|string|max:50',
            'category' => 'sometimes|required|string|max:100',
            'registration_number' => 'nullable|string|max:100',
            'notes' => 'nullable|string',
            'status' => ['sometimes', Rule::in([Supplier::STATUS_ACTIVE, Supplier::STATUS_PENDING, Supplier::STATUS_INACTIVE])],
            'payment_terms' => 'nullable|string|max:100',
            'credit_limit' => 'nullable|numeric|min:0',
        ]);

        $supplier->update($validated);
        return $this->success($supplier->fresh(), 'Supplier updated successfully');
    }

    public function destroy(Supplier $supplier)
    {
        if ($supplier->purchaseOrders()->whereIn('status', ['Pending', 'Approved', 'Partially Received'])->exists()) {
            return $this->error('Supplier has open purchase orders and cannot be deleted.', 409);
        }

        $supplier->delete();
        return $this->success(null, 'Supplier deleted successfully');
    }

    public function uploadLogo(Request $request, Supplier $supplier)
    {
        $validated = $request->validate([
            'logo' => 'required|image|max:5120',
        ]);
        if ($supplier->logo_path) {
            Storage::disk('public')->delete($supplier->logo_path);
        }
        $path = $validated['logo']->store('supplier-logos', 'public');
        $supplier->update(['logo_path' => $path]);
        return $this->success($supplier->fresh(), 'Supplier logo uploaded successfully');
    }
}
