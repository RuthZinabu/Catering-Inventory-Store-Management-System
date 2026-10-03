import 'package:flutter_test/flutter_test.dart';
import 'package:catering_inventory_store_management_system/models/stock_models.dart';

void main() {
  test('normalizes nested store stock into a catering stock item', () {
    final stock = CateringStockItem.fromJson(normalizeStockItemJson({
      'id': 'stock-id',
      'item_id': 'item-id',
      'store_id': 'store-id',
      'quantity': '4.000',
      'reserved_quantity': '1.000',
      'current_cost': '2.50',
      'min_quantity': '1.000',
      'max_quantity': '10.000',
      'status': 'Healthy',
      'updated_at': '2026-10-03T12:00:00.000000Z',
      'item': {
        'code': 'ITEM-1',
        'name': 'Serving tray',
        'category': 'Equipment',
        'item_type': 'catering',
        'catering_subtype': 'temporary',
        'unit': 'each',
      },
      'store': {'name': 'Main Store'},
    }));

    expect(stock.id, 'stock-id');
    expect(stock.name, 'Serving tray');
    expect(stock.quantity, 4);
    expect(stock.location, 'Main Store');
    expect(stock.subtype, CateringSubtype.temporary);
  });

  test('supplies safe defaults for missing food and electronics metadata', () {
    final food = FoodStockItem.fromJson(normalizeStockItemJson({
      'id': 'food-stock',
      'stock_category': 'food',
      'updated_at': '2026-10-03T12:00:00.000000Z',
    }));
    final electronics = ElectronicsStockItem.fromJson(normalizeStockItemJson({
      'id': 'electronics-stock',
      'stock_category': 'electronics',
      'updated_at': '2026-10-03T12:00:00.000000Z',
    }));

    expect(food.batchNumber, isEmpty);
    expect(electronics.brand, isEmpty);
    expect(electronics.maintenanceStatus, 'Unknown');
  });

  test('normalizes stock movement API fields and decimal strings', () {
    final movement = StockMovementEntry.fromJson(normalizeStockMovementJson({
      'id': 'movement-id',
      'item_id': 'item-id',
      'type': 'Adjustment',
      'quantity': '2.500',
      'unit': 'kg',
      'performed_by': 'user-id',
      'created_at': '2026-10-03T12:00:00.000000Z',
      'note': null,
    }));

    expect(movement.stockItemId, 'item-id');
    expect(movement.quantity, 2.5);
    expect(movement.date, DateTime.parse('2026-10-03T12:00:00.000000Z'));
    expect(movement.note, isEmpty);
  });
}