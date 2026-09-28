import 'package:flutter/material.dart';

import 'screens/dashboard_screen.dart';
import 'screens/stock/stock_screen.dart';
import 'screens/suppliers/supplier_list_screen.dart';
import 'screens/purchases/purchase_list_screen.dart';
import 'screens/stock_transfers/stock_transfer_list_screen.dart';
import 'screens/kitchen_issues/kitchen_issue_list_screen.dart';
import 'screens/recipes/recipe_list_screen.dart';
import 'screens/waste/waste_list_screen.dart';
import 'screens/expiry/expiry_list_screen.dart';
import 'screens/users/user_list_screen.dart';
import 'screens/reports/reports_screen.dart';
import 'screens/barcode/barcode_management_screen.dart';
import 'screens/multistore/multistore_screen.dart';

import 'widgets/module_card.dart';
import 'utils/responsive.dart';
import 'theme/app_colors.dart';

class CateringInventoryApp extends StatelessWidget {
  const CateringInventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = const ColorScheme.light(
      primary: AppColors.primaryBlue,
      onPrimary: AppColors.darkGreen,
      secondary: AppColors.secondaryGray,
      onSecondary: Colors.white,
      tertiary: AppColors.accentGreen,
      onTertiary: AppColors.darkGreen,
      error: AppColors.errorRed,
      onError: Colors.white,
      surface: AppColors.cardSurface,
      onSurface: AppColors.darkGreen,
    );

    return MaterialApp(
      title: 'Catering Control',
      debugShowCheckedModeBanner: false,

      // Force light appearance regardless of device theme.
      themeMode: ThemeMode.light,

      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: scheme,
        scaffoldBackgroundColor: AppColors.creamBackground,
        cardTheme: const CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(24),
            ),
          ),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: AppColors.darkGreen,
          foregroundColor: Colors.white,
        ),
        textTheme: Typography.material2021()
            .englishLike
            .apply(
              bodyColor: AppColors.secondaryGray,
              displayColor: AppColors.darkGreen,
            )
            .copyWith(
              headlineSmall:
                  Typography.material2021().englishLike.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        color: AppColors.darkGreen,
                      ),
              titleLarge:
                  Typography.material2021().englishLike.titleLarge?.copyWith(
                        color: AppColors.darkGreen,
                      ),
              titleMedium:
                  Typography.material2021().englishLike.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkGreen,
                      ),
              titleSmall:
                  Typography.material2021().englishLike.titleSmall?.copyWith(
                        color: AppColors.darkGreen,
                      ),
              bodyMedium:
                  Typography.material2021().englishLike.bodyMedium?.copyWith(
                        color: AppColors.secondaryGray,
                      ),
              bodyLarge:
                  Typography.material2021().englishLike.bodyLarge?.copyWith(
                        color: AppColors.secondaryGray,
                      ),
              bodySmall:
                  Typography.material2021().englishLike.bodySmall?.copyWith(
                        color: AppColors.textGray,
                      ),
            ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: AppColors.darkGreen,
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 14,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 14,
            ),
            foregroundColor: AppColors.secondaryGray,
            side: const BorderSide(
              color: AppColors.secondaryGray,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: AppColors.darkGreen,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.secondaryGray,
          ),
          selectedColor: AppColors.primaryBlue,
          checkmarkColor: AppColors.darkGreen,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.cardSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: AppColors.border,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: AppColors.border,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: AppColors.primaryBlue,
              width: 1.5,
            ),
          ),
          hintStyle: const TextStyle(
            color: AppColors.textGray,
          ),
          labelStyle: const TextStyle(
            color: AppColors.secondaryGray,
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.border,
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? AppColors.accentGreen
                : null,
          ),
          checkColor: WidgetStateProperty.all(
            AppColors.darkGreen,
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? AppColors.accentGreen
                : null,
          ),
          trackColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? AppColors.accentGreen.withOpacity(.35)
                : null,
          ),
        ),
      ),

      // Applied once, app-wide, so every screen remains responsive.
      builder: (context, child) {
        final clampedScaler = MediaQuery.textScalerOf(context).clamp(
          minScaleFactor: 0.85,
          maxScaleFactor: 1.3,
        );

        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: clampedScaler,
          ),
          child: ResponsiveContainer(
            child: child ?? const SizedBox.shrink(),
          ),
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
    StockScreen(),
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

      // ---------------------------------------------------------
      // DARK GREEN + GOLD BOTTOM NAVIGATION
      // ---------------------------------------------------------
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(
          16,
          0,
          16,
          10,
        ),
        decoration: BoxDecoration(
          color: AppColors.darkGreen,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: NavigationBar(
            backgroundColor: AppColors.darkGreen,
            elevation: 0,
            height: 64,
            selectedIndex: _index,

            onDestinationSelected: (value) {
              setState(() {
                _index = value;
              });
            },

            // Subtle glass-gold selected indicator
            indicatorColor: AppColors.glassGold,
            surfaceTintColor: Colors.transparent,

            // Gold text
            labelTextStyle: WidgetStateProperty.resolveWith(
              (states) {
                final isSelected = states.contains(WidgetState.selected);

                return TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.accentGold
                      : const Color(0xFFD8C78A),
                );
              },
            ),

            destinations: const [
              NavigationDestination(
                icon: Icon(
                  Icons.grid_view_rounded,
                  color: Color(0xFFD8C78A),
                  size: 20,
                ),
                selectedIcon: Icon(
                  Icons.grid_view_rounded,
                  color: AppColors.accentGold,
                  size: 22,
                ),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.inventory_2_outlined,
                  color: Color(0xFFD8C78A),
                  size: 20,
                ),
                selectedIcon: Icon(
                  Icons.inventory_2_rounded,
                  color: AppColors.accentGold,
                  size: 22,
                ),
                label: 'Stock',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.business_outlined,
                  color: Color(0xFFD8C78A),
                  size: 20,
                ),
                selectedIcon: Icon(
                  Icons.business_rounded,
                  color: AppColors.accentGold,
                  size: 22,
                ),
                label: 'Suppliers',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.receipt_long_outlined,
                  color: Color(0xFFD8C78A),
                  size: 20,
                ),
                selectedIcon: Icon(
                  Icons.receipt_long,
                  color: AppColors.accentGold,
                  size: 22,
                ),
                label: 'Purchases',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.more_horiz_rounded,
                  color: Color(0xFFD8C78A),
                  size: 20,
                ),
                selectedIcon: Icon(
                  Icons.more_horiz_rounded,
                  color: AppColors.accentGold,
                  size: 22,
                ),
                label: 'More',
              ),
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

        final basePad = responsiveValue(
          context,
          mobile: 16.0,
          tablet: 24.0,
          desktop: 32.0,
        );

        // Extra bottom padding so the Reports card scrolls
        // fully above the navigation bar.
        final bottomPad = basePad + MediaQuery.of(context).padding.bottom + 80;

        return ListView(
          padding: EdgeInsets.fromLTRB(
            basePad,
            basePad,
            basePad,
            bottomPad,
          ),
          children: [
            Text(
              'More modules',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, gridConstraints) {
                const spacing = 12.0;

                final cardHeight = responsiveValue(
                  context,
                  mobile: 150,
                  tablet: 160,
                  desktop: 172,
                );

                final itemWidth = (gridConstraints.maxWidth -
                        spacing * (crossAxisCount - 1)) /
                    crossAxisCount;

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
                      icon: Icons.restaurant_menu_rounded,
                      color: Colors.green,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RecipeListScreen(),
                          ),
                        );
                      },
                    ),
                    ModuleCard(
                      title: 'Waste',
                      subtitle: 'Record wastage and losses',
                      icon: Icons.delete_outline_rounded,
                      color: Colors.red,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const WasteListScreen(),
                          ),
                        );
                      },
                    ),
                    ModuleCard(
                      title: 'Expiry',
                      subtitle: 'Monitor near-expiry and expired lots',
                      icon: Icons.event_busy_outlined,
                      color: Colors.purple,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ExpiryListScreen(),
                          ),
                        );
                      },
                    ),
                    ModuleCard(
                      title: 'Users',
                      subtitle: 'View roles, permissions and audit trail',
                      icon: Icons.people_outline_rounded,
                      color: Colors.teal,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const UserListScreen(),
                          ),
                        );
                      },
                    ),
                    ModuleCard(
                      title: 'Reports',
                      subtitle: 'Stock, purchases, waste, expiry & more',
                      icon: Icons.bar_chart_rounded,
                      color: Colors.blue,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ReportsScreen(),
                          ),
                        );
                      },
                    ),
                    ModuleCard(
                      title: 'Barcode',
                      subtitle: 'Generate, scan, print barcodes',
                      icon: Icons.qr_code_2,
                      color: const Color(0xFF6366F1),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BarcodeManagementScreen(),
                          ),
                        );
                      },
                    ),
                    ModuleCard(
                      title: 'Multi-Store',
                      subtitle: 'Manage multiple stores & locations',
                      icon: Icons.storefront,
                      color: const Color(0xFFEC4899),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MultiStoreScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}
