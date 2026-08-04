import 'package:flutter/material.dart';
import '../../models/stock_models.dart';
import '../../services/mock_repository.dart';
import 'stock_detail_screen.dart';
import 'stock_helpers.dart';

class CateringStockTab extends StatefulWidget {
  const CateringStockTab({super.key});

  @override
  State<CateringStockTab> createState() => _CateringStockTabState();
}

class _CateringStockTabState extends State<CateringStockTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final permanentItems =
        MockRepository.cateringStock.where((item) => item.subtype == CateringSubtype.permanent).toList();
    final temporaryItems =
        MockRepository.cateringStock.where((item) => item.subtype == CateringSubtype.temporary).toList();

    final filteredPermanent = permanentItems.where((item) {
      final matchesSearch = searchQuery.isEmpty ||
          item.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          item.category.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesSearch;
    }).toList();

    final filteredTemporary = temporaryItems.where((item) {
      final matchesSearch = searchQuery.isEmpty ||
          item.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          item.category.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesSearch;
    }).toList();

    final healthyPermanent =
        filteredPermanent.where((item) => item.status == 'Healthy').length;
    final lowStockPermanent =
        filteredPermanent.where((item) => item.status == 'Low Stock').length;

    final healthyTemporary =
        filteredTemporary.where((item) => item.status == 'Healthy').length;
    final lowStockTemporary =
        filteredTemporary.where((item) => item.status == 'Low Stock').length;

    return Column(
      children: [
        // Header with tab bar
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Catering Stock',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.6),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 6))
                      ],
                    ),
                    child: const Icon(Icons.workspace_premium_rounded, color: Color(0xFF7C3AED)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Reusable assets and consumables for events and service.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14.5),
              ),
              const SizedBox(height: 16),
              // Sub-tab bar (Permanent/Temporary)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 8))
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: const Color(0xFF7C3AED),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: const Color(0xFF64748B),
                  labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                  tabs: const [
                    Tab(text: 'Permanent'),
                    Tab(text: 'Temporary'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Search bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 8))
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        onChanged: (value) => setState(() => searchQuery = value),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Search catering items...',
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Permanent tab
              _buildCateringList(
                filteredPermanent,
                healthyPermanent,
                lowStockPermanent,
                'Permanent Assets',
                const Color(0xFF7C3AED),
              ),
              // Temporary tab
              _buildCateringList(
                filteredTemporary,
                healthyTemporary,
                lowStockTemporary,
                'Consumables',
                const Color(0xFFF59E0B),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCateringList(
    List<CateringStockItem> items,
    int healthyCount,
    int lowStockCount,
    String title,
    Color accentColor,
  ) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Row(
              children: [
                Expanded(
                  child: _summaryCard(title, '$healthyCount healthy', const Color(0xFF16A34A), Icons.check_circle_rounded),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _summaryCard('Low Stock', '$lowStockCount items', const Color(0xFFF59E0B), Icons.warning_amber_rounded),
                ),
              ],
            ),
          ),
        ),
        if (items.isEmpty)
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
                    final item = items[index];
                    final statusColor = stockStatusColor(item.status);
                    final stockFraction = (item.quantity / item.maxQuantity).clamp(0.0, 1.0);

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
                                        color: accentColor.withOpacity(0.14),
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: Icon(
                                        item.subtype == CateringSubtype.permanent
                                            ? Icons.workspace_premium_rounded
                                            : Icons.eco_rounded,
                                        color: accentColor,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  item.name,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium
                                                      ?.copyWith(
                                                          fontWeight: FontWeight.w700,
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
                                                  bgColor: accentColor.withOpacity(0.12),
                                                  textColor: accentColor),
                                              infoChip('${item.quantity} ${item.unit}'),
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
                                    color: accentColor,
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
                                          infoChip('ETB ${item.purchasePrice.toStringAsFixed(0)}'),
                                          infoChip(item.code),
                                          infoChip(item.location),
                                        ],
                                      ),
                                    ),
                                    if (item.isReserved == true) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF7C3AED).withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                        child: const Text(
                                          'Reserved',
                                          style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF7C3AED)),
                                        ),
                                      ),
                                    ],
                                    IconButton(
                                      onPressed: () {},
                                      icon: const Icon(Icons.more_horiz_rounded, color: Color(0xFF64748B)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }, childCount: items.length),
            ),
          ),
      ],
    );
  }

  Widget _summaryCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 14, offset: const Offset(0, 8))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
                color: color.withOpacity(0.14), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
