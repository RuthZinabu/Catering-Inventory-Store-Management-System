import '../../models/stock_models.dart';
import '../stock_transfers/stock_transfer_models.dart';

class StockHistoryEntry {
  final DateTime date;
  final StockMovementEntry? movement;
  final StockTransferViewModel? transfer;
  final StockTransferLineViewModel? transferLine;

  const StockHistoryEntry({
    required this.date,
    this.movement,
    this.transfer,
    this.transferLine,
  });
}

List<StockHistoryEntry> buildStockHistoryEntries({
  required String itemId,
  required List<StockMovementEntry> movements,
  required List<StockTransferViewModel> transfers,
  bool transfersLoaded = true,
}) {
  final history = <StockHistoryEntry>[];

  for (final movement in movements) {
    // When the transfer list is available, show a transfer once with its
    // current lifecycle status rather than duplicating ship/receive movements.
    if (transfersLoaded && movement.type == 'Transfer') continue;
    history.add(StockHistoryEntry(date: movement.date, movement: movement));
  }

  for (final transfer in transfers) {
    for (final line in transfer.lines.where((line) => line.itemId == itemId)) {
      history.add(
        StockHistoryEntry(
          date: DateTime.tryParse(transfer.date) ??
              DateTime.fromMillisecondsSinceEpoch(0),
          transfer: transfer,
          transferLine: line,
        ),
      );
    }
  }

  history.sort((a, b) => b.date.compareTo(a.date));
  return history;
}
