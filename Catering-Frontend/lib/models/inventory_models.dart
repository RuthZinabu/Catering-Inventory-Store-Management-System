import 'package:json_annotation/json_annotation.dart';

part 'inventory_models.g.dart';

@JsonSerializable()
class InventoryItem {
  final String id;
  final String code;
  final String name;
  final String category;
  final String unit;
  @JsonKey(name: 'default_purchase_price', fromJson: _parseDouble)
  final double purchasePrice;
  @JsonKey(name: 'internal_cost', fromJson: _parseDoubleOptional)
  final double? internalCost;
  @JsonKey(name: 'min_stock', fromJson: _parseIntOptional)
  final int? minStock;
  @JsonKey(name: 'max_stock', fromJson: _parseIntOptional)
  final int? maxStock;
  final String description;
  @JsonKey(name: 'stock_on_hand', fromJson: _parseIntOptional)
  final int? stockOnHand;
  @JsonKey(name: 'reorder_point', fromJson: _parseIntOptional)
  final int? reorderPoint;
  @JsonKey(name: 'is_active', fromJson: _parseBoolOptional)
  final bool? isActive;
  @JsonKey(name: 'item_type')
  final String? itemType;
  @JsonKey(name: 'shelf_life_days', fromJson: _parseIntOptional)
  final int? shelfLifeDays;
  @JsonKey(name: 'requires_refrigeration', fromJson: _parseBoolOptional)
  final bool? requiresRefrigeration;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  const InventoryItem({
    required this.id,
    required this.code,
    required this.name,
    required this.category,
    required this.unit,
    required this.purchasePrice,
    required this.description,
    this.internalCost,
    this.minStock,
    this.maxStock,
    this.stockOnHand,
    this.reorderPoint,
    this.isActive,
    this.itemType,
    this.shelfLifeDays,
    this.requiresRefrigeration,
    this.createdAt,
    this.updatedAt,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) =>
      _$InventoryItemFromJson(json);

  Map<String, dynamic> toJson() => _$InventoryItemToJson(this);

  InventoryItem copyWith({
    String? id,
    String? code,
    String? name,
    String? category,
    String? unit,
    double? purchasePrice,
    double? internalCost,
    int? minStock,
    int? maxStock,
    String? description,
    int? stockOnHand,
    int? reorderPoint,
    bool? isActive,
    String? itemType,
    int? shelfLifeDays,
    bool? requiresRefrigeration,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      internalCost: internalCost ?? this.internalCost,
      minStock: minStock ?? this.minStock,
      maxStock: maxStock ?? this.maxStock,
      description: description ?? this.description,
      stockOnHand: stockOnHand ?? this.stockOnHand,
      reorderPoint: reorderPoint ?? this.reorderPoint,
      isActive: isActive ?? this.isActive,
      itemType: itemType ?? this.itemType,
      shelfLifeDays: shelfLifeDays ?? this.shelfLifeDays,
      requiresRefrigeration:
          requiresRefrigeration ?? this.requiresRefrigeration,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Computed properties with defaults for missing fields
  String get status => isActive == true ? 'Active' : 'Inactive';
  int get minStockValue => minStock ?? 0;
  int get maxStockValue => maxStock ?? 0;
  int get stockOnHandValue => stockOnHand ?? 0;
  int get reorderPointValue => reorderPoint ?? 0;
  double get internalCostValue => internalCost ?? purchasePrice;
}

@JsonSerializable()
class Supplier {
  final String id;
  final String name;
  final String company;
  @JsonKey(name: 'contact_person')
  final String contactPerson;
  final String phone;
  final String email;
  final String address;
  @JsonKey(name: 'tax_number')
  final String taxNumber;
  final String status;
  @JsonKey(name: 'outstanding_balance', fromJson: _parseDouble)
  final double outstandingBalance;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  const Supplier({
    required this.id,
    required this.name,
    required this.company,
    required this.contactPerson,
    required this.phone,
    required this.email,
    required this.address,
    required this.taxNumber,
    required this.status,
    required this.outstandingBalance,
    this.createdAt,
    this.updatedAt,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) =>
      _$SupplierFromJson(json);

  Map<String, dynamic> toJson() => _$SupplierToJson(this);
}

@JsonSerializable()
class PurchaseRecord {
  final String id;
  final String number;
  final String supplier;
  @JsonKey(name: 'order_date')
  final DateTime date;
  final String item;
  @JsonKey(fromJson: _parseInt)
  final int quantity;
  @JsonKey(name: 'unit_price', fromJson: _parseDouble)
  final double unitPrice;
  @JsonKey(fromJson: _parseDouble)
  final double vat;
  @JsonKey(fromJson: _parseDouble)
  final double discount;
  @JsonKey(fromJson: _parseDouble)
  final double total;
  final String? status;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  const PurchaseRecord({
    required this.id,
    required this.number,
    required this.supplier,
    required this.date,
    required this.item,
    required this.quantity,
    required this.unitPrice,
    required this.vat,
    required this.discount,
    required this.total,
    this.status,
    this.createdAt,
  });

  factory PurchaseRecord.fromJson(Map<String, dynamic> json) =>
      _$PurchaseRecordFromJson(json);

  Map<String, dynamic> toJson() => _$PurchaseRecordToJson(this);
}

@JsonSerializable()
class StockMovement {
  final String id;
  final String item;
  final String type;
  @JsonKey(fromJson: _parseInt)
  final int quantity;
  final DateTime date;
  final String note;
  @JsonKey(name: 'performed_by')
  final String? performedBy;

  const StockMovement({
    required this.id,
    required this.item,
    required this.type,
    required this.quantity,
    required this.date,
    required this.note,
    this.performedBy,
  });

  factory StockMovement.fromJson(Map<String, dynamic> json) =>
      _$StockMovementFromJson(json);

  Map<String, dynamic> toJson() => _$StockMovementToJson(this);
}

@JsonSerializable()
class Recipe {
  final String id;
  final String name;
  final String description;
  final List<String> ingredients;
  @JsonKey(name: 'food_cost', fromJson: _parseDouble)
  final double foodCost;

  const Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.ingredients,
    required this.foodCost,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) => _$RecipeFromJson(json);

  Map<String, dynamic> toJson() => _$RecipeToJson(this);
}

@JsonSerializable()
class AlertItem {
  final String id;
  final String title;
  final String detail;
  final DateTime date;
  final String severity;
  final String? type;
  @JsonKey(name: 'is_read')
  final bool? isRead;

  const AlertItem({
    required this.id,
    required this.title,
    required this.detail,
    required this.date,
    required this.severity,
    this.type,
    this.isRead,
  });

  DateTime get createdAt => date;

  factory AlertItem.fromJson(Map<String, dynamic> json) =>
      _$AlertItemFromJson(json);

  Map<String, dynamic> toJson() => _$AlertItemToJson(this);
}

@JsonSerializable()
class WasteRecord {
  final String id;
  final String number;
  final String item;
  final String category;
  final String unit;
  @JsonKey(fromJson: _parseDouble)
  final double quantity;
  @JsonKey(name: 'estimated_cost', fromJson: _parseDouble)
  final double estimatedCost;
  final String reason;
  @JsonKey(name: 'recorded_by')
  final String recordedBy;
  final DateTime date;
  final String status;
  final String notes;

  const WasteRecord({
    required this.id,
    required this.number,
    required this.item,
    required this.category,
    required this.unit,
    required this.quantity,
    required this.estimatedCost,
    required this.reason,
    required this.recordedBy,
    required this.date,
    required this.status,
    required this.notes,
  });

  factory WasteRecord.fromJson(Map<String, dynamic> json) =>
      _$WasteRecordFromJson(json);

  Map<String, dynamic> toJson() => _$WasteRecordToJson(this);
}

@JsonSerializable()
class ExpiryItem {
  final String id;
  final String item;
  final String category;
  final String unit;
  @JsonKey(fromJson: _parseDouble)
  final double quantity;
  @JsonKey(name: 'expiry_date')
  final DateTime expiryDate;
  @JsonKey(name: 'batch_number')
  final String batchNumber;
  final String location;
  final String status; // 'Expired', 'Expiring Soon', 'OK'

  const ExpiryItem({
    required this.id,
    required this.item,
    required this.category,
    required this.unit,
    required this.quantity,
    required this.expiryDate,
    required this.batchNumber,
    required this.location,
    required this.status,
  });

  factory ExpiryItem.fromJson(Map<String, dynamic> json) =>
      _$ExpiryItemFromJson(json);

  Map<String, dynamic> toJson() => _$ExpiryItemToJson(this);
}

@JsonSerializable()
class AppUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String department;
  final String status; // 'Active', 'Inactive', 'Suspended'
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'last_login')
  final String lastLogin;
  final List<String> permissions;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.department,
    required this.status,
    required this.createdAt,
    required this.lastLogin,
    required this.permissions,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);
    normalized['phone'] ??= '';
    normalized['department'] ??= '';
    normalized['last_login'] ??=
        normalized['last_login_at']?.toString() ?? 'Never';
    normalized['permissions'] ??= <String>[];
    return _$AppUserFromJson(normalized);
  }

  Map<String, dynamic> toJson() => _$AppUserToJson(this);
}

@JsonSerializable()
class RecipeIngredient {
  final String name;
  @JsonKey(fromJson: _parseDouble)
  final double quantity;
  final String unit;
  @JsonKey(name: 'unit_cost', fromJson: _parseDouble)
  final double unitCost;

  const RecipeIngredient({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.unitCost,
  });

  double get totalCost => quantity * unitCost;

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) =>
      _$RecipeIngredientFromJson(json);

  Map<String, dynamic> toJson() => _$RecipeIngredientToJson(this);
}

@JsonSerializable()
class RecipeItem {
  final String id;
  final String name;
  final String category;
  final String description;
  @JsonKey(fromJson: _parseInt)
  final int servings;
  final List<RecipeIngredient> ingredients;
  @JsonKey(name: 'selling_price', fromJson: _parseDouble)
  final double sellingPrice;
  @JsonKey(name: 'prep_time')
  final String prepTime;
  final String status; // 'Active', 'Inactive'

  const RecipeItem({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.servings,
    required this.ingredients,
    required this.sellingPrice,
    required this.prepTime,
    required this.status,
  });

  double get totalFoodCost =>
      ingredients.fold(0, (sum, i) => sum + i.totalCost);

  double get foodCostPercentage =>
      sellingPrice > 0 ? (totalFoodCost / sellingPrice) * 100 : 0;

  factory RecipeItem.fromJson(Map<String, dynamic> json) =>
      _$RecipeItemFromJson(json);

  Map<String, dynamic> toJson() => _$RecipeItemToJson(this);
}
