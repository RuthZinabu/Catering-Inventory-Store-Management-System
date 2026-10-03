import 'package:flutter/material.dart';
import '../services/api_repository.dart';
import '../models/inventory_models.dart';
import '../models/stock_models.dart';
import '../widgets/loading_error_widgets.dart';
import '../utils/responsive.dart';
import '../theme/app_colors.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  String? _error;

  List<InventoryItem> _inventoryItems = [];
  List<StockItem> _stockItems = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load available dashboard data in parallel.
      final results = await Future.wait([
        ApiRepository.instance.getInventoryItems(),
        ApiRepository.instance.getStockItems(),
      ]);

      if (mounted) {
        setState(() {
          _inventoryItems = results[0] as List<InventoryItem>;
          _stockItems = results[1] as List<StockItem>;
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

  // Calculate dashboard metrics from live data
  int get totalStock => _stockItems.length;
  int get lowStockCount => _inventoryItems
      .where((item) =>
          item.stockOnHandValue <= item.minStockValue && item.minStockValue > 0)
      .length;
  double get totalInventoryValue => _inventoryItems.fold(
      0, (sum, item) => sum + (item.purchasePrice * item.stockOnHandValue));

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: LoadingWidget(message: 'Loading dashboard…')),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: CustomErrorWidget(
              error: _error!,
              title: 'Could not load dashboard',
              onRetry: _loadDashboardData,
            ),
          ),
        ),
      );
    }

    final now = DateTime.now();
    final dateLabel =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDashboardData,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Good morning',
                            style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 4),
                        Text(
                          'Admin',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.darkGreen,
                    child: const Text(
                      'A',
                      style: TextStyle(
                        color: AppColors.accentGold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text('Today • $dateLabel',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.darkGreen,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: AppColors.accentGold.withOpacity(0.35),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.favorite_outline_rounded,
                            color: AppColors.accentGold),
                        const SizedBox(width: 10),
                        Text(
                          'Inventory health',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.accentGold,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      lowStockCount == 0
                          ? 'No items are currently below their minimum stock level.'
                          : '$lowStockCount ${lowStockCount == 1 ? 'item is' : 'items are'} below the minimum stock level.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            height: 1.5,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final columns = width < 250
                      ? 1
                      : isDesktopWidth(width)
                          ? 4
                          : isTabletWidth(width)
                              ? 3
                              : 2;
                  const spacing = 12.0;
                  final cardWidth =
                      (width - spacing * (columns - 1)) / columns;

                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: [
                      SizedBox(
                        width: cardWidth,
                        child: _healthCard(
                          context,
                          'Total Stock Items',
                          '$totalStock',
                          Icons.inventory_2_rounded,
                          AppColors.darkGreen,
                          'Current',
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: _healthCard(
                          context,
                          'Low Stock',
                          '$lowStockCount',
                          Icons.warning_amber_rounded,
                          AppColors.accentGold,
                          'Needs attention',
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: _healthCard(
                          context,
                          'Inventory Value',
                          'ETB ${totalInventoryValue.toStringAsFixed(0)}',
                          Icons.account_balance_wallet_outlined,
                          AppColors.accentGold,
                          'Current',
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              Text('Low stock',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              ..._buildLowStockCards(context),
              const SizedBox(height: 12),
              Text('Activity & alerts',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              _activityUnavailableCard(context),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildLowStockCards(BuildContext context) {
    final lowStockItems = _inventoryItems
        .where((item) =>
            item.stockOnHandValue <= item.minStockValue &&
            item.minStockValue > 0)
        .take(3)
        .toList();

    if (lowStockItems.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 18,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.check_circle_outline,
                    color: AppColors.accentGreen),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('All items well stocked!',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('No low stock alerts at the moment.',
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
        ),
      ];
    }

    return lowStockItems.map((item) {
      final progress = (item.stockOnHand != null &&
              item.maxStock != null &&
              item.maxStock! > 0)
          ? (item.stockOnHand! / item.maxStock!).clamp(0.0, 1.0).toDouble()
          : 0.0;
      final color = progress < 0.2 ? AppColors.errorRed : AppColors.accentGold;
      return _lowStockCard(
        context,
        item.name,
        '${item.stockOnHand} / ${item.maxStock} ${item.unit} left',
        progress,
        color,
      );
    }).toList();
  }

  Widget _activityUnavailableCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.info_outline, color: AppColors.primaryBlue),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Activity and expiry alerts are not available from the server yet.',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _healthCard(BuildContext context, String title, String value,
      IconData icon, Color color, String trend) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
        border: Border.all(color: const Color(0xFFE9EEF8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(999)),
                child: Text(trend,
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(title, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _lowStockCard(BuildContext context, String name, String detail,
      double progress, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 18,
                offset: const Offset(0, 8))
          ]),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16)),
            child: Icon(Icons.warning_amber_rounded, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Text(name,
                            style:
                                const TextStyle(fontWeight: FontWeight.w700))),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(999)),
                      child: Text('Warning',
                          style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w600,
                              fontSize: 11)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(detail, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFF1F5F9),
                      color: color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
