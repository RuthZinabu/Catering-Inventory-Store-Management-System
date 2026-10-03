// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

// Helper functions to parse strings and numbers
double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

double? _parseDoubleOptional(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

int? _parseIntOptional(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

bool? _parseBoolOptional(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is int) return value != 0;
  if (value is String) return value.toLowerCase() == 'true' || value == '1';
  return null;
}

InventoryItem _$InventoryItemFromJson(Map<String, dynamic> json) => InventoryItem(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      unit: json['unit'] as String,
      purchasePrice: _parseDouble(json['default_purchase_price']),
      description: json['description'] as String,
      internalCost: _parseDoubleOptional(json['internal_cost']),
      minStock: _parseIntOptional(json['min_stock']),
      maxStock: _parseIntOptional(json['max_stock']),
      stockOnHand: _parseIntOptional(json['stock_on_hand']),
      reorderPoint: _parseIntOptional(json['reorder_point']),
      isActive: _parseBoolOptional(json['is_active']),
      itemType: json['item_type'] as String?,
      shelfLifeDays: json['shelf_life_days'] as int?,
      requiresRefrigeration: json['requires_refrigeration'] as bool?,
      createdAt: json['created_at'] == null ? null : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null ? null : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$InventoryItemToJson(InventoryItem instance) => <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'category': instance.category,
      'unit': instance.unit,
      'default_purchase_price': instance.purchasePrice,
      'internal_cost': instance.internalCost,
      'min_stock': instance.minStock,
      'max_stock': instance.maxStock,
      'description': instance.description,
      'stock_on_hand': instance.stockOnHand,
      'reorder_point': instance.reorderPoint,
      'is_active': instance.isActive,
      'item_type': instance.itemType,
      'shelf_life_days': instance.shelfLifeDays,
      'requires_refrigeration': instance.requiresRefrigeration,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

Supplier _$SupplierFromJson(Map<String, dynamic> json) => Supplier(
      id: json['id'] as String,
      name: json['name'] as String,
      company: json['company'] as String,
      contactPerson: json['contact_person'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      address: json['address'] as String,
      taxNumber: json['tax_number'] as String,
      status: json['status'] as String,
      outstandingBalance: _parseDouble(json['outstanding_balance']),
      createdAt: json['created_at'] == null ? null : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null ? null : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$SupplierToJson(Supplier instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'company': instance.company,
      'contact_person': instance.contactPerson,
      'phone': instance.phone,
      'email': instance.email,
      'address': instance.address,
      'tax_number': instance.taxNumber,
      'status': instance.status,
      'outstanding_balance': instance.outstandingBalance,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

PurchaseRecord _$PurchaseRecordFromJson(Map<String, dynamic> json) => PurchaseRecord(
      id: json['id'] as String,
      number: json['number'] as String,
      supplier: json['supplier'] as String,
      date: DateTime.parse(json['order_date'] as String),
      item: json['item'] as String,
      quantity: _parseInt(json['quantity']),
      unitPrice: _parseDouble(json['unit_price']),
      vat: _parseDouble(json['vat']),
      discount: _parseDouble(json['discount']),
      total: _parseDouble(json['total']),
      status: json['status'] as String?,
      createdAt: json['created_at'] == null ? null : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$PurchaseRecordToJson(PurchaseRecord instance) => <String, dynamic>{
      'id': instance.id,
      'number': instance.number,
      'supplier': instance.supplier,
      'order_date': instance.date.toIso8601String(),
      'item': instance.item,
      'quantity': instance.quantity,
      'unit_price': instance.unitPrice,
      'vat': instance.vat,
      'discount': instance.discount,
      'total': instance.total,
      'status': instance.status,
      'created_at': instance.createdAt?.toIso8601String(),
    };

StockMovement _$StockMovementFromJson(Map<String, dynamic> json) => StockMovement(
      id: json['id'] as String,
      item: json['item'] as String,
      type: json['type'] as String,
      quantity: _parseInt(json['quantity']),
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String,
      performedBy: json['performed_by'] as String?,
    );

Map<String, dynamic> _$StockMovementToJson(StockMovement instance) => <String, dynamic>{
      'id': instance.id,
      'item': instance.item,
      'type': instance.type,
      'quantity': instance.quantity,
      'date': instance.date.toIso8601String(),
      'note': instance.note,
      'performed_by': instance.performedBy,
    };

Recipe _$RecipeFromJson(Map<String, dynamic> json) => Recipe(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      ingredients: (json['ingredients'] as List<dynamic>).map((e) => e as String).toList(),
      foodCost: _parseDouble(json['food_cost']),
    );

Map<String, dynamic> _$RecipeToJson(Recipe instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'ingredients': instance.ingredients,
      'food_cost': instance.foodCost,
    };

AlertItem _$AlertItemFromJson(Map<String, dynamic> json) => AlertItem(
      id: json['id'] as String,
      title: json['title'] as String,
      detail: json['detail'] as String,
      date: DateTime.parse(json['date'] as String),
      severity: json['severity'] as String,
      type: json['type'] as String?,
      isRead: json['is_read'] as bool?,
    );

Map<String, dynamic> _$AlertItemToJson(AlertItem instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'detail': instance.detail,
      'date': instance.date.toIso8601String(),
      'severity': instance.severity,
      'type': instance.type,
      'is_read': instance.isRead,
    };

WasteRecord _$WasteRecordFromJson(Map<String, dynamic> json) => WasteRecord(
      id: json['id'] as String,
      number: json['number'] as String,
      item: json['item'] as String,
      category: json['category'] as String,
      unit: json['unit'] as String,
      quantity: _parseDouble(json['quantity']),
      estimatedCost: _parseDouble(json['estimated_cost']),
      reason: json['reason'] as String,
      recordedBy: json['recorded_by'] as String,
      date: DateTime.parse(json['date'] as String),
      status: json['status'] as String,
      notes: json['notes'] as String,
    );

Map<String, dynamic> _$WasteRecordToJson(WasteRecord instance) => <String, dynamic>{
      'id': instance.id,
      'number': instance.number,
      'item': instance.item,
      'category': instance.category,
      'unit': instance.unit,
      'quantity': instance.quantity,
      'estimated_cost': instance.estimatedCost,
      'reason': instance.reason,
      'recorded_by': instance.recordedBy,
      'date': instance.date.toIso8601String(),
      'status': instance.status,
      'notes': instance.notes,
    };

ExpiryItem _$ExpiryItemFromJson(Map<String, dynamic> json) => ExpiryItem(
      id: json['id'] as String,
      item: json['item'] as String,
      category: json['category'] as String,
      unit: json['unit'] as String,
      quantity: _parseDouble(json['quantity']),
      expiryDate: DateTime.parse(json['expiry_date'] as String),
      batchNumber: json['batch_number'] as String,
      location: json['location'] as String,
      status: json['status'] as String,
    );

Map<String, dynamic> _$ExpiryItemToJson(ExpiryItem instance) => <String, dynamic>{
      'id': instance.id,
      'item': instance.item,
      'category': instance.category,
      'unit': instance.unit,
      'quantity': instance.quantity,
      'expiry_date': instance.expiryDate.toIso8601String(),
      'batch_number': instance.batchNumber,
      'location': instance.location,
      'status': instance.status,
    };

AppUser _$AppUserFromJson(Map<String, dynamic> json) => AppUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      role: json['role'] as String,
      department: json['department'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastLogin: json['last_login'] as String,
      permissions: (json['permissions'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$AppUserToJson(AppUser instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'role': instance.role,
      'department': instance.department,
      'status': instance.status,
      'created_at': instance.createdAt.toIso8601String(),
      'last_login': instance.lastLogin,
      'permissions': instance.permissions,
    };

RecipeIngredient _$RecipeIngredientFromJson(Map<String, dynamic> json) => RecipeIngredient(
      name: json['name'] as String,
      quantity: _parseDouble(json['quantity']),
      unit: json['unit'] as String,
      unitCost: _parseDouble(json['unit_cost']),
    );

Map<String, dynamic> _$RecipeIngredientToJson(RecipeIngredient instance) => <String, dynamic>{
      'name': instance.name,
      'quantity': instance.quantity,
      'unit': instance.unit,
      'unit_cost': instance.unitCost,
    };

RecipeItem _$RecipeItemFromJson(Map<String, dynamic> json) => RecipeItem(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      servings: _parseInt(json['servings']),
      ingredients: (json['ingredients'] as List<dynamic>)
          .map((e) => RecipeIngredient.fromJson(e as Map<String, dynamic>))
          .toList(),
      sellingPrice: _parseDouble(json['selling_price']),
      prepTime: json['prep_time'] as String,
      status: json['status'] as String,
    );

Map<String, dynamic> _$RecipeItemToJson(RecipeItem instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'description': instance.description,
      'servings': instance.servings,
      'ingredients': instance.ingredients.map((e) => e.toJson()).toList(),
      'selling_price': instance.sellingPrice,
      'prep_time': instance.prepTime,
      'status': instance.status,
    };