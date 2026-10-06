// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StockMovementEntry _$StockMovementEntryFromJson(Map<String, dynamic> json) =>
    StockMovementEntry(
      id: json['id'] as String,
      stockItemId: json['stock_item_id'] as String,
      type: json['type'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      performedBy: json['performed_by'] as String,
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String,
    );

Map<String, dynamic> _$StockMovementEntryToJson(StockMovementEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'stock_item_id': instance.stockItemId,
      'type': instance.type,
      'quantity': instance.quantity,
      'unit': instance.unit,
      'performed_by': instance.performedBy,
      'date': instance.date.toIso8601String(),
      'note': instance.note,
    };

StockItem _$StockItemFromJson(Map<String, dynamic> json) => StockItem(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      stockCategory:
          $enumDecode(_$StockCategoryEnumMap, json['stock_category']),
      unit: json['unit'] as String,
      purchasePrice: _parseDouble(json['purchase_price']),
      quantity: _parseDouble(json['quantity']),
      minQuantity: _parseDouble(json['min_quantity']),
      maxQuantity: _parseDouble(json['max_quantity']),
      location: json['location'] as String,
      supplier: json['supplier'] as String,
      status: json['status'] as String,
      description: json['description'] as String,
      lastUpdated: DateTime.parse(json['last_updated'] as String),
      itemId: json['item_id'] as String?,
      storeId: json['store_id'] as String?,
    );

Map<String, dynamic> _$StockItemToJson(StockItem instance) => <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'category': instance.category,
      'stock_category': _$StockCategoryEnumMap[instance.stockCategory]!,
      'unit': instance.unit,
      'purchase_price': instance.purchasePrice,
      'quantity': instance.quantity,
      'min_quantity': instance.minQuantity,
      'max_quantity': instance.maxQuantity,
      'location': instance.location,
      'supplier': instance.supplier,
      'status': instance.status,
      'description': instance.description,
      'last_updated': instance.lastUpdated.toIso8601String(),
      'item_id': instance.itemId,
      'store_id': instance.storeId,
    };

const _$StockCategoryEnumMap = {
  StockCategory.food: 'food',
  StockCategory.catering: 'catering',
  StockCategory.electronics: 'electronics',
};

FoodStockItem _$FoodStockItemFromJson(Map<String, dynamic> json) =>
    FoodStockItem(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      unit: json['unit'] as String,
      purchasePrice: _parseDouble(json['purchase_price']),
      quantity: _parseDouble(json['quantity']),
      minQuantity: _parseDouble(json['min_quantity']),
      maxQuantity: _parseDouble(json['max_quantity']),
      location: json['location'] as String,
      supplier: json['supplier'] as String,
      status: json['status'] as String,
      description: json['description'] as String,
      lastUpdated: DateTime.parse(json['last_updated'] as String),
      itemId: json['item_id'] as String?,
      storeId: json['store_id'] as String?,
      expiryDate: json['expiry_date'] == null
          ? null
          : DateTime.parse(json['expiry_date'] as String),
      batchNumber: json['batch_number'] as String,
      requiresRefrigeration: json['requires_refrigeration'] as bool? ?? false,
    );

Map<String, dynamic> _$FoodStockItemToJson(FoodStockItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'category': instance.category,
      'unit': instance.unit,
      'purchase_price': instance.purchasePrice,
      'quantity': instance.quantity,
      'min_quantity': instance.minQuantity,
      'max_quantity': instance.maxQuantity,
      'location': instance.location,
      'supplier': instance.supplier,
      'status': instance.status,
      'description': instance.description,
      'last_updated': instance.lastUpdated.toIso8601String(),
      'item_id': instance.itemId,
      'store_id': instance.storeId,
      'expiry_date': instance.expiryDate?.toIso8601String(),
      'batch_number': instance.batchNumber,
      'requires_refrigeration': instance.requiresRefrigeration,
    };

CateringStockItem _$CateringStockItemFromJson(Map<String, dynamic> json) =>
    CateringStockItem(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      unit: json['unit'] as String,
      purchasePrice: _parseDouble(json['purchase_price']),
      quantity: _parseDouble(json['quantity']),
      minQuantity: _parseDouble(json['min_quantity']),
      maxQuantity: _parseDouble(json['max_quantity']),
      location: json['location'] as String,
      supplier: json['supplier'] as String,
      status: json['status'] as String,
      description: json['description'] as String,
      lastUpdated: DateTime.parse(json['last_updated'] as String),
      itemId: json['item_id'] as String?,
      storeId: json['store_id'] as String?,
      subtype: $enumDecode(_$CateringSubtypeEnumMap, json['subtype']),
      condition: json['condition'] as String?,
      isReserved: json['is_reserved'] as bool?,
      reservedFor: json['reserved_for'] as String?,
      packSize: (json['pack_size'] as num?)?.toInt(),
      consumptionRate: json['consumption_rate'] as String?,
    );

Map<String, dynamic> _$CateringStockItemToJson(CateringStockItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'category': instance.category,
      'unit': instance.unit,
      'purchase_price': instance.purchasePrice,
      'quantity': instance.quantity,
      'min_quantity': instance.minQuantity,
      'max_quantity': instance.maxQuantity,
      'location': instance.location,
      'supplier': instance.supplier,
      'status': instance.status,
      'description': instance.description,
      'last_updated': instance.lastUpdated.toIso8601String(),
      'item_id': instance.itemId,
      'store_id': instance.storeId,
      'subtype': _$CateringSubtypeEnumMap[instance.subtype]!,
      'condition': instance.condition,
      'is_reserved': instance.isReserved,
      'reserved_for': instance.reservedFor,
      'pack_size': instance.packSize,
      'consumption_rate': instance.consumptionRate,
    };

const _$CateringSubtypeEnumMap = {
  CateringSubtype.permanent: 'permanent',
  CateringSubtype.temporary: 'temporary',
};

ElectronicsStockItem _$ElectronicsStockItemFromJson(
        Map<String, dynamic> json) =>
    ElectronicsStockItem(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      unit: json['unit'] as String,
      purchasePrice: _parseDouble(json['purchase_price']),
      quantity: _parseDouble(json['quantity']),
      minQuantity: _parseDouble(json['min_quantity']),
      maxQuantity: _parseDouble(json['max_quantity']),
      location: json['location'] as String,
      supplier: json['supplier'] as String,
      status: json['status'] as String,
      description: json['description'] as String,
      lastUpdated: DateTime.parse(json['last_updated'] as String),
      itemId: json['item_id'] as String?,
      storeId: json['store_id'] as String?,
      brand: json['brand'] as String,
      model: json['model'] as String,
      serialNumber: json['serial_number'] as String,
      warrantyExpiry: json['warranty_expiry'] == null
          ? null
          : DateTime.parse(json['warranty_expiry'] as String),
      maintenanceStatus: json['maintenance_status'] as String,
      lastMaintenanceDate: json['last_maintenance_date'] == null
          ? null
          : DateTime.parse(json['last_maintenance_date'] as String),
      assetTag: json['asset_tag'] as String,
    );

Map<String, dynamic> _$ElectronicsStockItemToJson(
        ElectronicsStockItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'category': instance.category,
      'unit': instance.unit,
      'purchase_price': instance.purchasePrice,
      'quantity': instance.quantity,
      'min_quantity': instance.minQuantity,
      'max_quantity': instance.maxQuantity,
      'location': instance.location,
      'supplier': instance.supplier,
      'status': instance.status,
      'description': instance.description,
      'last_updated': instance.lastUpdated.toIso8601String(),
      'item_id': instance.itemId,
      'store_id': instance.storeId,
      'brand': instance.brand,
      'model': instance.model,
      'serial_number': instance.serialNumber,
      'warranty_expiry': instance.warrantyExpiry?.toIso8601String(),
      'maintenance_status': instance.maintenanceStatus,
      'last_maintenance_date': instance.lastMaintenanceDate?.toIso8601String(),
      'asset_tag': instance.assetTag,
    };
