class KitchenIssueViewModel {
  final String id;
  final String storeId;
  final String store;
  final String number;
  final String department;
  final String kitchen;
  final String requestedBy;
  final String approvedBy;
  final String issueDate;
  final String status;
  final int itemsIssued;
  final double totalQuantity;
  final String notes;
  final List<KitchenIssueIngredientViewModel> ingredients;

  const KitchenIssueViewModel({
    required this.id,
    required this.storeId,
    required this.store,
    required this.number,
    required this.department,
    required this.kitchen,
    required this.requestedBy,
    required this.approvedBy,
    required this.issueDate,
    required this.status,
    required this.itemsIssued,
    required this.totalQuantity,
    required this.ingredients,
    this.notes = '',
  });

  factory KitchenIssueViewModel.fromJson(Map<String, dynamic> json) {
    final ingredients = json['ingredients'] as List? ?? const [];
    return KitchenIssueViewModel(
      id: json['id'] as String? ?? '',
      storeId: json['store_id'] as String? ?? '',
      store: json['store'] as String? ?? '',
      number: json['number'] as String? ?? '',
      department: json['department'] as String? ?? '',
      kitchen: json['kitchen'] as String? ?? '',
      requestedBy: json['requested_by'] as String? ?? '',
      approvedBy: json['approved_by'] as String? ?? '',
      issueDate: json['issue_date']?.toString() ?? '',
      status: json['status'] as String? ?? 'Pending Approval',
      itemsIssued: (json['items_issued'] as num?)?.toInt() ?? ingredients.length,
      totalQuantity: _parseKitchenNumber(json['total_quantity']),
      notes: json['notes'] as String? ?? '',
      ingredients: ingredients
          .map((item) => KitchenIssueIngredientViewModel.fromJson(
              Map<String, dynamic>.from(item as Map)))
          .toList(),
    );
  }
}

class KitchenIssueIngredientViewModel {
  final String itemId;
  final String name;
  final String category;
  final String unit;
  final double availableStock;
  final double quantity;
  final double quantityIssued;

  const KitchenIssueIngredientViewModel({
    required this.itemId,
    required this.name,
    required this.category,
    required this.unit,
    required this.availableStock,
    required this.quantity,
    this.quantityIssued = 0,
  });

  factory KitchenIssueIngredientViewModel.fromJson(Map<String, dynamic> json) {
    return KitchenIssueIngredientViewModel(
      itemId: json['item_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
      availableStock: _parseKitchenNumber(json['available_stock']),
      quantity: _parseKitchenNumber(json['quantity']),
      quantityIssued: _parseKitchenNumber(json['quantity_issued']),
    );
  }
}

double _parseKitchenNumber(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}
