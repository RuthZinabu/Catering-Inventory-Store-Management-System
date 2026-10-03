import 'package:flutter/material.dart';
import '../../models/stock_models.dart';
import '../../services/api_repository.dart';

class StockHistoryScreen extends StatefulWidget {
  final StockItem item;
  const StockHistoryScreen({super.key, required this.item});

  @override
  State<StockHistoryScreen> createState() => _StockHistoryScreenState();
}

class _StockHistoryScreenState extends State<StockHistoryScreen> {
  List<StockMovementEntry> _movements = [];
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
          _movements = movements;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
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
                        onPressed: _loadStockMovements,
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

    final movements = _movements;

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
                        Text(item.name,
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
                      '${movements.length} record${movements.length == 1 ? '' : 's'}',
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
            // List
            Expanded(
              child: movements.isEmpty
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
                          const Text('No movement history',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: Color(0xFF10162B))),
                          const SizedBox(height: 6),
                          const Text('No records found for this item.',
                              style: TextStyle(
                                  color: Color(0xFF64748B), fontSize: 13)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 112),
                      itemCount: movements.length,
                      itemBuilder: (context, index) {
                        final m = movements[index];
                        final color = _typeColor(m.type);
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
                                child: Icon(_typeIcon(m.type),
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
                                          child: Text(m.type,
                                              style: TextStyle(
                                                  color: color,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700)),
                                        ),
                                        const Spacer(),
                                        Text(_formatDate(m.date),
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: Color(0xFF94A3B8),
                                                fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                        '${m.quantity.toStringAsFixed(m.quantity == m.quantity.truncate() ? 0 : 1)} ${m.unit}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15,
                                            color: Color(0xFF10162B))),
                                    const SizedBox(height: 4),
                                    Text('By ${m.performedBy}',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF64748B),
                                            fontWeight: FontWeight.w500)),
                                    if (m.note.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Text(m.note,
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
