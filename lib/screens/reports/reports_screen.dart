import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _period = 'Weekly';

  static const _cards = [
    _ReportCardData('Current Stock', 'Today', Icons.assignment_outlined, [
      ('Total SKUs', '1,284', AppColors.darkGreen),
      ('In Stock', '1,102', AppColors.accentGreen),
      ('Low Stock', '46', AppColors.accentGold),
      ('Out of Stock', '18', AppColors.errorRed),
    ], 'View all'),
    _ReportCardData('Inventory Valuation', 'ETB 48.2K', Icons.monetization_on_outlined, [
      ('Raw Materials', 'ETB 22.4K', AppColors.darkGreen),
      ('Work-in-Progress', 'ETB 8.7K', AppColors.darkGreen),
      ('Finished Goods', 'ETB 17.1K', AppColors.darkGreen),
      ('Avg. Cost / Item', 'ETB 37.60', AppColors.darkGreen),
    ], 'Breakdown'),
    _ReportCardData('Stock Movement', 'Last 7d', Icons.swap_horiz_rounded, [
      ('Inbound (Received)', '+218', AppColors.accentGreen),
      ('Outbound (Issued)', '-192', AppColors.errorRed),
      ('Transfers', '37', AppColors.darkGreen),
      ('Net Change', '+26', AppColors.accentGreen),
    ], 'Details'),
    _ReportCardData('Purchase Report', 'This week', Icons.shopping_cart_outlined, [
      ('Orders Placed', '14', AppColors.darkGreen),
      ('Items Ordered', '342', AppColors.darkGreen),
      ('Total Spent', 'ETB 11,820', AppColors.darkGreen),
      ('Avg. Order Value', 'ETB 844', AppColors.darkGreen),
    ], 'Orders'),
    _ReportCardData('Supplier Report', 'Top 5', Icons.local_shipping_outlined, [
      ('Apex Supplies', 'ETB 4.2K', AppColors.darkGreen),
      ('Riverside Ltd', 'ETB 3.8K', AppColors.darkGreen),
      ('GreenLeaf Co', 'ETB 2.9K', AppColors.darkGreen),
      ('On-time Delivery', '94%', AppColors.accentGreen),
    ], 'All suppliers'),
    _ReportCardData('Expiry Report', 'Urgent', Icons.hourglass_bottom_rounded, [
      ('Expiring in 0–3 days', '8', AppColors.errorRed),
      ('Expiring in 4–7 days', '15', AppColors.accentGold),
      ('Expiring in 8–30 days', '34', AppColors.darkGreen),
      ('Total at risk', '23', AppColors.errorRed),
    ], 'Manage expiries'),
    _ReportCardData('Waste Report', 'This week', Icons.delete_outline_rounded, [
      ('Spoilage', 'ETB 740', AppColors.darkGreen),
      ('Damaged', 'ETB 320', AppColors.darkGreen),
      ('Expired', 'ETB 180', AppColors.darkGreen),
      ('Waste as % of Sales', '1.8%', AppColors.darkGreen),
    ], 'Analyze waste'),
    _ReportCardData('Consumption Report', 'This week', Icons.restaurant_outlined, [
      ('Total Consumption', '1,847 kg', AppColors.primaryBlue),
      ('Theoretical', '1,690 kg', AppColors.darkGreen),
      ('Wastage', '87 kg', AppColors.accentGold),
      ('Variance Cost', 'ETB 710', AppColors.errorRed),
    ], 'View consumption'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _header(context)),
            SliverToBoxAdapter(child: _kpiStrip()),
            SliverToBoxAdapter(child: _periodFilter()),
            SliverToBoxAdapter(child: _reportGrid(context)),
            SliverToBoxAdapter(child: _insight(context)),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Inventory Reports',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    const Row(children: [
                      Icon(Icons.circle, size: 7, color: AppColors.accentGreen),
                      SizedBox(width: 6),
                      Text('Daily · Weekly · Monthly',
                          style: TextStyle(color: AppColors.secondaryGray, fontSize: 12)),
                    ]),
                  ],
                ),
              ),
              _headerAction(context, Icons.download_outlined, 'Export'),
              const SizedBox(width: 8),
              _headerAction(context, Icons.refresh_rounded, 'Refresh'),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: const Row(children: [
              Icon(Icons.calendar_today_outlined, size: 15, color: AppColors.primaryBlue),
              SizedBox(width: 8),
              Text('Aug 10 – Aug 16, 2026',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondaryGray)),
              Spacer(),
              Icon(Icons.expand_more_rounded, size: 17, color: AppColors.textGray),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _headerAction(BuildContext context, IconData icon, String label) {
    return InkWell(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$label report'), duration: const Duration(seconds: 1)),
      ),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withOpacity(.16),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 17, color: AppColors.darkGreen),
      ),
    );
  }

  Widget _kpiStrip() {
    const items = [
      ('Total Items', '1,284', '+12 vs last week', Icons.inventory_2_outlined, AppColors.primaryBlue),
      ('Inventory Value', 'ETB 48.2K', '+3.2% vs last month', Icons.account_balance_wallet_outlined, AppColors.accentGreen),
      ('Movements', '347', '-8% vs last week', Icons.swap_vert_rounded, AppColors.secondaryGray),
      ('Expiring Soon', '23', '+5 in next 7 days', Icons.schedule_outlined, AppColors.accentGold),
      ('Waste / Week', 'ETB 1,240', '-2% vs last week', Icons.delete_outline_rounded, AppColors.errorRed),
    ];
    return SizedBox(
      height: 108,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, index) {
          final item = items[index];
          return Container(
            width: 164,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(item.$4, color: item.$5, size: 15),
                const SizedBox(width: 6),
                Expanded(child: Text(item.$1, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: AppColors.secondaryGray))),
              ]),
              const SizedBox(height: 6),
              Text(item.$2, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.darkGreen)),
              Text(item.$3, style: TextStyle(fontSize: 10, color: item.$3.startsWith('+') ? AppColors.accentGreen : AppColors.errorRed)),
            ]),
          );
        },
      ),
    );
  }

  Widget _periodFilter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: ['Daily', 'Weekly', 'Monthly'].map((value) {
            final selected = _period == value;
            return GestureDetector(
              onTap: () => setState(() => _period = value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primaryBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                    color: selected ? AppColors.darkGreen : AppColors.secondaryGray)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _reportGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 980 ? 3 : constraints.maxWidth >= 620 ? 2 : 1;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _cards.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              mainAxisExtent: 232,
            ),
            itemBuilder: (_, index) => _reportCard(context, _cards[index]),
          );
        },
      ),
    );
  }

  Widget _reportCard(BuildContext context, _ReportCardData card) {
    return InkWell(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${card.title} details'), duration: const Duration(seconds: 1)),
      ),
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 13),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(card.icon, color: AppColors.primaryBlue, size: 19),
            const SizedBox(width: 9),
            Expanded(child: Text(card.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.darkGreen))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: AppColors.softSurface, borderRadius: BorderRadius.circular(20)),
              child: Text(card.badge, style: const TextStyle(fontSize: 9, color: AppColors.secondaryGray, fontWeight: FontWeight.w700)),
            ),
          ]),
          const SizedBox(height: 9),
          Expanded(
            child: Column(
              children: card.rows.map((row) => Container(
                padding: const EdgeInsets.symmetric(vertical: 7),
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
                child: Row(children: [
                  Expanded(child: Text(row.$1, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: AppColors.secondaryGray))),
                  Text(row.$2, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: row.$3)),
                ]),
              )).toList(),
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: const [
            Text('View details', style: TextStyle(fontSize: 11, color: AppColors.darkGreen, fontWeight: FontWeight.w800)),
            SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, color: AppColors.darkGreen, size: 16),
          ]),
        ]),
      ),
    );
  }

  Widget _insight(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withOpacity(.18),
          borderRadius: BorderRadius.circular(16),
          border: const Border(left: BorderSide(color: AppColors.primaryBlue, width: 4)),
        ),
        child: Row(children: [
          const Icon(Icons.lightbulb_outline_rounded, color: AppColors.darkGreen, size: 22),
          const SizedBox(width: 10),
          const Expanded(
            child: Text.rich(TextSpan(
              text: 'Insight: ',
              style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.darkGreen, fontSize: 12),
              children: [
                TextSpan(text: 'Stock turnover is 4.2x this month — above target. ',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                TextSpan(text: 'Great performance!',
                    style: TextStyle(color: AppColors.accentGreen, fontWeight: FontWeight.w800)),
              ],
            )),
          ),
          IconButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Full report generation started'), duration: Duration(seconds: 1)),
            ),
            icon: const Icon(Icons.file_present_outlined, color: AppColors.darkGreen, size: 20),
            visualDensity: VisualDensity.compact,
          ),
        ]),
      ),
    );
  }
}

class _ReportCardData {
  final String title;
  final String badge;
  final IconData icon;
  final List<(String, String, Color)> rows;
  final String action;

  const _ReportCardData(this.title, this.badge, this.icon, this.rows, this.action);
}