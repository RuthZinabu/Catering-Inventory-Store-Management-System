import 'package:flutter/material.dart';

import '../models/inventory_models.dart';
import '../services/api_repository.dart';
import '../widgets/loading_error_widgets.dart';
import 'inventory_detail_screen.dart';
import 'inventory_create_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String selectedCategory = 'All';
  String searchQuery = '';

  List<InventoryItem> _items = [];
  bool _isLoading = true;
  String? _error;

  final List<String> categories = const [
    'All',
    'Meat',
    'Vegetables',
    'Fruits',
    'Dairy',
    'Dry Food',
    'Beverages',
    'Spices',
    'Oil',
    'Cleaning Supplies',
    'Packaging Materials',
  ];

  @override
  void initState() {
    super.initState();
    _loadInventoryItems();
  }

  Future<void> _loadInventoryItems() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final items = await ApiRepository.instance.getInventoryItems(
        search: searchQuery.isEmpty ? null : searchQuery,
        category: selectedCategory == 'All' ? null : selectedCategory,
      );

      if (mounted) {
        setState(() {
          _items = items;
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

  void _onSearchChanged(String value) {
    setState(() {
      searchQuery = value;
    });

    // Debounce the API call
    Future.delayed(const Duration(milliseconds: 500), () {
      if (searchQuery == value) {
        _loadInventoryItems();
      }
    });
  }

  void _onCategoryChanged(String category) {
    setState(() {
      selectedCategory = category;
    });
    _loadInventoryItems();
  }

  @override
  Widget build(BuildContext context) {
    // Handle loading and error states
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: LoadingWidget()),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: CustomErrorWidget(
          error: _error!,
          onRetry: _loadInventoryItems,
        ),
      );
    }

    final filteredItems = _items;

    final healthyCount =
        filteredItems.where((item) => item.status == 'Healthy').length;
    final lowStockCount =
        filteredItems.where((item) => item.status == 'Low Stock').length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70),
        child: FloatingActionButton.extended(
          onPressed: () async {
            await Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const InventoryCreateScreen()));
            if (mounted) _loadInventoryItems();
          },
          icon: const Icon(Icons.add_rounded),
          label: const Text('New'),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Inventory',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.6),
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
                          child: const Icon(Icons.auto_awesome_rounded,
                              color: Color(0xFF2563EB)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Modern stock control for kitchen operations and replenishment.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontSize: 14.5),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
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
                          const Icon(Icons.search_rounded,
                              color: Color(0xFF64748B)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              onChanged: _onSearchChanged,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Search item or category',
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.tune_rounded,
                                color: Color(0xFF2563EB)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
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
                              onSelected: (_) => _onCategoryChanged(category),
                              selectedColor: const Color(0xFFDCEAFE),
                              labelStyle: TextStyle(
                                  color: isSelected
                                      ? const Color(0xFF1D4ED8)
                                      : const Color(0xFF475569),
                                  fontWeight: FontWeight.w600),
                              side: BorderSide.none,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                            child: _summaryCard(
                                'Healthy',
                                '$healthyCount items',
                                const Color(0xFF14B8A6),
                                Icons.check_circle_rounded)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _summaryCard(
                                'Low stock',
                                '$lowStockCount items',
                                const Color(0xFFF59E0B),
                                Icons.warning_amber_rounded)),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 112),
              sliver: filteredItems.isEmpty
                  ? SliverToBoxAdapter(
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
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final item = filteredItems[index];
                        final accent = _accentForCategory(item.category);
                        final statusColor = _statusColor(item.status);
                        final stockFraction = (item.stockOnHand != null &&
                                item.maxStock != null &&
                                item.maxStock! > 0)
                            ? (item.stockOnHand! / item.maxStock!)
                                .clamp(0.0, 1.0)
                            : 0.0;

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
                                      builder: (_) =>
                                          InventoryDetailScreen(item: item))),
                              child: Padding(
                                padding: const EdgeInsets.all(2),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 66,
                                          height: 66,
                                          decoration: BoxDecoration(
                                            color: accent.withOpacity(0.14),
                                            borderRadius:
                                                BorderRadius.circular(18),
                                          ),
                                          child: Icon(
                                              _iconForCategory(item.category),
                                              color: accent,
                                              size: 28),
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
                                                                  FontWeight
                                                                      .w700,
                                                              letterSpacing:
                                                                  -0.2),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8,
                                                        vertical: 5),
                                                    decoration: BoxDecoration(
                                                      color: statusColor
                                                          .withOpacity(0.12),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              999),
                                                    ),
                                                    child: Text(
                                                      item.status,
                                                      style: TextStyle(
                                                          color: statusColor,
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.w700),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Wrap(
                                                spacing: 7,
                                                runSpacing: 6,
                                                children: [
                                                  _infoChip(item.category),
                                                  _infoChip(
                                                      '${item.stockOnHand} ${item.unit}'),
                                                  _infoChip(
                                                      'Reorder ${item.reorderPoint}'),
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
                                                color:
                                                    const Color(0xFF64748B))),
                                    const SizedBox(height: 6),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(999),
                                      child: LinearProgressIndicator(
                                        value: stockFraction,
                                        minHeight: 7,
                                        backgroundColor:
                                            const Color(0xFFF1F5F9),
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
                                              _infoChip(
                                                  'ETB ${item.purchasePrice.toStringAsFixed(0)}'),
                                              _infoChip(item.code),
                                              _infoChip('Main Store'),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {},
                                          icon: const Icon(
                                              Icons.more_horiz_rounded,
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
        ),
      ),
    );
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

  Widget _infoChip(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(999)),
      child: Text(value,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155))),
    );
  }

  Color _accentForCategory(String category) {
    switch (category) {
      case 'Meat':
        return const Color(0xFFEF4444);
      case 'Vegetables':
        return const Color(0xFF10B981);
      case 'Fruits':
        return const Color.fromRGBO(245, 158, 11, 1);
      case 'Dairy':
        return const Color(0xFF3B82F6);
      case 'Beverages':
        return const Color(0xFF8B5CF6);
      case 'Spices':
        return const Color(0xFFEC4899);
      case 'Oil':
        return const Color(0xFF0F766E);
      case 'Cleaning Supplies':
        return const Color(0xFF6366F1);
      case 'Packaging Materials':
        return const Color(0xFF84CC16);
      default:
        return const Color(0xFF2563EB);
    }
  }

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'Meat':
        return Icons.kebab_dining_outlined;
      case 'Vegetables':
        return Icons.eco_outlined;
      case 'Fruits':
        return Icons.apple_outlined;
      case 'Dairy':
        return Icons.set_meal_outlined;
      case 'Beverages':
        return Icons.local_cafe_outlined;
      case 'Spices':
        return Icons.local_fire_department_outlined;
      case 'Oil':
        return Icons.oil_barrel_outlined;
      case 'Cleaning Supplies':
        return Icons.cleaning_services_outlined;
      case 'Packaging Materials':
        return Icons.inventory_2_outlined;
      default:
        return Icons.rice_bowl_outlined;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Low Stock':
        return const Color(0xFFF59E0B);
      case 'Healthy':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF64748B);
    }
  }
}
