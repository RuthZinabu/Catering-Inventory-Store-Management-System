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
  @JsonKey(name: 'purchase_price')
  final double purchasePrice;
  final double quantity; // current quantity on hand
  @JsonKey(name: 'min_quantity')
  final double minQuantity;
  @JsonKey(name: 'max_quantity')
  final double maxQuantity;
  final String location; // store / shelf
  final String supplier;
  final String status; // 'Healthy', 'Low Stock', 'Out of Stock'
  final String description;
  @JsonKey(name: 'last_updated')
  final DateTime lastUpdated;

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
