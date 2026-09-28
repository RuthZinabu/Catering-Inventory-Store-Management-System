class PurchaseViewModel {
  final String number;
  final String supplier;
  final String date;
  final int items;
  final String amount;
  final String expectedDelivery;
  final String status;
  final String paymentStatus;

  const PurchaseViewModel({
    required this.number,
    required this.supplier,
    required this.date,
    required this.items,
    required this.amount,
    required this.expectedDelivery,
    required this.status,
    required this.paymentStatus,
  });
}
