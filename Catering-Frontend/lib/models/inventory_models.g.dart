// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InventoryItem _$InventoryItemFromJson(Map<String, dynamic> json) =>
    InventoryItem(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      unit: json['unit'] as String,
      purchasePrice: (json['default_purchase_price'] as num).toDouble(),
      description: json['description'] as String,
      internalCost: (json['internal_cost'] as num?)?.toDouble(),
      minStock: (json['min_stock'] as num?)?.toInt(),
      maxStock: (json['max_stock'] as num?)?.toInt(),
      stockOnHand: (json['stock_on_hand'] as num?)?.toInt(),
      reorderPoint: (json['reorder_point'] as num?)?.toInt(),
      isActive: json['is_active'] as bool?,
      itemType: json['item_type'] as String?,
      shelfLifeDays: (json['shelf_life_days'] as num?)?.toInt(),
      requiresRefrigeration: json['requires_refrigeration'] as bool?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$InventoryItemToJson(InventoryItem instance) =>
    <String, dynamic>{
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
      outstandingBalance: (json['outstanding_balance'] as num).toDouble(),
      category: json['category'] as String? ?? '',
      registrationNumber: json['registration_number'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      paymentTerms: json['payment_terms'] as String? ?? '',
      creditLimit: (json['credit_limit'] as num?)?.toDouble(),
      logoPath: json['logo_path'] as String? ?? '',
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
      'category': instance.category,
      'registration_number': instance.registrationNumber,
      'notes': instance.notes,
      'payment_terms': instance.paymentTerms,
      'credit_limit': instance.creditLimit,
      'logo_path': instance.logoPath,
    };

PurchaseRecord _$PurchaseRecordFromJson(Map<String, dynamic> json) =>
    PurchaseRecord(
      id: json['id'] as String,
      number: json['number'] as String,
      supplier: json['supplier'] as String,
      date: DateTime.parse(json['order_date'] as String),
      item: json['item'] as String,
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: (json['unit_price'] as num).toDouble(),
      vat: (json['vat'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      status: json['status'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$PurchaseRecordToJson(PurchaseRecord instance) =>
    <String, dynamic>{
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

StockMovement _$StockMovementFromJson(Map<String, dynamic> json) =>
    StockMovement(
      id: json['id'] as String,
      item: json['item'] as String,
      type: json['type'] as String,
      quantity: (json['quantity'] as num).toInt(),
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String,
      performedBy: json['performed_by'] as String?,
    );

Map<String, dynamic> _$StockMovementToJson(StockMovement instance) =>
    <String, dynamic>{
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
      ingredients: (json['ingredients'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      foodCost: (json['food_cost'] as num).toDouble(),
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
      quantity: (json['quantity'] as num).toDouble(),
      estimatedCost: (json['estimated_cost'] as num).toDouble(),
      reason: json['reason'] as String,
      recordedBy: json['recorded_by'] as String,
      date: DateTime.parse(json['date'] as String),
      status: json['status'] as String,
      notes: json['notes'] as String,
    );

Map<String, dynamic> _$WasteRecordToJson(WasteRecord instance) =>
    <String, dynamic>{
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
      quantity: (json['quantity'] as num).toDouble(),
      expiryDate: DateTime.parse(json['expiry_date'] as String),
      batchNumber: json['batch_number'] as String,
      location: json['location'] as String,
      status: json['status'] as String,
    );

Map<String, dynamic> _$ExpiryItemToJson(ExpiryItem instance) =>
    <String, dynamic>{
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
      permissions: (json['permissions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
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

RecipeIngredient _$RecipeIngredientFromJson(Map<String, dynamic> json) =>
    RecipeIngredient(
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      unitCost: (json['unit_cost'] as num).toDouble(),
    );

Map<String, dynamic> _$RecipeIngredientToJson(RecipeIngredient instance) =>
    <String, dynamic>{
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
      servings: (json['servings'] as num).toInt(),
      ingredients: (json['ingredients'] as List<dynamic>)
          .map((e) => RecipeIngredient.fromJson(e as Map<String, dynamic>))
          .toList(),
      sellingPrice: (json['selling_price'] as num).toDouble(),
      prepTime: json['prep_time'] as String,
      status: json['status'] as String,
    );

Map<String, dynamic> _$RecipeItemToJson(RecipeItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'description': instance.description,
      'servings': instance.servings,
      'ingredients': instance.ingredients,
      'selling_price': instance.sellingPrice,
      'prep_time': instance.prepTime,
      'status': instance.status,
    };
