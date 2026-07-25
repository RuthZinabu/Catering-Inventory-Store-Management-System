import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/suppliers/supplier_list_screen.dart';
import 'screens/purchases/purchase_list_screen.dart';
import 'screens/stock_transfers/stock_transfer_list_screen.dart';
import 'screens/kitchen_issues/kitchen_issue_list_screen.dart';
import 'services/mock_repository.dart';
import 'widgets/module_card.dart';

class CateringInventoryApp extends StatelessWidget {
  const CateringInventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB));
    return MaterialApp(
      title: 'Catering Control',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: const Color(0xFFF4F6FB),
        cardTheme: const CardThemeData(elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24)))) ,
        appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0, backgroundColor: Colors.transparent),
        textTheme: Typography.material2021().englishLike.copyWith(
          headlineSmall: Typography.material2021().englishLike.headlineSmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.5),
          titleMedium: Typography.material2021().englishLike.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          bodyMedium: Typography.material2021().englishLike.bodyMedium?.copyWith(color: const Color(0xFF58627A)),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            side: const BorderSide(color: Color(0xFFDCE4F0)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
        ),
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Color(0xFFE3E8F0))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Color(0xFFE3E8F0))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: scheme.primary, width: 1.5)),
        ),
      ),
      home: const RootShell(),
    );
  }
}

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  final List<Widget> _pages = const [
    DashboardScreen(),
    InventoryScreen(),
    SupplierListScreen(),
    PurchaseListScreen(),
    MorePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_index],
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () {},
      //   icon: const Icon(Icons.add_rounded),
      //   label: const Text('New'),
      // ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 24, offset: const Offset(0, 12)),
          ],
          border: Border.all(color: const Color(0xFFE9EEF6)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: NavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedIndex: _index,
            onDestinationSelected: (value) => setState(() => _index = value),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.grid_view_rounded), label: 'Dashboard'),
              NavigationDestination(icon: Icon(Icons.inventory_2_outlined), label: 'Inventory'),
              NavigationDestination(icon: Icon(Icons.business_outlined), label: 'Suppliers'),
              NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Purchases'),
              NavigationDestination(icon: Icon(Icons.more_horiz_rounded), label: 'More'),
            ],
          ),
        ),
      ),
    );
  }
}
 
class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
 @override
Widget build(BuildContext context) {
  return LayoutBuilder(
    builder: (context, constraints) {
      int crossAxisCount;
   //    constraints.maxWidth < 600 ? 2 : 3;
if (constraints.maxWidth < 375) {
  crossAxisCount = 1;
} else if (constraints.maxWidth < 600) {
  crossAxisCount = 2;
} else {
  crossAxisCount = 3;
}
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'More modules',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 12),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: crossAxisCount, // <-- use variable here
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.95,

            children: [
              ModuleCard(
                title: 'Transfers',
                subtitle: 'Adjustments, transfer and movement history',
                icon: Icons.swap_horiz_rounded,
                color: Colors.indigo,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StockTransferListScreen(),
                    ),
                  );
                },
              ),

              ModuleCard(
                title: 'Kitchen Issues',
                subtitle: 'Issue ingredients to cooking departments',
                icon: Icons.kitchen_outlined,
                color: Colors.orange,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const KitchenIssueListScreen(),
                    ),
                  );
                },
              ),

              ModuleCard(
                title: 'Recipes',
                subtitle: 'Ingredient breakdown and food costing',
                icon: Icons.receipt_long,
                color: Colors.green,
              ),

              ModuleCard(
                title: 'Waste',
                subtitle: 'Record wastage and losses',
                icon: Icons.delete_outline_rounded,
                color: Colors.red,
              ),

              ModuleCard(
                title: 'Expiry',
                subtitle: 'Monitor near-expiry and expired lots',
                icon: Icons.event_busy_outlined,
                color: Colors.purple,
              ),

              ModuleCard(
                title: 'Users',
                subtitle: 'View roles, permissions and audit trail',
                icon: Icons.people_outline_rounded,
                color: Colors.teal,
              ),
            ],
          ),

          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reports',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),

                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _chip('Current Stock'),
                      _chip('Inventory Valuation'),
                      _chip('Waste Report'),
                      _chip('Consumption Report'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    },
  );
}
  Widget _chip(String label) {
    return Chip(label: Text(label));
  }
}