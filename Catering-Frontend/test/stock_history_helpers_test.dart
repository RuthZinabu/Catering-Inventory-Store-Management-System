import 'package:flutter_test/flutter_test.dart';
import 'package:catering_inventory_store_management_system/models/stock_models.dart';
import 'package:catering_inventory_store_management_system/screens/stock/stock_history_helpers.dart';
import 'package:catering_inventory_store_management_system/screens/stock_transfers/stock_transfer_models.dart';

void main() {
  test('keeps pending and completed item transfers without duplicate movements',
      () {
    final movements = [
      StockMovementEntry(
        id: 'transfer-movement',
        stockItemId: 'item-1',
        type: 'Transfer',
        quantity: 4,
        unit: 'kg',
        performedBy: 'Manager',
        date: DateTime.parse('2026-10-12T10:00:00Z'),
        note: 'Transfer shipped',
      ),
      StockMovementEntry(
        id: 'stock-in',
        stockItemId: 'item-1',
        type: 'Stock In',
        quantity: 2,
        unit: 'kg',
        performedBy: 'Storekeeper',
        date: DateTime.parse('2026-10-11T10:00:00Z'),
        note: '',
      ),
    ];
    final transfers = [
      _transfer(id: 'pending-transfer', status: 'pending', itemId: 'item-1'),
      _transfer(id: 'received-transfer', status: 'received', itemId: 'item-1'),
      _transfer(id: 'other-item-transfer', status: 'pending', itemId: 'item-2'),
    ];

    final history = buildStockHistoryEntries(
      itemId: 'item-1',
      movements: movements,
      transfers: transfers,
    );

    expect(history, hasLength(3));
    expect(history.where((entry) => entry.movement?.type == 'Transfer'), isEmpty);
    expect(
      history
          .where((entry) => entry.transfer != null)
          .map((entry) => entry.transfer!.status),
      containsAll(['pending', 'received']),
    );
    expect(
      history.where((entry) => entry.movement?.type == 'Stock In'),
      hasLength(1),
    );
  });

  test('keeps transfer movements when transfer records could not be loaded',
      () {
    final movement = StockMovementEntry(
      id: 'transfer-movement',
      stockItemId: 'item-1',
      type: 'Transfer',
      quantity: 4,
      unit: 'kg',
      performedBy: 'Manager',
      date: DateTime.parse('2026-10-12T10:00:00Z'),
      note: 'Transfer shipped',
    );

    final history = buildStockHistoryEntries(
      itemId: 'item-1',
      movements: [movement],
      transfers: const [],
      transfersLoaded: false,
    );

    expect(history, hasLength(1));
    expect(history.single.movement?.id, 'transfer-movement');
  });
}

StockTransferViewModel _transfer({
  required String id,
  required String status,
  required String itemId,
}) {
  return StockTransferViewModel(
    id: id,
    number: 'TR-$id',
    fromStoreId: 'from-store',
    fromStore: 'Source',
    toStoreId: 'to-store',
    toStore: 'Destination',
    items: 1,
    quantity: 4,
    date: status == 'pending' ? '2026-10-12' : '2026-10-10',
    person: 'Manager',
    status: status,
    lines: [
      StockTransferLineViewModel(
        id: 'line-$id',
        itemId: itemId,
        name: 'Test Item',
        code: 'ITEM-1',
        unit: 'kg',
        quantityRequested: 4,
        quantityShipped: status == 'received' ? 4 : 0,
        quantityReceived: status == 'received' ? 4 : 0,
      ),
    ],
  );
}
