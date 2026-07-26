import 'package:flutter/material.dart';
import '../services/mock_repository.dart';
import '../utils/responsive.dart';

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
                  Text('Good morning', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text('Admin', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12)]),
                  child: const Icon(Icons.notifications_none_rounded),
                ),
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFF2563EB),
                  child: const Text('R', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text('Today • 24 Jul 2026', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF4F46E5)]),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.18), blurRadius: 24, offset: const Offset(0, 14))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.favorite_outline_rounded, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('Inventory health', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 12),
              Text('Everything is running smoothly. 4 items need attention today.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white.withOpacity(0.9))),
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
    double itemWidth = (maxWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: [
        SizedBox(width: itemWidth, child: _healthCard(context, 'Total Stock', '128', Icons.inventory_2_rounded, const Color(0xFF2563EB), '+12%')),
        SizedBox(width: itemWidth, child: _healthCard(context, 'Low Alerts', '4', Icons.warning_amber_rounded, const Color(0xFFF59E0B), 'Watch')),
        SizedBox(width: itemWidth, child: _healthCard(context, 'Expiring', '7', Icons.access_time_filled, const Color(0xFFEF4444), '3 soon')),
        SizedBox(width: itemWidth, child: _healthCard(context, 'Today\'s Purchase', 'ETB 54k', Icons.shopping_cart_outlined, const Color(0xFF10B981), '+8%')),
        SizedBox(width: itemWidth, child: _healthCard(context, 'Today\'s Stock Out', '3', Icons.remove_circle_outline, const Color(0xFF7C3AED), 'Stable')),
        SizedBox(width: itemWidth, child: _healthCard(context, 'Inventory Value', 'ETB 840k', Icons.account_balance_wallet_outlined, const Color(0xFF0F766E), '+4%')),
        SizedBox(width: itemWidth, child: _healthCard(context, 'Recent Transactions', '24', Icons.receipt_long, const Color(0xFF0EA5E9), 'Live')),
      ],
    );
  },
),

        const SizedBox(height: 20),
        Text('Quick actions', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _actionButton(context, Icons.add_rounded, 'Add Item', const Color(0xFF2563EB)),
            _actionButton(context, Icons.receipt_long, 'New Purchase', const Color(0xFF4F46E5)),
            _actionButton(context, Icons.local_shipping_outlined, 'Issue Stock', const Color(0xFF0F766E)),
            _actionButton(context, Icons.inventory_2_outlined, 'Receive Goods', const Color(0xFFF59E0B)),
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
                    Text('Stock overview', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    Text('Last 30 days', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 120,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(child: _buildBar(38, const Color(0xFF60A5FA), 'W1')),
                      Expanded(child: _buildBar(58, const Color(0xFF818CF8), 'W2')),
                      Expanded(child: _buildBar(48, const Color(0xFF34D399), 'W3')),
                      Expanded(child: _buildBar(72, const Color(0xFFF59E0B), 'W4')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text('Low stock', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        ...[
          _lowStockCard(context, 'Basmati Rice', '14 / 30 kg left', 0.47, const Color(0xFFF59E0B)),
          _lowStockCard(context, 'Chicken Breast', '18 / 40 kg left', 0.45, const Color(0xFFEF4444)),
        ],
        const SizedBox(height: 20),
        Text('Recent activities', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        ...[
          _activityRow(context, Icons.add_circle_outline, 'PO-1048 received', '2 min ago', const Color(0xFF2563EB)),
          _activityRow(context, Icons.local_shipping_outlined, 'Issued to kitchen', '18 min ago', const Color(0xFF10B981)),
          _activityRow(context, Icons.warning_amber_rounded, 'Low stock alert', '1 hr ago', const Color(0xFFF59E0B)),
        ],
      ],
    );
  }

  Widget _healthCard(BuildContext context, String title, String value, IconData icon, Color color, String trend) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
        border: Border.all(color: const Color(0xFFE9EEF8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(999)),
                child: Text(trend, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(title, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _actionButton(BuildContext context, IconData icon, String label, Color color) {
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
          Container(height: height, width: 20, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10))),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }

  Widget _lowStockCard(BuildContext context, String name, String detail, double progress, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 18, offset: const Offset(0, 8))]),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(16)),
            child: Icon(Icons.warning_amber_rounded, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w700))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(999)),
                      child: Text('Warning', style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 11)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(detail, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(value: progress, minHeight: 8, backgroundColor: const Color(0xFFF1F5F9), color: color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _activityRow(BuildContext context, IconData icon, String title, String time, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 8))]),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600))),
          Text(time, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}