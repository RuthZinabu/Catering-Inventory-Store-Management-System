class StockTransferViewModel {
  final String id;
  final String number;
  final String fromStoreId;
  final String fromStore;
  final String toStoreId;
  final String toStore;
  final int items;
  final double quantity;
  final String date;
  final String person;
  final String status;
  final String notes;
  final List<StockTransferLineViewModel> lines;

  const StockTransferViewModel({
    required this.id,
    required this.number,
    required this.fromStoreId,
    required this.fromStore,
    required this.toStoreId,
    required this.toStore,
    required this.items,
    required this.quantity,
    required this.date,
    required this.person,
    required this.status,
    this.notes = '',
    this.lines = const [],
  });

  factory StockTransferViewModel.fromJson(Map<String, dynamic> json) {
    final lines = json['lines'] as List? ?? const [];
    return StockTransferViewModel(
      id: json['id'] as String,
      number: json['number'] as String? ?? '',
      fromStoreId: json['from_store_id'] as String? ?? '',
      fromStore: json['from_store'] as String? ?? '',
      toStoreId: json['to_store_id'] as String? ?? '',
      toStore: json['to_store'] as String? ?? '',
      items: (json['items'] as num?)?.toInt() ?? 0,
      quantity: _parseNumber(json['quantity']),
      date: json['date']?.toString() ?? '',
      person: json['person'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      notes: json['notes'] as String? ?? '',
      lines: lines
          .map((line) => StockTransferLineViewModel.fromJson(
              Map<String, dynamic>.from(line as Map)))
          .toList(),
    );
  }
}

class StockTransferLineViewModel {
  final String id;
  final String itemId;
  final String name;
  final String code;
  final String unit;
  final double quantityRequested;
  final double quantityShipped;
  final double quantityReceived;

  const StockTransferLineViewModel({
    required this.id,
    required this.itemId,
    required this.name,
    required this.code,
    required this.unit,
    required this.quantityRequested,
    required this.quantityShipped,
    required this.quantityReceived,
  });

  factory StockTransferLineViewModel.fromJson(Map<String, dynamic> json) {
    return StockTransferLineViewModel(
      id: json['id'] as String? ?? '',
      itemId: json['item_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
      quantityRequested: _parseNumber(json['quantity_requested']),
      quantityShipped: _parseNumber(json['quantity_shipped']),
      quantityReceived: _parseNumber(json['quantity_received']),
    );
  }
}

class TransferStockItemViewModel {
  final String itemId;
  final String name;
  final String code;
  final String unit;
  final double quantity;
  final double availableQuantity;

  const TransferStockItemViewModel({
    required this.itemId,
    required this.name,
    required this.code,
    required this.unit,
    required this.quantity,
    required this.availableQuantity,
  });

  factory TransferStockItemViewModel.fromJson(Map<String, dynamic> json) {
    final item = Map<String, dynamic>.from(json['item'] as Map? ?? const {});
    return TransferStockItemViewModel(
      itemId: json['item_id'] as String? ?? '',
      name: item['name'] as String? ?? '',
      code: item['code'] as String? ?? '',
      unit: item['unit'] as String? ?? '',
      quantity: _parseNumber(json['quantity']),
      availableQuantity: _parseNumber(json['available_quantity']),
    );
  }
}

double _parseNumber(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}
