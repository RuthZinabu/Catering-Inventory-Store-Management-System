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

    try {
      final movements = await ApiRepository.instance.getStockMovements(
        itemId: widget.item.id,
      );
      if (mounted) {
        setState(() {
          _movementCount = movements.length;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
          _movementCount = 0; // Default to 0 on error
        });
      }
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
          onHistory: () => Navigator.of(context).push(
            MaterialPageRoute(
                builder: (_) => StockHistoryScreen(item: widget.item)),
          ),
        ),
      ),
    );
  }
}
