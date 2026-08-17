import 'package:flutter/material.dart';
import '../../models/stock_models.dart';
import '../../services/mock_repository.dart';
import 'stock_history_screen.dart';
import 'stock_form_screen.dart';
import 'stock_helpers.dart';

class StockDetailScreen extends StatelessWidget {
  final StockItem item;
  const StockDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final movementCount = MockRepository.stockMovements
        .where((m) => m.stockItemId == item.id)
        .length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: buildStockDetailBody(
          context,
          item,
          movementCount: movementCount,
          onEdit: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => StockFormScreen(item: item)),
          ),
          onHistory: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => StockHistoryScreen(item: item)),
          ),
        ),
      ),
    );
  }
}
