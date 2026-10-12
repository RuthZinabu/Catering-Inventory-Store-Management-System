import 'package:flutter/material.dart';
import '../../models/stock_models.dart';
import '../../services/api_repository.dart';
import 'stock_history_screen.dart';
import 'stock_form_screen.dart';
import 'stock_helpers.dart';

class StockDetailScreen extends StatefulWidget {
  final StockItem item;
  const StockDetailScreen({super.key, required this.item});

  @override
  State<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  int _movementCount = 0;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStockMovements();
  }

  Future<void> _loadStockMovements() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final itemId = widget.item.historyItemId;
    List<StockMovementEntry>? movements;
    var transferCount = 0;
    var transferHistoryLoaded = false;
    Object? loadError;

    try {
      movements = await ApiRepository.instance.getStockMovements(
        storeId: widget.item.storeId,
        itemId: itemId,
      );
    } catch (error) {
      loadError = error;
    }

    try {
      final transfers = await ApiRepository.instance.getStockTransfersForItem(
        itemId,
        storeId: widget.item.storeId,
      );
      transferCount = transfers.length;
      transferHistoryLoaded = true;
    } catch (error) {
      loadError ??= error;
    }

    if (!mounted) return;
    setState(() {
      if (movements == null && !transferHistoryLoaded) {
        _error = loadError.toString();
        _movementCount = 0;
      } else {
        final movementCount = movements
                ?.where(
                  (movement) =>
                      !transferHistoryLoaded || movement.type != 'Transfer',
                )
                .length ??
            0;
        _movementCount = movementCount + transferCount;
      }
      _isLoading = false;
    });
  }

  Future<void> _openHistory() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => StockHistoryScreen(item: widget.item)),
    );
    if (mounted) {
      _loadStockMovements();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: buildStockDetailBody(
          context,
          widget.item,
          movementCount: _movementCount,
          onEdit: () => Navigator.of(context).push(
            MaterialPageRoute(
                builder: (_) => StockFormScreen(item: widget.item)),
          ),
          onHistory: _openHistory,
        ),
      ),
    );
  }
}
