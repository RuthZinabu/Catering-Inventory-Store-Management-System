import 'package:flutter/material.dart';
import '../../models/stock_models.dart';
import '../../services/mock_repository.dart';
import 'stock_detail_screen.dart';
import 'stock_helpers.dart';
import '../../widgets/search_bar.dart';

class ElectronicsTab extends StatefulWidget {
  const ElectronicsTab({super.key});

  @override
  State<ElectronicsTab> createState() => _ElectronicsTabState();
}

class _ElectronicsTabState extends State<ElectronicsTab> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 420;
    final items = MockRepository.electronicsStock;

    final filteredItems = items.where((item) {
      final matchesSearch = searchQuery.isEmpty ||
          item.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          item.category.toLowerCase().contains(searchQuery.toLowerCase()) ||
          item.brand.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesSearch;
    }).toList();

    final healthyCount =
        filteredItems.where((item) => item.status == 'Healthy').length;
    final lowStockCount =
        filteredItems.where((item) => item.status == 'Low Stock').length;
    final maintenanceDueCount = filteredItems
        .where((item) =>
            item.maintenanceStatus == 'Due' ||
            item.maintenanceStatus == 'Overdue')
        .length;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
            child: Column(
              children: [
                // Search bar
                CateringSearch(
                  hintText: 'Search electronics...',
                  onChanged: (value) {
                    setState(() => searchQuery = value);
                  },
                ),
                const SizedBox(height: 16),
                // Summary cards - compact responsive layout

                isMobile
                    ? Column(
                        children: [
                          _summaryCard(
                            'Healthy',
                            '$healthyCount items',
                            const Color(0xFF16A34A),
                            Icons.check_circle_rounded,
                          ),
                          const SizedBox(height: 8),
                          _summaryCard(
                            'Low Stock',
                            '$lowStockCount items',
                            const Color(0xFFF59E0B),
                            Icons.warning_amber_rounded,
                          ),
                          const SizedBox(height: 8),
                          _summaryCard(
                            'Maintenance',
                            '$maintenanceDueCount',
                            const Color(0xFFF59E0B),
                            Icons.build_rounded,
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: _summaryCard(
                              'Healthy',
                              '$healthyCount items',
                              const Color(0xFF16A34A),
                              Icons.check_circle_rounded,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _summaryCard(
                              'Low Stock',
                              '$lowStockCount items',
                              const Color(0xFFF59E0B),
                              Icons.warning_amber_rounded,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _summaryCard(
                              'Maintenance',
                              '$maintenanceDueCount',
                              const Color(0xFFF59E0B),
                              Icons.build_rounded,
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
        if (filteredItems.isEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 112),
            sliver: SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 14,
                        offset: const Offset(0, 8))
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(Icons.electrical_services_outlined,
                        size: 44, color: Color(0xFF64748B)),
                    const SizedBox(height: 8),
                    Text('No electronics match this view',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('Try a broader search.',
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 112),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = filteredItems[index];
                final statusColor = stockStatusColor(item.status);
                final warrantyColor = _warrantyColor(item.warrantyStatus);
                final maintenanceColor =
                    _maintenanceColor(item.maintenanceStatus);
                final stockFraction =
                    (item.quantity / item.maxQuantity).clamp(0.0, 1.0);

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(14),
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
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => StockDetailScreen(item: item),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 66,
                                  height: 66,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0369A1)
                                        .withOpacity(0.14),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: const Icon(
                                    Icons.electrical_services_rounded,
                                    color: Color(0xFF0369A1),
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.name,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      letterSpacing: -0.2),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          statusBadge(item.status),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Wrap(
                                        spacing: 7,
                                        runSpacing: 6,
                                        children: [
                                          infoChip(item.category,
                                              bgColor: const Color(0xFF0369A1)
                                                  .withOpacity(0.12),
                                              textColor:
                                                  const Color(0xFF0369A1)),
                                          infoChip(item.brand),
                                          if (item.assetTag.isNotEmpty)
                                            infoChip(item.assetTag),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Text('Current stock',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF64748B))),
                                ),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    if (item.warrantyExpiry != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color:
                                              warrantyColor.withOpacity(0.12),
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.shield_rounded,
                                                size: 12),
                                            const SizedBox(width: 4),
                                            Text(item.warrantyStatus,
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w700,
                                                    color: warrantyColor)),
                                          ],
                                        ),
                                      ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color:
                                            maintenanceColor.withOpacity(0.12),
                                        borderRadius:
                                            BorderRadius.circular(999),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.build_rounded,
                                              size: 12),
                                          const SizedBox(width: 4),
                                          Text(item.maintenanceStatus,
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                  color: maintenanceColor)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: LinearProgressIndicator(
                                value: stockFraction,
                                minHeight: 7,
                                backgroundColor: const Color(0xFFF1F5F9),
                                color: const Color(0xFF0369A1),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      infoChip(
                                          'ETB ${item.purchasePrice.toStringAsFixed(0)}'),
                                      infoChip(item.code),
                                      infoChip(item.location),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.more_horiz_rounded,
                                      color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }, childCount: filteredItems.length),
            ),
          ),
      ],
    );
  }

  Color _warrantyStatusColor(String status) {
    switch (status) {
      case 'Active':
        return const Color(0xFF10B981);
      case 'Expiring Soon':
        return const Color(0xFFF59E0B);
      case 'Expired':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF64748B);
    }
  }

  Color _warrantyColor(String status) {
    switch (status) {
      case 'Active':
        return const Color(0xFF10B981);
      case 'Expiring Soon':
        return const Color(0xFFF59E0B);
      case 'Expired':
        return const Color(0xFFEF4444);
      case 'No Warranty':
        return const Color(0xFF64748B);
      default:
        return const Color(0xFF64748B);
    }
  }

  Color _maintenanceColor(String status) {
    switch (status) {
      case 'OK':
        return const Color(0xFF10B981);
      case 'Due':
        return const Color(0xFFF59E0B);
      case 'Overdue':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF64748B);
    }
  }

  Widget _summaryCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 14,
              offset: const Offset(0, 8))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: color.withOpacity(0.14),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 12),
                    maxLines: 1),
                const SizedBox(height: 2),
                Text(value,
                    style:
                        const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                    maxLines: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
