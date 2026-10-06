import 'dart:async';

import 'package:flutter/material.dart';
import '../services/api_repository.dart';
import '../services/auth_service.dart';
import '../models/inventory_models.dart';
import '../models/stock_models.dart';
import 'profile_screen.dart';
import 'notifications_screen.dart';
import '../services/api_service.dart' as legacy_api;
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
  int _unreadNotificationCount = 0;
  String? _refreshError;
  String? _activityError;
  bool _isRefreshingDashboard = false;
  Timer? _dashboardRefreshTimer;

  List<InventoryItem> _inventoryItems = [];
  List<StockItem> _stockItems = [];
  Map<String, dynamic> _dashboardKpis = {};
  List<Map<String, dynamic>> _lowStockItems = [];
  List<Map<String, dynamic>> _expiringBatches = [];
  List<Map<String, dynamic>> _recentNotifications = [];
  DateTime? _lastRefreshedAt;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    _dashboardRefreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _loadDashboardData(showLoading: false),
    );
  }

  @override
  void dispose() {
    _dashboardRefreshTimer?.cancel();
    super.dispose();
  }

  bool get _canViewReportDashboard {
    final user = AuthService.instance.currentUser;
    return user?.isAdmin == true ||
        (user?.permissions.contains('reports.view') ?? false);
  }

  Future<void> _loadDashboardData({bool showLoading = true}) async {
    if (_isRefreshingDashboard) return;
    _isRefreshingDashboard = true;
    if (showLoading && mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      List<InventoryItem> inventoryItems = [];
      List<StockItem> stockItems = [];
      Map<String, dynamic> dashboardKpis = {};
      List<Map<String, dynamic>> lowStockItems = [];
      List<Map<String, dynamic>> expiringBatches = [];

      if (_canViewReportDashboard) {
        final responses = await Future.wait([
          legacy_api.ApiClient.instance
              .get('/reports/dashboard/kpis?period=weekly'),
          legacy_api.ApiClient.instance
              .get('/reports/stock/low-stock?per_page=5'),
        ]);
        final reportData =
            Map<String, dynamic>.from(responses[0]['data'] as Map);
        dashboardKpis =
            Map<String, dynamic>.from(reportData['kpis'] as Map);
        final alerts =
            Map<String, dynamic>.from(reportData['alerts'] as Map? ?? {});
        expiringBatches = (alerts['expiring_batches'] as List? ?? const [])
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();

        final lowStockData =
            Map<String, dynamic>.from(responses[1]['data'] as Map);
        lowStockItems = (lowStockData['items'] as List? ?? const [])
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      } else {
        final results = await Future.wait([
          ApiRepository.instance.getInventoryItems(),
          ApiRepository.instance.getStockItems(),
        ]);
        inventoryItems = results[0] as List<InventoryItem>;
        stockItems = results[1] as List<StockItem>;
        dashboardKpis = _fallbackDashboardKpis(inventoryItems, stockItems);
        lowStockItems = _fallbackLowStockItems(inventoryItems);
      }

      List<Map<String, dynamic>> recentNotifications =
          List<Map<String, dynamic>>.of(_recentNotifications);
      int unreadCount = _unreadNotificationCount;
      String? activityError;
      try {
        final response = await legacy_api.ApiClient.instance
            .get('/notifications?per_page=5');
        final notificationData =
            Map<String, dynamic>.from(response['data'] as Map);
        unreadCount =
            (notificationData['unread_count'] as num?)?.toInt() ?? 0;
        recentNotifications =
            (notificationData['notifications'] as List? ?? const [])
                .map((item) => Map<String, dynamic>.from(item as Map))
                .toList();
      } catch (error) {
        activityError = error.toString();
      }

      if (mounted) {
        setState(() {
          _inventoryItems = inventoryItems;
          _stockItems = stockItems;
          _dashboardKpis = dashboardKpis;
          _lowStockItems = lowStockItems;
          _expiringBatches = expiringBatches;
          _recentNotifications = recentNotifications;
          _unreadNotificationCount = unreadCount;
          _activityError = activityError;
          _refreshError = null;
          _lastRefreshedAt = DateTime.now();
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (showLoading) {
            _error = e.toString();
          } else {
            _refreshError = e.toString();
          }
        });
      }
    } finally {
      _isRefreshingDashboard = false;
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshDashboard() async {
    await _loadDashboardData(showLoading: false);
  }

  Map<String, dynamic> _fallbackDashboardKpis(
    List<InventoryItem> inventoryItems,
    List<StockItem> stockItems,
  ) {
    final lowStockItems = inventoryItems.where((item) =>
        item.minStockValue > 0 &&
        item.stockOnHandValue > 0 &&
        item.stockOnHandValue <= item.minStockValue);
    final outOfStockItems =
        inventoryItems.where((item) => item.stockOnHandValue <= 0);
    return {
      'total_items': stockItems.length,
      'low_stock_items': lowStockItems.length,
      'out_of_stock_items': outOfStockItems.length,
      'inventory_value': inventoryItems.fold<double>(
        0,
        (sum, item) => sum + item.purchasePrice * item.stockOnHandValue,
      ),
    };
  }

  List<Map<String, dynamic>> _fallbackLowStockItems(
    List<InventoryItem> inventoryItems,
  ) {
    return inventoryItems
        .where((item) =>
            item.stockOnHandValue <= 0 ||
            (item.minStockValue > 0 &&
                item.stockOnHandValue <= item.minStockValue))
        .take(5)
        .map((item) => {
              'id': item.id,
              'name': item.name,
              'unit': item.unit,
              'quantity': item.stockOnHandValue,
              'minimum_quantity': item.minStockValue,
            })
        .toList();
  }

  int get totalStock =>
      (_dashboardKpis['total_items'] as num?)?.toInt() ?? _stockItems.length;
  int get lowStockCount =>
      (_dashboardKpis['low_stock_items'] as num?)?.toInt() ?? 0;
  int get outOfStockCount =>
      (_dashboardKpis['out_of_stock_items'] as num?)?.toInt() ?? 0;
  int get stockAttentionCount => lowStockCount + outOfStockCount;
  int get expiringSoonCount =>
      (_dashboardKpis['expiring_soon'] as num?)?.toInt() ?? 0;
  int get movementsThisWeek =>
      (_dashboardKpis['stock_movements'] as num?)?.toInt() ?? 0;
  int get untrackedExpiryCount =>
      (_dashboardKpis['untracked_expiry_items'] as num?)?.toInt() ?? 0;
  int get expiredBatchItemTypes =>
      (_dashboardKpis['expired_items'] as num?)?.toInt() ?? 0;
  double get totalInventoryValue {
    final value = _dashboardKpis['inventory_value'];
    if (value is num) return value.toDouble();
    return _inventoryItems.fold<double>(
      0,
      (sum, item) => sum + item.purchasePrice * item.stockOnHandValue,
    );
  }

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
    final user = AuthService.instance.currentUser;
    final userName = user?.name.trim();
    final avatarInitial =
        userName != null && userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshDashboard,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome!',
                            style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 4),
                        Text(
                          userName?.isNotEmpty == true ? userName! : 'User',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  Tooltip(
                    message: 'Notifications',
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const NotificationsScreen(),
                          ),
                        );
                        _loadDashboardData(showLoading: false);
                      },
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Center(
                              child: Icon(Icons.notifications_none_rounded),
                            ),
                            if (_unreadNotificationCount > 0)
                              Positioned(
                                right: -2,
                                top: -2,
                                child: Container(
                                  constraints: const BoxConstraints(
                                    minWidth: 18,
                                    minHeight: 18,
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: const BoxDecoration(
                                    color: AppColors.errorRed,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    _unreadNotificationCount > 99
                                        ? '99+'
                                        : '$_unreadNotificationCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Tooltip(
                    message: 'Profile',
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const ProfileScreen(),
                          ),
                        );
                      },
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.darkGreen,
                        child: Text(
                          avatarInitial,
                          style: const TextStyle(
                            color: AppColors.accentGold,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text('Today • $dateLabel',
                  style: Theme.of(context).textTheme.bodyMedium),
              if (_lastRefreshedAt != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Updated ${_formatActivityTime(_lastRefreshedAt!.toIso8601String())}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              if (_refreshError != null) ...[
                const SizedBox(height: 10),
                _dashboardStatusMessage(
                  context,
                  'Dashboard refresh failed. Showing the last loaded data.',
                  AppColors.errorRed,
                ),
              ],
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
                      stockAttentionCount == 0
                          ? 'No items are currently below their minimum stock level or out of stock.'
                          : '$stockAttentionCount ${stockAttentionCount == 1 ? 'item needs' : 'items need'} stock attention ($lowStockCount low, $outOfStockCount out of stock).',
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
                          'Total SKUs',
                          '$totalStock',
                          Icons.inventory_2_rounded,
                          AppColors.darkGreen,
                          'Live',
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
                          'Low',
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: _healthCard(
                          context,
                          'Out of Stock',
                          '$outOfStockCount',
                          Icons.remove_shopping_cart_outlined,
                          AppColors.errorRed,
                          'Zero',
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
                          'Live',
                        ),
                      ),
                      if (_canViewReportDashboard) ...[
                        SizedBox(
                          width: cardWidth,
                          child: _healthCard(
                            context,
                            'Expiring Soon',
                            '$expiringSoonCount',
                            Icons.event_busy_outlined,
                            AppColors.errorRed,
                            'Next 7d',
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: _healthCard(
                            context,
                            'Movements This Week',
                            '$movementsThisWeek',
                            Icons.swap_horiz_rounded,
                            AppColors.primaryBlue,
                            'This week',
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              Text('Stock attention',
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
              _buildActivityAlerts(context),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildLowStockCards(BuildContext context) {
    if (_lowStockItems.isEmpty) {
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
                    Text('No items are at or below their recorded minimum.',
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
        ),
      ];
    }

    return _lowStockItems.take(5).map((item) {
      final quantity = _numberValue(item['quantity']);
      final minimum = _numberValue(item['minimum_quantity']);
      final progress = minimum > 0
          ? (quantity / minimum).clamp(0.0, 1.0).toDouble()
          : 0.0;
      final color =
          quantity <= 0 ? AppColors.errorRed : AppColors.accentGold;
      final unit = item['unit']?.toString() ?? '';
      return _lowStockCard(
        context,
        item['name']?.toString() ?? 'Unknown item',
        '${_formatQuantity(quantity)} $unit on hand · minimum ${_formatQuantity(minimum)}',
        progress,
        color,
      );
    }).toList();
  }

  Widget _buildActivityAlerts(BuildContext context) {
    final entries = <Widget>[];
    for (final batch in _expiringBatches) {
      final days = (batch['days_until_expiry'] as num?)?.toInt() ?? 0;
      final status = batch['status']?.toString() ?? 'Expiry alert';
      final expiryMessage = days < 0
          ? 'Expired ${-days} ${-days == 1 ? 'day' : 'days'} ago'
          : days == 0
              ? 'Expires today'
              : 'Expires in $days ${days == 1 ? 'day' : 'days'}';
      final details = <String>[
        if ((batch['store']?.toString() ?? '').isNotEmpty)
          batch['store'].toString(),
        '${_formatQuantity(_numberValue(batch['quantity']))} ${batch['unit'] ?? ''}',
        if ((batch['batch_number']?.toString() ?? '').isNotEmpty)
          'Batch ${batch['batch_number']}',
      ].join(' · ');
      entries.add(_dashboardActivityRow(
        context,
        title: '${batch['item'] ?? 'Inventory item'} · $status',
        message: '$expiryMessage${details.isEmpty ? '' : ' · $details'}',
        time: _formatDateOnly(batch['expiry_date']?.toString()),
        icon: days < 0 ? Icons.error_outline_rounded : Icons.event_busy_outlined,
        color: days < 0 ? AppColors.errorRed : AppColors.accentGold,
      ));
    }

    for (final notification in _recentNotifications) {
      final category =
          (notification['category']?.toString() ?? '').toLowerCase();
      final icon = switch (category) {
        'purchases' => Icons.shopping_cart_outlined,
        'transfers' => Icons.swap_horiz_rounded,
        'kitchen' => Icons.restaurant_outlined,
        'waste' => Icons.delete_outline_rounded,
        _ => Icons.notifications_active_outlined,
      };
      entries.add(_dashboardActivityRow(
        context,
        title: notification['title']?.toString() ?? 'Notification',
        message: notification['message']?.toString() ?? '',
        time: _formatActivityTime(notification['created_at']?.toString()),
        icon: icon,
        color: AppColors.primaryBlue,
      ));
    }

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (expiredBatchItemTypes > 0) ...[
            _dashboardStatusMessage(
              context,
              'Remaining expired tracked batches are recorded for $expiredBatchItemTypes SKUs. Older batches may be counted here without appearing in the recent list.',
              AppColors.errorRed,
            ),
            if (entries.isNotEmpty || untrackedExpiryCount > 0)
              const SizedBox(height: 12),
          ],
          if (untrackedExpiryCount > 0) ...[
            _dashboardStatusMessage(
              context,
              'Expiry tracking is incomplete across $untrackedExpiryCount SKUs; some stock is not linked to a batch.',
              AppColors.accentGold,
            ),
            if (entries.isNotEmpty) const SizedBox(height: 12),
          ],
          if (entries.isEmpty &&
              _activityError == null &&
              expiredBatchItemTypes == 0 &&
              untrackedExpiryCount == 0)
            Text(
              'No recent notifications or tracked expiry warnings.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ...entries,
          if (_activityError != null) ...[
            if (entries.isNotEmpty) const SizedBox(height: 8),
            Text(
              'Recent notifications could not be loaded.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.errorRed,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _dashboardActivityRow(
    BuildContext context, {
    required String title,
    required String message,
    required String time,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                if (message.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                if (time.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(time, style: Theme.of(context).textTheme.bodySmall),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dashboardStatusMessage(
    BuildContext context,
    String message,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  double _numberValue(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _formatQuantity(double quantity) {
    return quantity == quantity.roundToDouble()
        ? quantity.toStringAsFixed(0)
        : quantity.toStringAsFixed(2);
  }

  String _formatActivityTime(String? value) {
    final date = DateTime.tryParse(value ?? '');
    if (date == null) return '';
    final local = date.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    if (local.year == DateTime.now().year &&
        local.month == DateTime.now().month &&
        local.day == DateTime.now().day) {
      return 'Today, $hour:$minute';
    }
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')} $hour:$minute';
  }

  String _formatDateOnly(String? value) {
    final date = DateTime.tryParse(value ?? '');
    if (date == null) return value ?? '';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
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
