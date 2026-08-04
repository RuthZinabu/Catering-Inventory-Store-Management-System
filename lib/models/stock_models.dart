// Unified stock model hierarchy
// StockItem (base) → FoodStockItem | CateringStockItem | ElectronicsStockItem

enum StockCategory { food, catering, electronics }

enum CateringSubtype { permanent, temporary }

// ── Stock movement entry ──────────────────────────────────────────────────────

class StockMovementEntry {
  final String id;
  final String stockItemId;
  final String type; // 'Stock In', 'Stock Out', 'Transfer', 'Adjustment', 'Return'
  final double quantity;
  final String unit;
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
}

// ── Base stock item ───────────────────────────────────────────────────────────

class StockItem {
  final String id;
  final String code;
  final String name;
  final String category;       // sub-category label (e.g. 'Meat', 'Tables')
  final StockCategory stockCategory;
  final String unit;
  final double purchasePrice;
  final double quantity;       // current quantity on hand
  final double minQuantity;
  final double maxQuantity;
  final String location;       // store / shelf
  final String supplier;
  final String status;         // 'Healthy', 'Low Stock', 'Out of Stock'
  final String description;
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
  double get stockFraction => maxQuantity > 0 ? (quantity / maxQuantity).clamp(0.0, 1.0) : 0;
}

// ── Food stock item ───────────────────────────────────────────────────────────

class FoodStockItem extends StockItem {
  final DateTime? expiryDate;
  final String batchNumber;
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
}

// ── Catering stock item ───────────────────────────────────────────────────────

class CateringStockItem extends StockItem {
  final CateringSubtype subtype; // permanent | temporary
  // Permanent-specific
  final String? condition;       // 'Good', 'Fair', 'Needs Repair'
  final bool? isReserved;
  final String? reservedFor;     // event name
  // Temporary-specific
  final int? packSize;           // units per pack
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
}

// ── Electronics stock item ────────────────────────────────────────────────────

class ElectronicsStockItem extends StockItem {
  final String brand;
  final String model;
  final String serialNumber;
  final DateTime? warrantyExpiry;
  final String maintenanceStatus; // 'OK', 'Due', 'Overdue'
  final DateTime? lastMaintenanceDate;
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
}
