class StockTransferViewModel {
  final String number;
  final String fromStore;
  final String toStore;
  final int items;
  final int quantity;
  final String date;
  final String person;
  final String status;

  const StockTransferViewModel({
    required this.number,
    required this.fromStore,
    required this.toStore,
    required this.items,
    required this.quantity,
    required this.date,
    required this.person,
    required this.status,
  });
}
