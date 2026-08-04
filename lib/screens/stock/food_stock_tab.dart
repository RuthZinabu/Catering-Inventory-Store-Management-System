import 'package:catering_inventory_store_management_system/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import '../../models/stock_models.dart';
import '../../services/mock_repository.dart';
import 'stock_detail_screen.dart';
import 'stock_helpers.dart';

class FoodStockTab extends StatefulWidget {
  const FoodStockTab({super.key});

  @override
  State<FoodStockTab> createState() => _FoodStockTabState();
}

class _FoodStockTabState extends State<FoodStockTab> {
  String selectedCategory = 'All';
  String searchQuery = '';

  final List<String> categories = const [
    'All',
    'Meat',
    'Dairy',
    'Oil',
    'Vegetables',
    'Dry Food',
  ];

  @override
  Widget build(BuildContext context) {
    final filteredItems = MockRepository.foodStock.where((item) {
      final matchesCategory = selectedCategory == 'All' ||
          item.category == selectedCategory ||
          (selectedCategory == 'Dry Food' && item.category == 'Dry Food');
      final matchesSearch = searchQuery.isEmpty ||
          item.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          item.category.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    final healthyCount =
        filteredItems.where((item) => item.status == 'Healthy').length;
    final lowStockCount =
        filteredItems.where((item) => item.status == 'Low Stock').length;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Column(
              children: [
                // Search bar
                CateringSearch(
                  hintText: 'Search food items...',
                  onChanged: (value) {
                    setState(() => searchQuery = value);
                  },
                ),
                const SizedBox(height: 16),
                // Categories scroll
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.map((category) {
                      final isSelected = category == selectedCategory;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (_) =>
                              setState(() => selectedCategory = category),
                          selectedColor: const Color(0xFFDCEAFE),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? const Color(0xFF1D4ED8)
                                : const Color(0xFF475569),
                            fontWeight: FontWeight.w600,
                          ),
                          side: BorderSide.none,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                // Summary cards
                Row(
                  children: [
                    Expanded(
                      child: _summaryCard('Healthy', '$healthyCount items',
                          const Color(0xFF16A34A), Icons.check_circle_rounded),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _summaryCard('Low Stock', '$lowStockCount items',
                          const Color(0xFFF59E0B), Icons.warning_amber_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
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
                    const Icon(Icons.inventory_2_outlined,
                        size: 44, color: Color(0xFF64748B)),
                    const SizedBox(height: 8),
                    Text('No items match this view',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('Try a broader search or switch categories.',
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
                final accent = _accentForCategory(item.category);
                final statusColor = stockStatusColor(item.status);
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
                                    color: accent.withOpacity(0.14),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Icon(
                                    foodCategoryIcon(item.category),
                                    color: accent,
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
                                              bgColor: accent.withOpacity(0.12),
                                              textColor: accent),
                                          infoChip(
                                              '${item.quantity} ${item.unit}'),
                                          if (item.expiryDate != null)
                                            infoChip(
                                                'Expires: ${_formatDate(item.expiryDate!)}',
                                                bgColor: _expiryColor(
                                                        item.expiryDate!)
                                                    .withOpacity(0.12),
                                                textColor: _expiryColor(
                                                    item.expiryDate!)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text('Current stock',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF64748B))),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: LinearProgressIndicator(
                                value: stockFraction,
                                minHeight: 7,
                                backgroundColor: const Color(0xFFF1F5F9),
                                color: accent,
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

  Color _expiryColor(DateTime expiry) {
    final diff = expiry.difference(DateTime.now()).inDays;
    if (diff < 0) return const Color(0xFFEF4444);
    if (diff <= 7) return const Color(0xFFF59E0B);
    return const Color(0xFF10B981);
  }

  Widget _summaryCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
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
            width: 42,
            height: 42,
            decoration: BoxDecoration(
                color: color.withOpacity(0.14),
                borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        color: Color(0xFF64748B), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _accentForCategory(String category) {
    switch (category) {
      case 'Meat':
        return const Color(0xFFEF4444);
      case 'Dairy':
        return const Color(0xFF3B82F6);
      case 'Oil':
        return const Color(0xFF0F766E);
      case 'Vegetables':
        return const Color(0xFF10B981);
      case 'Dry Food':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF2563EB);
    }
  }
}
