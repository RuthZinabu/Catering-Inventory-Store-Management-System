import 'package:flutter/material.dart';
import '../../models/stock_models.dart';
import '../../services/api_repository.dart';
import 'stock_history_helpers.dart';
import '../stock_transfers/stock_transfer_models.dart';

class StockHistoryScreen extends StatefulWidget {
  final StockItem item;
  const StockHistoryScreen({super.key, required this.item});

  @override
  State<StockHistoryScreen> createState() => _StockHistoryScreenState();
}

class _StockHistoryScreenState extends State<StockHistoryScreen> {
  List<StockHistoryEntry> _history = [];
  bool _isLoading = true;
  String? _error;
  String? _warning;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _warning = null;
    });

    final itemId = widget.item.historyItemId;
    List<StockMovementEntry>? movements;
    List<StockTransferViewModel>? transfers;
    Object? movementError;
    Object? transferError;

    try {
      movements = await ApiRepository.instance.getStockMovements(
        storeId: widget.item.storeId,
        itemId: itemId,
      );
    } catch (error) {
      movementError = error;
    }

    try {
      transfers = await ApiRepository.instance.getStockTransfersForItem(
        itemId,
        storeId: widget.item.storeId,
      );
    } catch (error) {
      transferError = error;
    }

    if (!mounted) return;
    if (movements == null && transfers == null) {
      setState(() {
        _error = 'Could not load this item’s history. '
            '${movementError ?? ''} ${transferError ?? ''}'.trim();
        _isLoading = false;
      });
      return;
    }

    final history = buildStockHistoryEntries(
      itemId: itemId,
      movements: movements ?? const <StockMovementEntry>[],
      transfers: transfers ?? const <StockTransferViewModel>[],
      transfersLoaded: transfers != null,
    );
    setState(() {
      _history = history;
      _warning = movementError != null || transferError != null
          ? 'Some history records could not be loaded. Retry to see the complete history.'
          : null;
      _isLoading = false;
    });
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'Stock In':
        return const Color(0xFF16A34A);
      case 'Stock Out':
        return const Color(0xFFEF4444);
      case 'Transfer':
        return const Color(0xFF4F46E5);
      case 'Return':
        return const Color(0xFF0F766E);
      case 'Adjustment':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF64748B);
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'Stock In':
        return Icons.arrow_downward_rounded;
      case 'Stock Out':
        return Icons.arrow_upward_rounded;
      case 'Transfer':
        return Icons.swap_horiz_rounded;
      case 'Return':
        return Icons.replay_rounded;
      case 'Adjustment':
        return Icons.tune_rounded;
      default:
        return Icons.circle_outlined;
    }
  }

  String _formatDate(DateTime d) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${d.day} ${months[d.month]} ${d.year}';
  }

  double _transferQuantity(StockTransferLineViewModel line) {
    if (line.quantityReceived > 0) return line.quantityReceived;
    if (line.quantityShipped > 0) return line.quantityShipped;
    return line.quantityRequested;
  }

  String _transferStatusLabel(String status) {
    return status
        .split('_')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                      style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.all(10)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Movement History',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                      style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.all(10)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Movement History',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadHistory,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final history = _history;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4))
                        ],
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 18, color: Color(0xFF10162B)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Movement History',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF10162B),
                                    letterSpacing: -0.4)),
                        const SizedBox(height: 2),
                        Text(widget.item.name,
                            style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Count badge
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${history.length} record${history.length == 1 ? '' : 's'}',
                      style: const TextStyle(
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.w700,
                          fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (_warning != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Text(
                  _warning!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
            // List
            Expanded(
              child: history.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(Icons.history_rounded,
                                size: 44, color: Color(0xFF94A3B8)),
                          ),
                          const SizedBox(height: 16),
                          const Text('No movement or transfer history',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: Color(0xFF10162B))),
                          const SizedBox(height: 6),
                          const Text('No records found for this item in this store.',
                              style: TextStyle(
                                  color: Color(0xFF64748B), fontSize: 13)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 112),
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final entry = history[index];
                        final movement = entry.movement;
                        final transfer = entry.transfer;
                        final transferLine = entry.transferLine;
                        final isTransfer = transfer != null;
                        final type = isTransfer ? 'Transfer' : movement!.type;
                        final color = _typeColor(type);
                        final quantity = isTransfer
                            ? _transferQuantity(transferLine!)
                            : movement!.quantity;
                        final unit = isTransfer
                            ? transferLine!.unit
                            : movement!.unit;
                        final performedBy = isTransfer
                            ? transfer!.person
                            : movement!.performedBy;
                        final note = isTransfer
                            ? 'Transfer ${transfer!.number}: ${transfer!.fromStore} → ${transfer!.toStore}'
                            : movement!.note;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 18,
                                  offset: const Offset(0, 10))
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(_typeIcon(type),
                                    color: color, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: color.withOpacity(0.12),
                                            borderRadius:
                                                BorderRadius.circular(999),
                                          ),
                                          child: Text(
                                            isTransfer
                                                ? 'Transfer · ${_transferStatusLabel(transfer!.status)}'
                                                : type,
                                              style: TextStyle(
                                                  color: color,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700)),
                                        ),
                                        const Spacer(),
                                        Text(_formatDate(entry.date),
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: Color(0xFF94A3B8),
                                                fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                        '${quantity.toStringAsFixed(quantity == quantity.truncate() ? 0 : 1)} $unit',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15,
                                            color: Color(0xFF10162B))),
                                    const SizedBox(height: 4),
                                    Text('By ${performedBy.isEmpty ? "Unknown" : performedBy}',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF64748B),
                                            fontWeight: FontWeight.w500)),
                                    if (note.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Text(note,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF475569),
                                              fontStyle: FontStyle.italic)),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
