import '../models/inventory_models.dart';

class MockRepository {
  static final List<InventoryItem> items = [
    const InventoryItem(
      id: '1',
      code: 'CH-001',
      name: 'Chicken Breast',
      category: 'Meat',
      unit: 'Kg',
      purchasePrice: 135.0,
      internalCost: 145.0,
      minStock: 20,
      maxStock: 120,
      description: 'Fresh boneless chicken for kitchen production.',
      stockOnHand: 48,
      reorderPoint: 24,
      status: 'Healthy',
    ),
    const InventoryItem(
      id: '2',
      code: 'RI-002',
      name: 'Basmati Rice',
      category: 'Dry Food',
      unit: 'Kg',
      purchasePrice: 95.0,
      internalCost: 105.0,
      minStock: 30,
      maxStock: 200,
      description: 'Premium rice for bulk meal service.',
      stockOnHand: 14,
      reorderPoint: 18,
      status: 'Low Stock',
    ),
    const InventoryItem(
      id: '3',
      code: 'DA-003',
      name: 'Milk Powder',
      category: 'Dairy',
      unit: 'Bag',
      purchasePrice: 420.0,
      internalCost: 450.0,
      minStock: 10,
      maxStock: 60,
      description: 'Used for desserts and beverage preparation.',
      stockOnHand: 63,
      reorderPoint: 10,
      status: 'Healthy',
    ),
  ];

  static final List<Supplier> suppliers = [
    const Supplier(
      id: 's1',
      name: 'Mulu Bekele',
      company: 'Fresh Foods PLC',
      contactPerson: 'Mulu Bekele',
      phone: '+251911223344',
      email: 'mulu@freshfoods.et',
      address: 'Addis Ababa',
      taxNumber: 'TAX-1001',
      status: 'Active',
      outstandingBalance: 12000,
    ),
    const Supplier(
      id: 's2',
      name: 'Daniel Tesfaye',
      company: 'Urban Pantry',
      contactPerson: 'Daniel Tesfaye',
      phone: '+251922334455',
      email: 'daniel@urbanpantry.et',
      address: 'Bole',
      taxNumber: 'TAX-2002',
      status: 'Pending',
      outstandingBalance: 6400,
    ),
  ];

  static final List<PurchaseRecord> purchases = [
    PurchaseRecord(
      id: 'p1',
      number: 'PO-1048',
      supplier: 'Fresh Foods PLC',
      date: DateTime(2026, 7, 22),
      item: 'Chicken Breast',
      quantity: 40,
      unitPrice: 135,
      vat: 1080,
      discount: 200,
      total: 5400,
    ),
    PurchaseRecord(
      id: 'p2',
      number: 'PO-1049',
      supplier: 'Urban Pantry',
      date: DateTime(2026, 7, 23),
      item: 'Basmati Rice',
      quantity: 25,
      unitPrice: 95,
      vat: 712.5,
      discount: 0,
      total: 2375,
    ),
  ];

  static final List<StockMovement> movements = [
    StockMovement(
      id: 'm1',
      item: 'Chicken Breast',
      type: 'Purchase',
      quantity: 40,
      date: DateTime(2026, 7, 22),
      note: 'Received purchase order PO-1048',
    ),
    StockMovement(
      id: 'm2',
      item: 'Basmati Rice',
      type: 'Kitchen Issue',
      quantity: 8,
      date: DateTime(2026, 7, 24),
      note: 'Issued to kitchen for buffet service',
    ),
    StockMovement(
      id: 'm3',
      item: 'Milk Powder',
      type: 'Waste',
      quantity: 2,
      date: DateTime(2026, 7, 20),
      note: 'Damaged packaging',
    ),
  ];

  static final List<Recipe> recipes = [
    const Recipe(
      id: 'r1',
      name: 'Chicken Curry',
      description: 'Signature catering chicken curry with fresh spices.',
      ingredients: ['Chicken — 2 Kg', 'Onion — 1 Kg', 'Tomato — 0.5 Kg', 'Oil — 0.25 L', 'Salt — 0.05 Kg'],
      foodCost: 480.0,
    ),
    const Recipe(
      id: 'r2',
      name: 'Vegetable Pilaf',
      description: 'Mixed rice dish with fresh vegetables.',
      ingredients: ['Rice — 1.5 Kg', 'Carrot — 0.4 Kg', 'Peas — 0.3 Kg', 'Oil — 0.1 L'],
      foodCost: 220.0,
    ),
  ];

  static final List<AlertItem> alerts = [
    AlertItem(
      id: 'a1',
      title: 'Low stock alert',
      detail: 'Basmati Rice is below reorder level.',
      date: DateTime(2026, 7, 24),
      severity: 'High',
    ),
    AlertItem(
      id: 'a2',
      title: 'Expiry upcoming',
      detail: 'Milk Powder expires in 3 days.',
      date: DateTime(2026, 7, 24),
      severity: 'Medium',
    ),
  ];
}
