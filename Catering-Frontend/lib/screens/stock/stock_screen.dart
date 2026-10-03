import 'package:flutter/material.dart';
import 'food_stock_tab.dart';
import 'catering_stock_tab.dart';
import 'electronics_tab.dart';
import 'food_stock_form_screen.dart';
import 'catering_stock_form_screen.dart';
import 'electronics_stock_form_screen.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _stockDataVersion = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header with tabs
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Stock',
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
                  const SizedBox(height: 2),
                  Text(
                    'Unified inventory across food, catering, and electronics.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  // Tab bar
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 0.001),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 8))
                      ],
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorPadding:
                          const EdgeInsets.symmetric(horizontal: -6),
                      labelPadding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 0),
                      indicator: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              const Color(0xFF2563EB), // Original purple border
                          width: 1.2,
                        ),
                      ),
                      labelColor: const Color(0xFF2563EB),
                      unselectedLabelColor:
                          const Color.fromARGB(255, 76, 83, 92),
                      labelStyle: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 10),
                      unselectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 10),
                      tabs: const [
                        Tab(height: 28, text: 'Food'),
                        Tab(height: 28, text: 'Catering'),
                        Tab(height: 28, text: 'Electronics'),
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
                  FoodStockTab(key: ValueKey('food-$_stockDataVersion')),
                  CateringStockTab(key: ValueKey('catering-$_stockDataVersion')),
                  ElectronicsTab(key: ValueKey('electronics-$_stockDataVersion')),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70),
        child: FloatingActionButton.extended(
          onPressed: () => _showCategorySelectionDialog(context),
          icon: const Icon(Icons.add_rounded),
          label: const Text('New Item'),
        ),
      ),
    );
  }

  Future<void> _openStockForm(Widget form) async {
    final uploaded = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => form),
    );
    if (uploaded == true && mounted) {
      setState(() => _stockDataVersion++);
    }
  }

  void _showCategorySelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add New Item',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Select a category to add a new stock item.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: const Color(0xFF64748B)),
              ),
              const SizedBox(height: 24),
              // Food option
              _buildCategoryCard(
                context,
                title: 'Food',
                description: 'Perishable food items',
                icon: Icons.restaurant_outlined,
                color: const Color(0xFFEF4444),
                onTap: () {
                  Navigator.of(context).pop();
                  _openStockForm(const FoodStockFormScreen());
                },
              ),
              const SizedBox(height: 12),
              // Catering option
              _buildCategoryCard(
                context,
                title: 'Catering',
                description: 'Permanent or temporary items',
                icon: Icons.workspace_premium_rounded,
                color: const Color(0xFF7C3AED),
                onTap: () => _showCateringSubtypeDialog(context),
              ),
              const SizedBox(height: 12),
              // Electronics option
              _buildCategoryCard(
                context,
                title: 'Electronics',
                description: 'Devices and equipment',
                icon: Icons.electrical_services_rounded,
                color: const Color(0xFF0369A1),
                onTap: () {
                  Navigator.of(context).pop();
                  _openStockForm(const ElectronicsStockFormScreen());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCateringSubtypeDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Catering Type',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Select a subtype for the catering item.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: const Color(0xFF64748B)),
              ),
              const SizedBox(height: 24),
              // Permanent option
              _buildCategoryCard(
                context,
                title: 'Permanent',
                description: 'Reusable assets for events',
                icon: Icons.workspace_premium_rounded,
                color: const Color(0xFF7C3AED),
                onTap: () {
                  Navigator.of(context).pop();
                  _openStockForm(
                    const CateringStockFormScreen(subtype: 'permanent'),
                  );
                },
              ),
              const SizedBox(height: 12),
              // Temporary option
              _buildCategoryCard(
                context,
                title: 'Temporary',
                description: 'Consumables for events',
                icon: Icons.eco_rounded,
                color: const Color(0xFFF59E0B),
                onTap: () {
                  Navigator.of(context).pop();
                  _openStockForm(
                    const CateringStockFormScreen(subtype: 'temporary'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: const Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: color, size: 16),
          ],
        ),
      ),
    );
  }
}
