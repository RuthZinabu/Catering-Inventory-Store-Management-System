import 'package:flutter/material.dart';
import '../services/mock_repository.dart';
import '../utils/responsive.dart';
import '../theme/app_colors.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hPad = responsiveHorizontalPadding(context);
    return ListView(
      padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 120),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Good morning',
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text('Admin',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 12)
                      ]),
                  child: const Icon(Icons.notifications_none_rounded),
                ),
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.darkGreen,
                  child: const Text('H',
                      style: TextStyle(
                          color: Colors.amberAccent,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text('Today • 24 Jul 2026',
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.darkGreen,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppColors.accentGold.withOpacity(0.35),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.darkGreen.withOpacity(0.25),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: AppColors.glassGold,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.favorite_outline_rounded,
                      color: AppColors.accentGold,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Inventory health',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.accentGold,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.88),
                        height: 1.5,
                      ),
                  children: [
                    const TextSpan(
                      text: 'Everything is running smoothly. ',
                    ),
                    TextSpan(
                      text: '4 items',
                      style: const TextStyle(
                        color: AppColors.accentGold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const TextSpan(
                      text: ' need attention today.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            // Calculate how many items can fit dynamically, using the same
            // breakpoints as the rest of the app.
            double maxWidth = constraints.maxWidth;
            int crossAxisCount;
            if (maxWidth < 250) {
              crossAxisCount = 1; // Very small phones
            } else if (isDesktopWidth(maxWidth)) {
              crossAxisCount = 4; // Desktop
            } else if (isTabletWidth(maxWidth)) {
              crossAxisCount = 3; // Tablets
            } else {
              crossAxisCount = 2; // Phones
            }

            // Exact item width calculation removing the 12px spaces
            double spacing = 12.0;
            double itemWidth =
                (maxWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                SizedBox(
                  width: itemWidth,
                  child: _healthCard(
                    context,
                    'Total Stock',
                    '128',
                    Icons.inventory_2_rounded,
                    AppColors.darkGreen,
                    '+12%',
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _healthCard(
                    context,
                    'Low Alerts',
                    '4',
                    Icons.warning_amber_rounded,
                    AppColors.accentGold,
                    'Watch',
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _healthCard(
                    context,
                    'Expiring',
                    '7',
                    Icons.access_time_filled,
                    AppColors.errorRed,
                    '3 soon',
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _healthCard(
                    context,
                    "Today's Purchase",
                    'ETB 54k',
                    Icons.shopping_cart_outlined,
                    AppColors.darkGreen,
                    '+8%',
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _healthCard(
                    context,
                    "Today's Stock Out",
                    '3',
                    Icons.remove_circle_outline,
                    AppColors.darkGreen,
                    'Stable',
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _healthCard(
                    context,
                    'Inventory Value',
                    'ETB 840k',
                    Icons.account_balance_wallet_outlined,
                    AppColors.accentGold,
                    '+4%',
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _healthCard(
                    context,
                    'Recent Transactions',
                    '24',
                    Icons.receipt_long,
                    AppColors.darkGreen,
                    'Live',
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        Text('Quick actions',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _actionButton(
                context, Icons.add_rounded, 'Add Item', AppColors.primaryBlue),
            _actionButton(context, Icons.receipt_long, 'New Purchase',
                AppColors.darkGreen),
            _actionButton(context, Icons.local_shipping_outlined, 'Issue Stock',
                AppColors.secondaryGray),
            _actionButton(context, Icons.inventory_2_outlined, 'Receive Goods',
                AppColors.accentGold),
          ],
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Stock overview',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    Text('Last 30 days',
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 120,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                          child: _buildBar(38, AppColors.primaryBlue, 'W1')),
                      Expanded(child: _buildBar(58, AppColors.darkGreen, 'W2')),
                      Expanded(
                          child: _buildBar(48, AppColors.accentGreen, 'W3')),
                      Expanded(
                          child: _buildBar(72, AppColors.accentGold, 'W4')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text('Low stock',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        ...[
          _lowStockCard(context, 'Basmati Rice', '14 / 30 kg left', 0.47,
              AppColors.accentGold),
          _lowStockCard(context, 'Chicken Breast', '18 / 40 kg left', 0.45,
              AppColors.errorRed),
        ],
        const SizedBox(height: 20),
        Text('Recent activities',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        ...[
          _activityRow(context, Icons.add_circle_outline, 'PO-1048 received',
              '2 min ago', AppColors.primaryBlue),
          _activityRow(context, Icons.local_shipping_outlined,
              'Issued to kitchen', '18 min ago', AppColors.accentGreen),
          _activityRow(context, Icons.warning_amber_rounded, 'Low stock alert',
              '1 hr ago', AppColors.accentGold),
        ],
      ],
    );
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

  Widget _actionButton(
      BuildContext context, IconData icon, String label, Color color) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    // Two buttons per row on narrow phones, fixed comfortable width otherwise.
    final width = screenWidth < 250 ? (screenWidth - 20 * 2 - 12) / 2 : 155.0;
    return SizedBox(
      width: width,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildBar(double height, Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
              height: height,
              width: 20,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(10))),
          const SizedBox(height: 8),
          Text(label),
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

  Widget _activityRow(BuildContext context, IconData icon, String title,
      String time, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, 8))
          ]),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Text(title,
                  style: const TextStyle(fontWeight: FontWeight.w600))),
          Text(time, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
