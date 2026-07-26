import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/suppliers/supplier_list_screen.dart';
import 'screens/purchases/purchase_list_screen.dart';
import 'screens/stock_transfers/stock_transfer_list_screen.dart';
import 'screens/kitchen_issues/kitchen_issue_list_screen.dart';
import 'services/mock_repository.dart';
import 'widgets/module_card.dart';
import 'utils/responsive.dart';

class CateringInventoryApp extends StatelessWidget {
  const CateringInventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB));
    return MaterialApp(
      title: 'Catering Control',
      debugShowCheckedModeBanner: false,
      // Force light appearance regardless of the device's system theme so
      // text/background colors never flip between platforms.
      themeMode: ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: scheme,
        scaffoldBackgroundColor: const Color(0xFFF4F6FB),
        cardTheme: const CardThemeData(elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24)))) ,
        appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0, backgroundColor: Colors.transparent, foregroundColor: Color(0xFF10162B)),
        // IMPORTANT: `Typography.material2021().englishLike` only provides font
        // metrics (size/weight/spacing) - it does NOT set a text color. Any
        // style pulled from it (headlineSmall, titleLarge, titleMedium,
        // titleSmall, etc.) therefore has `color: null`, which Flutter then
        // resolves using the ambient platform brightness. That resolves to
        // black on most desktop browsers but white on many phones/mobile
        // browsers - which is exactly the "black in browser, white on phone"
        // bug reported for the dashboard ('Admin', metric numbers), the
        // 'Inventory' heading, supplier name/company text, and the More
        // section. Fixing this means every text style must carry an explicit
        // color instead of relying on that platform-dependent fallback.
        textTheme: Typography.material2021().englishLike
            .apply(
              bodyColor: const Color(0xFF10162B),
              displayColor: const Color(0xFF10162B),
            )
            .copyWith(
          headlineSmall: Typography.material2021().englishLike.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: const Color(0xFF10162B),
              ),
          titleLarge: Typography.material2021().englishLike.titleLarge?.copyWith(
                color: const Color(0xFF10162B),
              ),
          titleMedium: Typography.material2021().englishLike.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF10162B),
              ),
          titleSmall: Typography.material2021().englishLike.titleSmall?.copyWith(
                color: const Color(0xFF10162B),
              ),
          bodyMedium: Typography.material2021().englishLike.bodyMedium?.copyWith(
                color: const Color(0xFF58627A),
              ),
          bodyLarge: Typography.material2021().englishLike.bodyLarge?.copyWith(
                color: const Color(0xFF10162B),
              ),
          bodySmall: Typography.material2021().englishLike.bodySmall?.copyWith(
                color: const Color(0xFF58627A),
              ),
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
      // Applied once, app-wide, so every screen - including screens pushed
      // via Navigator.push for details/forms - is responsive without needing
      // individual per-screen changes:
      //  1. Caps content to a readable max width and centers it on large
      //     screens (tablets, desktop browser windows) instead of letting
      //     it stretch edge-to-edge.
      //  2. Clamps extreme system font-scaling so large accessibility text
      //     sizes can't break card/grid layouts.
      builder: (context, child) {
        final clampedScaler = MediaQuery.textScalerOf(context).clamp(minScaleFactor: 0.85, maxScaleFactor: 1.3);
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: clampedScaler),
          child: ResponsiveContainer(child: child ?? const SizedBox.shrink()),
        );
      },
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
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 24, offset: const Offset(0, 12)),
          ],
          border: Border.all(color: const Color(0xFFE9EEF6)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: NavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            // Smaller overall bar: reduced height, compact icons, and a
            // smaller label so the bar takes up noticeably less vertical
            // space than the Material 3 default (~80px).
            height: 56,
            labelTextStyle: WidgetStateProperty.all(
              const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
            ),
            selectedIndex: _index,
            onDestinationSelected: (value) => setState(() => _index = value),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.grid_view_rounded, size: 20), label: 'Dashboard'),
              NavigationDestination(icon: Icon(Icons.inventory_2_outlined, size: 20), label: 'Inventory'),
              NavigationDestination(icon: Icon(Icons.business_outlined, size: 20), label: 'Suppliers'),
              NavigationDestination(icon: Icon(Icons.receipt_long, size: 20), label: 'Purchases'),
              NavigationDestination(icon: Icon(Icons.more_horiz_rounded, size: 20), label: 'More'),
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
  Widget build(BuildContext context) {
  return LayoutBuilder(
    builder: (context, constraints) {
      int crossAxisCount;
      if (constraints.maxWidth < 375) {
        crossAxisCount = 1;
      } else if (isDesktopWidth(constraints.maxWidth)) {
        crossAxisCount = 4;
      } else if (isTabletWidth(constraints.maxWidth)) {
        crossAxisCount = 3;
      } else {
        crossAxisCount = 2;
      }
      return ListView(
        padding: EdgeInsets.all(responsiveValue(context, mobile: 16, tablet: 24, desktop: 32)),
        children: [
          Text(
            'More modules',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 12),

          // A fixed childAspectRatio ties card height directly to cell
          // width (height = width / aspectRatio). Since cell width swings a
          // lot as the grid resizes and recalculates its column count, that
          // made card height balloon or shrink abnormally during resize.
          // Instead we target a constant, responsive card height and derive
          // the aspect ratio from it, using this GridView's own measured
          // width (not the outer LayoutBuilder's) so the math stays correct
          // even though it sits inside a padded ListView.
          LayoutBuilder(
            builder: (context, gridConstraints) {
              const spacing = 12.0;
              final cardHeight = responsiveValue(context, mobile: 150, tablet: 160, desktop: 172);
              final itemWidth = (gridConstraints.maxWidth - spacing * (crossAxisCount - 1)) / crossAxisCount;
              final aspectRatio = itemWidth / cardHeight;

              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: spacing,
                crossAxisSpacing: spacing,
                childAspectRatio: aspectRatio,
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
              );
            },
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