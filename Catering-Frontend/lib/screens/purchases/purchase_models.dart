class PurchaseViewModel {
  final String id;
  final String number;
  final String supplier;
  final String supplierId;
  final String storeId;
  final String date;
  final String amount;
  final double subtotal;
  final double vatAmount;
  final double discountAmount;
  final double totalAmount;
  final List<PurchaseLineViewModel> items;
  final String expectedDelivery;
  final String status;
  final String paymentStatus;
  final String notes;

  const PurchaseViewModel({
    required this.id,
    required this.number,
    required this.supplier,
    required this.supplierId,
    required this.storeId,
    required this.date,
    required this.amount,
    required this.subtotal,
    required this.vatAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.items,
    required this.expectedDelivery,
    required this.status,
    required this.paymentStatus,
    required this.notes,
  });

  factory PurchaseViewModel.fromJson(Map<String, dynamic> json) {
    final supplier = Map<String, dynamic>.from(json['supplier'] as Map? ?? const {});
    final lines = (json['items'] as List? ?? const [])
        .map((item) => PurchaseLineViewModel.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
    final total = _number(json['total_amount']);
    return PurchaseViewModel(
      id: json['id'].toString(),
      number: json['number'] as String? ?? '',
      supplier: supplier['company'] as String? ?? supplier['name'] as String? ?? '',
      supplierId: json['supplier_id'].toString(),
      storeId: json['destination_store_id'].toString(),
      date: json['order_date'] as String? ?? '',
      amount: 'ETB ${total.toStringAsFixed(2)}',
      subtotal: _number(json['subtotal']),
      vatAmount: _number(json['vat_amount']),
      discountAmount: _number(json['discount_amount']),
      totalAmount: total,
      items: lines,
      expectedDelivery: json['expected_delivery_date'] as String? ?? '',
      status: json['status'] as String? ?? 'Pending',
      paymentStatus: json['payment_status'] as String? ?? 'Pending',
      notes: json['notes'] as String? ?? '',
    );
  }
}

class PurchaseLineViewModel {
  final String id;
  final String itemId;
  final String name;
  final String unit;
  final double quantity;
  final double receivedQuantity;
  final double unitPrice;
  final double vatAmount;
  final double discountAmount;
  final double lineTotal;

  const PurchaseLineViewModel({
    required this.id,
    required this.itemId,
    required this.name,
    required this.unit,
    required this.quantity,
    required this.receivedQuantity,
    required this.unitPrice,
    required this.vatAmount,
    required this.discountAmount,
    required this.lineTotal,
  });

  factory PurchaseLineViewModel.fromJson(Map<String, dynamic> json) {
    final item = Map<String, dynamic>.from(json['item'] as Map? ?? const {});
    return PurchaseLineViewModel(
      id: json['id'].toString(),
      itemId: json['item_id'].toString(),
      name: item['name'] as String? ?? '',
      unit: json['unit'] as String? ?? item['unit'] as String? ?? '',
      quantity: _number(json['quantity']),
      receivedQuantity: _number(json['received_quantity']),
      unitPrice: _number(json['unit_price']),
      vatAmount: _number(json['vat_amount']),
      discountAmount: _number(json['discount_amount']),
      lineTotal: _number(json['line_total']),
    );
  }
}

double _number(dynamic value) => value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
