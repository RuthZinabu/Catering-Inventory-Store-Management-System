import 'package:json_annotation/json_annotation.dart';

part 'stock_models.g.dart';

// Unified stock model hierarchy
// StockItem (base) → FoodStockItem | CateringStockItem | ElectronicsStockItem

enum StockCategory { food, catering, electronics }

enum CateringSubtype { permanent, temporary }

// ── Stock movement entry ──────────────────────────────────────────────────────

@JsonSerializable()
class StockMovementEntry {
  final String id;
  @JsonKey(name: 'stock_item_id')
  final String stockItemId;
  final String
      type; // 'Stock In', 'Stock Out', 'Transfer', 'Adjustment', 'Return'
  final double quantity;
  final String unit;
  @JsonKey(name: 'performed_by')
  final String performedBy;
  final DateTime date;
  final String note;

  const StockMovementEntry({
    required this.id,
    required this.stockItemId,
    required this.type,
    required this.quantity,
    required this.unit,
    required this.performedBy,
    required this.date,
    required this.note,
  });

  factory StockMovementEntry.fromJson(Map<String, dynamic> json) =>
      _$StockMovementEntryFromJson(json);

  Map<String, dynamic> toJson() => _$StockMovementEntryToJson(this);
}

// ── Base stock item ───────────────────────────────────────────────────────────

@JsonSerializable()
class StockItem {
  final String id;
  final String code;
  final String name;
  final String category; // sub-category label (e.g. 'Meat', 'Tables')
  @JsonKey(name: 'stock_category')
  final StockCategory stockCategory;
  final String unit;
  @JsonKey(name: 'purchase_price', fromJson: _parseDouble)
  final double purchasePrice;
  @JsonKey(fromJson: _parseDouble)
  final double quantity; // current quantity on hand
  @JsonKey(name: 'min_quantity', fromJson: _parseDouble)
  final double minQuantity;
  @JsonKey(name: 'max_quantity', fromJson: _parseDouble)
  final double maxQuantity;
  final String location; // store / shelf
  final String supplier;
  final String status; // 'Healthy', 'Low Stock', 'Out of Stock'
  final String description;
  @JsonKey(name: 'last_updated')
  final DateTime lastUpdated;

  // Metadata fields for API operations
  @JsonKey(name: 'item_id')
  final String? itemId;
  @JsonKey(name: 'store_id')
  final String? storeId;

  const StockItem({
    required this.id,
    required this.code,
    required this.name,
    required this.category,
    required this.stockCategory,
    required this.unit,
    required this.purchasePrice,
    required this.quantity,
    required this.minQuantity,
    required this.maxQuantity,
    required this.location,
    required this.supplier,
    required this.status,
    required this.description,
    required this.lastUpdated,
    this.itemId,
    this.storeId,
  });

  double get totalValue => quantity * purchasePrice;
  double get stockFraction =>
      maxQuantity > 0 ? (quantity / maxQuantity).clamp(0.0, 1.0) : 0;

  factory StockItem.fromJson(Map<String, dynamic> json) =>
      _$StockItemFromJson(json);

  Map<String, dynamic> toJson() => _$StockItemToJson(this);
}

// ── Food stock item ───────────────────────────────────────────────────────────

@JsonSerializable()
class FoodStockItem extends StockItem {
  @JsonKey(name: 'expiry_date')
  final DateTime? expiryDate;
  @JsonKey(name: 'batch_number')
  final String batchNumber;
  @JsonKey(name: 'requires_refrigeration')
  final bool requiresRefrigeration;

  const FoodStockItem({
    required super.id,
    required super.code,
    required super.name,
    required super.category,
    required super.unit,
    required super.purchasePrice,
    required super.quantity,
    required super.minQuantity,
    required super.maxQuantity,
    required super.location,
    required super.supplier,
    required super.status,
    required super.description,
    required super.lastUpdated,
    super.itemId,
    super.storeId,
    this.expiryDate,
    required this.batchNumber,
    this.requiresRefrigeration = false,
  }) : super(stockCategory: StockCategory.food);

  String get expiryStatus {
    if (expiryDate == null) return 'N/A';
    final diff = expiryDate!.difference(DateTime.now()).inDays;
    if (diff < 0) return 'Expired';
    if (diff <= 7) return 'Expiring Soon';
    return 'OK';
  }

  factory FoodStockItem.fromJson(Map<String, dynamic> json) =>
      _$FoodStockItemFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$FoodStockItemToJson(this);
}

// ── Catering stock item ───────────────────────────────────────────────────────

@JsonSerializable()
class CateringStockItem extends StockItem {
  final CateringSubtype subtype; // permanent | temporary
  // Permanent-specific
  final String? condition; // 'Good', 'Fair', 'Needs Repair'
  @JsonKey(name: 'is_reserved')
  final bool? isReserved;
  @JsonKey(name: 'reserved_for')
  final String? reservedFor; // event name
  // Temporary-specific
  @JsonKey(name: 'pack_size')
  final int? packSize; // units per pack
  @JsonKey(name: 'consumption_rate')
  final String? consumptionRate; // e.g. '50 pcs/event'

  const CateringStockItem({
    required super.id,
    required super.code,
    required super.name,
    required super.category,
    required super.unit,
    required super.purchasePrice,
    required super.quantity,
    required super.minQuantity,
    required super.maxQuantity,
    required super.location,
    required super.supplier,
    required super.status,
    required super.description,
    required super.lastUpdated,
    super.itemId,
    super.storeId,
    required this.subtype,
    this.condition,
    this.isReserved,
    this.reservedFor,
    this.packSize,
    this.consumptionRate,
  }) : super(stockCategory: StockCategory.catering);

  factory CateringStockItem.fromJson(Map<String, dynamic> json) =>
      _$CateringStockItemFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CateringStockItemToJson(this);
}

// ── Electronics stock item ────────────────────────────────────────────────────

@JsonSerializable()
class ElectronicsStockItem extends StockItem {
  final String brand;
  final String model;
  @JsonKey(name: 'serial_number')
  final String serialNumber;
  @JsonKey(name: 'warranty_expiry')
  final DateTime? warrantyExpiry;
  @JsonKey(name: 'maintenance_status')
  final String maintenanceStatus; // 'OK', 'Due', 'Overdue'
  @JsonKey(name: 'last_maintenance_date')
  final DateTime? lastMaintenanceDate;
  @JsonKey(name: 'asset_tag')
  final String assetTag;

  const ElectronicsStockItem({
    required super.id,
    required super.code,
    required super.name,
    required super.category,
    required super.unit,
    required super.purchasePrice,
    required super.quantity,
    required super.minQuantity,
    required super.maxQuantity,
    required super.location,
    required super.supplier,
    required super.status,
    required super.description,
    required super.lastUpdated,
    super.itemId,
    super.storeId,
    required this.brand,
    required this.model,
    required this.serialNumber,
    this.warrantyExpiry,
    required this.maintenanceStatus,
    this.lastMaintenanceDate,
    required this.assetTag,
  }) : super(stockCategory: StockCategory.electronics);

  String get warrantyStatus {
    if (warrantyExpiry == null) return 'No Warranty';
    final diff = warrantyExpiry!.difference(DateTime.now()).inDays;
    if (diff < 0) return 'Expired';
    if (diff <= 30) return 'Expiring Soon';
    return 'Active';
  }

  factory ElectronicsStockItem.fromJson(Map<String, dynamic> json) =>
      _$ElectronicsStockItemFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ElectronicsStockItemToJson(this);
}

// Helper function for safe double parsing
Map<String, dynamic> normalizeStockItemJson(Map<String, dynamic> json) {
  final item = json['item'] is Map
      ? Map<String, dynamic>.from(json['item'] as Map)
      : const <String, dynamic>{};
  final store = json['store'] is Map
      ? Map<String, dynamic>.from(json['store'] as Map)
      : const <String, dynamic>{};
  final supplier = item['supplier'] is Map
      ? Map<String, dynamic>.from(item['supplier'] as Map)
      : const <String, dynamic>{};
  final itemType =
      json['stock_category'] ?? json['item_type'] ?? item['item_type'];
  final category = StockCategory.values.any((value) => value.name == itemType)
      ? itemType as String
      : StockCategory.food.name;

  return {
    ...item,
    ...json,
    'id': json['id'] ?? json['item_id'] ?? '',
    'code': json['code'] ?? item['code'] ?? '',
    'name': json['name'] ?? item['name'] ?? '',
    'category': json['category'] ?? item['category'] ?? '',
    'stock_category': category,
    'unit': json['unit'] ?? item['unit'] ?? '',
    'purchase_price': json['purchase_price'] ??
        json['current_cost'] ??
        item['default_purchase_price'] ??
        0,
    'quantity': json['quantity'] ?? 0,
    'min_quantity': json['min_quantity'] ?? 0,
    'max_quantity': json['max_quantity'] ?? 0,
    'location':
        json['location'] ?? json['location_description'] ?? store['name'] ?? '',
    'supplier': json['supplier'] ??
        supplier['company'] ??
        supplier['name'] ??
        'Unknown',
    'status': json['status'] ?? 'Unknown',
    'description': json['description'] ?? item['description'] ?? '',
    'last_updated': json['last_updated'] ??
        json['updated_at'] ??
        json['created_at'] ??
        DateTime.now().toIso8601String(),
    'batch_number': json['batch_number'] ?? '',
    'requires_refrigeration': json['requires_refrigeration'] ??
        item['requires_refrigeration'] ??
        false,
    'subtype': json['subtype'] ??
        json['catering_subtype'] ??
        item['catering_subtype'] ??
        'permanent',
    'brand': json['brand'] ?? item['brand'] ?? '',
    'model': json['model'] ?? item['model'] ?? '',
    'serial_number': json['serial_number'] ?? '',
    'maintenance_status': json['maintenance_status'] ?? 'Unknown',
    'asset_tag': json['asset_tag'] ?? '',
  };
}

Map<String, dynamic> normalizeStockMovementJson(Map<String, dynamic> json) {
  return {
    ...json,
    'stock_item_id': json['stock_item_id'] ?? json['item_id'] ?? '',
    'quantity': _parseDouble(json['quantity']),
    'performed_by': json['performed_by']?.toString() ?? 'System',
    'date':
        json['date'] ?? json['created_at'] ?? DateTime.now().toIso8601String(),
    'note': json['note'] ?? '',
  };
}

double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}
