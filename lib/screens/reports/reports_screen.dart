import 'package:flutter/material.dart';

import '../../services/mock_repository.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Reports',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.6),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                        style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.all(10)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Business intelligence across stock, purchases, waste and costs.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontSize: 14.5),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                children: [
                  _reportCard(
                    context,
                    title: 'Current Stock Report',
                    subtitle: 'Live inventory levels and low stock alerts',
                    color: const Color(0xFF2563EB),
                    icon: Icons.inventory_2_rounded,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const _CurrentStockScreen())),
                  ),
                  _reportCard(
                    context,
                    title: 'Inventory Valuation',
                    subtitle: 'Total value of stock on hand by item',
                    color: const Color(0xFF0F766E),
                    icon: Icons.account_balance_wallet_outlined,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const _InventoryValuationScreen())),
                  ),
                  _reportCard(
                    context,
                    title: 'Stock Movement',
                    subtitle: 'Track inflow and outflow of inventory items',
                    color: const Color(0xFF7C3AED),
                    icon: Icons.swap_vert_rounded,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const _PlaceholderReportScreen(
                                  title: 'Stock Movement',
                                  icon: Icons.swap_vert_rounded,
                                  color: Color(0xFF7C3AED),
                                ))),
                  ),
                  _reportCard(
                    context,
                    title: 'Purchase Report',
                    subtitle: 'Spend analysis and purchase order history',
                    color: const Color(0xFF4F46E5),
                    icon: Icons.receipt_long,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const _PurchaseReportScreen())),
                  ),
                  _reportCard(
                    context,
                    title: 'Supplier Report',
                    subtitle: 'Supplier performance and order statistics',
                    color: const Color(0xFF0369A1),
                    icon: Icons.business_outlined,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const _PlaceholderReportScreen(
                                  title: 'Supplier Report',
                                  icon: Icons.business_outlined,
                                  color: Color(0xFF0369A1),
                                ))),
                  ),
                  _reportCard(
                    context,
                    title: 'Expiry Report',
                    subtitle: 'Items nearing expiry and expired stock',
                    color: const Color(0xFFB45309),
                    icon: Icons.event_busy_outlined,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const _PlaceholderReportScreen(
                                  title: 'Expiry Report',
                                  icon: Icons.event_busy_outlined,
                                  color: Color(0xFFB45309),
                                ))),
                  ),
                  _reportCard(
                    context,
                    title: 'Waste Report',
                    subtitle: 'Track wastage by reason and category',
                    color: const Color(0xFFEF4444),
                    icon: Icons.delete_outline_rounded,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const _WasteReportScreen())),
                  ),
                  _reportCard(
                    context,
                    title: 'Consumption Report',
                    subtitle: 'Daily consumption patterns and trends',
                    color: const Color(0xFF16A34A),
                    icon: Icons.restaurant_menu_rounded,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const _PlaceholderReportScreen(
                                  title: 'Consumption Report',
                                  icon: Icons.restaurant_menu_rounded,
                                  color: Color(0xFF16A34A),
                                ))),
                  ),
                  _reportCard(
                    context,
                    title: 'Daily & Monthly Inventory Report',
                    subtitle: 'Periodic inventory summaries and snapshots',
                    color: const Color(0xFF64748B),
                    icon: Icons.calendar_month_outlined,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const _PlaceholderReportScreen(
                                  title: 'Daily & Monthly Inventory Report',
                                  icon: Icons.calendar_month_outlined,
                                  color: Color(0xFF64748B),
                                ))),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reportCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14)),
                  child: Icon(icon, color: color, size: 21),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15)),
                      const SizedBox(height: 3),
                      Text(subtitle,
                          style: const TextStyle(
                              color: Color(0xFF64748B), fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: Color(0xFFCBD5E1)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── _ReportDetailShell ───────────────────────────────────────────────────────

class _ReportDetailShell extends StatelessWidget {
  final String title;
  final Widget child;
  const _ReportDetailShell({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(title,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.6)),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                        style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.all(10)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

// ── Placeholder screen ───────────────────────────────────────────────────────

class _PlaceholderReportScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  const _PlaceholderReportScreen(
      {required this.title, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded),
                style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.all(10)),
              ),
              const SizedBox(height: 16),
              Text(title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800, letterSpacing: -0.6)),
              const Spacer(),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(24)),
                      child: Icon(icon, color: color, size: 36),
                    ),
                    const SizedBox(height: 16),
                    Text('$title data coming soon.',
                        style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Wrapper screens ──────────────────────────────────────────────────────────

class _CurrentStockScreen extends StatelessWidget {
  const _CurrentStockScreen();
  @override
  Widget build(BuildContext context) => const _ReportDetailShell(
        title: 'Current Stock Report',
        child: _StockReport(),
      );
}

class _InventoryValuationScreen extends StatelessWidget {
  const _InventoryValuationScreen();
  @override
  Widget build(BuildContext context) => const _ReportDetailShell(
        title: 'Inventory Valuation',
        child: _StockReport(),
      );
}

class _PurchaseReportScreen extends StatelessWidget {
  const _PurchaseReportScreen();
  @override
  Widget build(BuildContext context) => const _ReportDetailShell(
        title: 'Purchase Report',
        child: _PurchaseReport(),
      );
}

class _WasteReportScreen extends StatelessWidget {
  const _WasteReportScreen();
  @override
  Widget build(BuildContext context) => const _ReportDetailShell(
        title: 'Waste Report',
        child: _WasteReport(),
      );
}

// ── Stock Report ─────────────────────────────────────────────────────────────

class _StockReport extends StatelessWidget {
  const _StockReport();

  @override
  Widget build(BuildContext context) {
    final items = MockRepository.items;
    final totalValue =
        items.fold<double>(0, (s, i) => s + i.stockOnHand * i.purchasePrice);
    final lowStock = items.where((i) => i.status == 'Low Stock').toList();
    final healthy = items.where((i) => i.status == 'Healthy').toList();

    // Category breakdown
    final Map<String, int> catCount = {};
    for (final item in items) {
      catCount[item.category] = (catCount[item.category] ?? 0) + 1;
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      children: [
        // KPI row
        Row(children: [
          Expanded(
              child: _kpiCard('Total Items', '${items.length}',
                  const Color(0xFF2563EB), Icons.inventory_2_rounded)),
          const SizedBox(width: 10),
          Expanded(
              child: _kpiCard(
                  'Inv. Value',
                  'ETB ${(totalValue / 1000).toStringAsFixed(0)}k',
                  const Color(0xFF0F766E),
                  Icons.account_balance_wallet_outlined)),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
              child: _kpiCard('Low Stock', '${lowStock.length}',
                  const Color(0xFFF59E0B), Icons.warning_amber_rounded)),
          const SizedBox(width: 10),
          Expanded(
              child: _kpiCard('Healthy', '${healthy.length}',
                  const Color(0xFF16A34A), Icons.check_circle_outline_rounded)),
        ]),
        const SizedBox(height: 16),
        _sectionTitle(context, 'Inventory Valuation by Item'),
        const SizedBox(height: 10),
        ...items.map((item) {
          final value = item.stockOnHand * item.purchasePrice;
          final fraction = totalValue > 0 ? value / totalValue : 0.0;
          return _barRow(
              context,
              item.name,
              item.category,
              'ETB ${value.toStringAsFixed(0)}',
              fraction,
              const Color(0xFF2563EB));
        }),
        const SizedBox(height: 16),
        _sectionTitle(context, 'Low Stock Alerts'),
        const SizedBox(height: 10),
        if (lowStock.isEmpty)
          _emptyCard(context, 'All items are at healthy levels.')
        else
          ...lowStock.map((item) => _alertRow(
              context,
              item.name,
              '${item.stockOnHand} / ${item.maxStock} ${item.unit}',
              item.stockOnHand / item.maxStock,
              const Color(0xFFF59E0B))),
        const SizedBox(height: 80),
      ],
    );
  }
}

// ── Purchase Report ──────────────────────────────────────────────────────────

class _PurchaseReport extends StatelessWidget {
  const _PurchaseReport();

  @override
  Widget build(BuildContext context) {
    final purchases = MockRepository.purchases;
    final totalSpend = purchases.fold<double>(0, (s, p) => s + p.total);
    final totalVat = purchases.fold<double>(0, (s, p) => s + p.vat);
    final totalDiscount = purchases.fold<double>(0, (s, p) => s + p.discount);

    // Supplier spend
    final Map<String, double> supplierSpend = {};
    for (final p in purchases) {
      supplierSpend[p.supplier] = (supplierSpend[p.supplier] ?? 0) + p.total;
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      children: [
        Row(children: [
          Expanded(
              child: _kpiCard(
                  'Total Spend',
                  'ETB ${totalSpend.toStringAsFixed(0)}',
                  const Color(0xFF4F46E5),
                  Icons.shopping_cart_outlined)),
          const SizedBox(width: 10),
          Expanded(
              child: _kpiCard('Orders', '${purchases.length}',
                  const Color(0xFF2563EB), Icons.receipt_long)),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
              child: _kpiCard('Total VAT', 'ETB ${totalVat.toStringAsFixed(0)}',
                  const Color(0xFFF59E0B), Icons.percent_rounded)),
          const SizedBox(width: 10),
          Expanded(
              child: _kpiCard(
                  'Discounts',
                  'ETB ${totalDiscount.toStringAsFixed(0)}',
                  const Color(0xFF16A34A),
                  Icons.local_offer_outlined)),
        ]),
        const SizedBox(height: 16),
        _sectionTitle(context, 'Spend by Supplier'),
        const SizedBox(height: 10),
        ...supplierSpend.entries.map((e) {
          final frac = totalSpend > 0 ? e.value / totalSpend : 0.0;
          return _barRow(
              context,
              e.key,
              'Supplier',
              'ETB ${e.value.toStringAsFixed(0)}',
              frac,
              const Color(0xFF4F46E5));
        }),
        const SizedBox(height: 16),
        _sectionTitle(context, 'Purchase Orders'),
        const SizedBox(height: 10),
        ...purchases.map((p) => _purchaseRow(
            context, p.number, p.supplier, p.item, p.total, p.date)),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _purchaseRow(BuildContext context, String number, String supplier,
      String item, double total, DateTime date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 6))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
                color: const Color(0xFFEDE9FE),
                borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.receipt_long,
                color: Color(0xFF4F46E5), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(number,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13)),
                Text('$supplier • $item',
                    style: const TextStyle(
                        color: Color(0xFF64748B), fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('ETB ${total.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: Color(0xFF4F46E5))),
              Text('${date.day}/${date.month}/${date.year}',
                  style:
                      const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Waste Report ─────────────────────────────────────────────────────────────

class _WasteReport extends StatelessWidget {
  const _WasteReport();

  @override
  Widget build(BuildContext context) {
    final records = MockRepository.wasteRecords;
    final totalLoss = records.fold<double>(0, (s, r) => s + r.estimatedCost);
    final confirmed = records.where((r) => r.status == 'Confirmed').length;
    final pending = records.where((r) => r.status == 'Pending Review').length;

    // Waste by reason
    final Map<String, double> byReason = {};
    for (final r in records) {
      byReason[r.reason] = (byReason[r.reason] ?? 0) + r.estimatedCost;
    }

    // Waste by category
    final Map<String, double> byCat = {};
    for (final r in records) {
      byCat[r.category] = (byCat[r.category] ?? 0) + r.estimatedCost;
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      children: [
        Row(children: [
          Expanded(
              child: _kpiCard(
                  'Total Loss',
                  'ETB ${totalLoss.toStringAsFixed(0)}',
                  const Color(0xFFEF4444),
                  Icons.money_off_rounded)),
          const SizedBox(width: 10),
          Expanded(
              child: _kpiCard('Records', '${records.length}',
                  const Color(0xFF64748B), Icons.list_alt_rounded)),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
              child: _kpiCard('Confirmed', '$confirmed',
                  const Color(0xFF475569), Icons.check_circle_outline_rounded)),
          const SizedBox(width: 10),
          Expanded(
              child: _kpiCard('Pending', '$pending', const Color(0xFFF59E0B),
                  Icons.pending_actions_rounded)),
        ]),
        const SizedBox(height: 16),
        _sectionTitle(context, 'Loss by Reason'),
        const SizedBox(height: 10),
        ...byReason.entries.map((e) {
          final frac = totalLoss > 0 ? e.value / totalLoss : 0.0;
          return _barRow(
              context,
              e.key,
              'Reason',
              'ETB ${e.value.toStringAsFixed(0)}',
              frac,
              const Color(0xFFEF4444));
        }),
        const SizedBox(height: 16),
        _sectionTitle(context, 'Loss by Category'),
        const SizedBox(height: 10),
        ...byCat.entries.map((e) {
          final frac = totalLoss > 0 ? e.value / totalLoss : 0.0;
          return _barRow(
              context,
              e.key,
              'Category',
              'ETB ${e.value.toStringAsFixed(0)}',
              frac,
              const Color(0xFF7C3AED));
        }),
        const SizedBox(height: 16),
        _sectionTitle(context, 'Waste Records'),
        const SizedBox(height: 10),
        ...records.map((r) => _wasteRow(
            context, r.number, r.item, r.reason, r.estimatedCost, r.status)),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _wasteRow(BuildContext context, String number, String item,
      String reason, double cost, String status) {
    final statusColor = status == 'Confirmed'
        ? const Color(0xFF64748B)
        : const Color(0xFFF59E0B);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 6))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.delete_outline_rounded,
                color: Color(0xFFEF4444), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$number • $item',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13)),
                Text(reason,
                    style: const TextStyle(
                        color: Color(0xFF64748B), fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('ETB ${cost.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: Color(0xFFEF4444))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999)),
                child: Text(status,
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Food Cost Report ─────────────────────────────────────────────────────────

class _FoodCostReport extends StatelessWidget {
  const _FoodCostReport();

  @override
  Widget build(BuildContext context) {
    final recipes = MockRepository.recipeItems;
    final activeRecipes = recipes.where((r) => r.status == 'Active').toList();
    final avgCostPct = activeRecipes.isEmpty
        ? 0.0
        : activeRecipes.fold<double>(0, (s, r) => s + r.foodCostPercentage) /
            activeRecipes.length;
    final totalFoodCost =
        activeRecipes.fold<double>(0, (s, r) => s + r.totalFoodCost);
    final totalRevenue =
        activeRecipes.fold<double>(0, (s, r) => s + r.sellingPrice);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      children: [
        Row(children: [
          Expanded(
              child: _kpiCard(
                  'Avg Cost %',
                  '${avgCostPct.toStringAsFixed(1)}%',
                  avgCostPct > 35
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF16A34A),
                  Icons.percent_rounded)),
          const SizedBox(width: 10),
          Expanded(
              child: _kpiCard('Active Recipes', '${activeRecipes.length}',
                  const Color(0xFF16A34A), Icons.restaurant_menu_rounded)),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
              child: _kpiCard(
                  'Total Food Cost',
                  'ETB ${totalFoodCost.toStringAsFixed(0)}',
                  const Color(0xFFEF4444),
                  Icons.shopping_basket_rounded)),
          const SizedBox(width: 10),
          Expanded(
              child: _kpiCard(
                  'Total Revenue',
                  'ETB ${totalRevenue.toStringAsFixed(0)}',
                  const Color(0xFF2563EB),
                  Icons.sell_rounded)),
        ]),
        const SizedBox(height: 16),
        _sectionTitle(context, 'Food Cost % by Recipe'),
        const SizedBox(height: 10),
        ...activeRecipes.map((r) {
          final color = r.foodCostPercentage > 40
              ? const Color(0xFFEF4444)
              : r.foodCostPercentage > 30
                  ? const Color(0xFFF59E0B)
                  : const Color(0xFF16A34A);
          return _barRow(
            context,
            r.name,
            r.category,
            '${r.foodCostPercentage.toStringAsFixed(1)}%',
            (r.foodCostPercentage / 100).clamp(0.0, 1.0),
            color,
          );
        }),
        const SizedBox(height: 16),
        _sectionTitle(context, 'Recipe Breakdown'),
        const SizedBox(height: 10),
        ...activeRecipes.map((r) => _recipeRow(context, r.name, r.category,
            r.totalFoodCost, r.sellingPrice, r.foodCostPercentage)),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _recipeRow(BuildContext context, String name, String category,
      double foodCost, double selling, double pct) {
    final color = pct > 40
        ? const Color(0xFFEF4444)
        : pct > 30
            ? const Color(0xFFF59E0B)
            : const Color(0xFF16A34A);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 6))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.restaurant_menu_rounded,
                color: Color(0xFF16A34A), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13)),
                Text(category,
                    style: const TextStyle(
                        color: Color(0xFF64748B), fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('ETB ${foodCost.toStringAsFixed(0)} cost',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: Color(0xFF334155))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999)),
                child: Text('${pct.toStringAsFixed(1)}%',
                    style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

Widget _kpiCard(String title, String value, Color color, IconData icon) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8))
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14)),
          child: Icon(icon, color: color, size: 21),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 16, color: color)),
              const SizedBox(height: 2),
              Text(title,
                  style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _sectionTitle(BuildContext context, String title) {
  return Text(title,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(fontWeight: FontWeight.w700));
}

Widget _barRow(BuildContext context, String title, String subtitle,
    String valueLabel, double fraction, Color color) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6))
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13)),
                  Text(subtitle,
                      style: const TextStyle(
                          color: Color(0xFF64748B), fontSize: 11)),
                ],
              ),
            ),
            Text(valueLabel,
                style: TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 13, color: color)),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: fraction.clamp(0.0, 1.0),
            minHeight: 7,
            backgroundColor: const Color(0xFFF1F5F9),
            color: color,
          ),
        ),
      ],
    ),
  );
}

Widget _alertRow(BuildContext context, String name, String detail,
    double fraction, Color color) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: color.withOpacity(0.3)),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6))
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(Icons.warning_amber_rounded, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
              child: Text(name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 13))),
          Text(detail,
              style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 12, color: color)),
        ]),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: fraction.clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: const Color(0xFFF1F5F9),
            color: color,
          ),
        ),
      ],
    ),
  );
}

Widget _emptyCard(BuildContext context, String message) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      children: [
        const Icon(Icons.check_circle_outline_rounded,
            color: Color(0xFF16A34A)),
        const SizedBox(width: 10),
        Text(message,
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: Color(0xFF16A34A))),
      ],
    ),
  );
}
