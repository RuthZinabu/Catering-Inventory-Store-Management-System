import 'package:flutter/material.dart';
import 'consumption_report_screen.dart';

const _blue = Color(0xFF2563EB);
const _ink = Color(0xFF10162B);
const _muted = Color(0xFF64748B);
const _border = Color(0xFFE7ECF3);
const _green = Color(0xFF0B8A5E);
const _amber = Color(0xFFD97706);
const _red = Color(0xFFD1453B);

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _period = 'Daily';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverToBoxAdapter(child: _buildKpis()),
            SliverToBoxAdapter(child: _buildPeriodFilter()),
            SliverToBoxAdapter(child: _buildReportGrid(context)),
            SliverToBoxAdapter(child: _buildInsightBanner(context)),
            SliverToBoxAdapter(child: _buildFooter()),
            const SliverToBoxAdapter(child: SizedBox(height: 90)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
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
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: _ink, fontWeight: FontWeight.w800, letterSpacing: -0.7)),
                    const SizedBox(height: 4),
                    Row(
                      children: const [
                        Icon(Icons.circle, size: 7, color: _green),
                        SizedBox(width: 6),
                        Text('Daily · Weekly · Monthly',
                            style: TextStyle(color: _muted, fontSize: 12, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ),
              _roundIconButton(Icons.download_outlined, 'Export'),
              const SizedBox(width: 8),
              _roundIconButton(Icons.refresh_rounded, 'Refresh'),
            ],
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: () => _showDatePicker(context),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _border),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(.035), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: const Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 15, color: _blue),
                  SizedBox(width: 8),
                  Text('Aug 10 – Aug 16, 2026',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                  Spacer(),
                  Icon(Icons.expand_more_rounded, size: 18, color: Color(0xFF94A3B8)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }

  Widget _roundIconButton(IconData icon, String label) {
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: () {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$label report'), duration: const Duration(seconds: 1)),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _blue.withOpacity(.09),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 17, color: _blue),
        ),
      ),
    );
  }

  Widget _buildKpis() {
    const data = [
      ('Total Items', '1,284', '+12 vs last week', Icons.inventory_2_outlined, _blue),
      ('Inventory Value', 'ETB 48.2K', '+3.2% vs last month', Icons.account_balance_wallet_outlined, Color(0xFF0F766E)),
      ('Stock Movements', '347', '-8% vs last week', Icons.swap_vert_rounded, Color(0xFF7C3AED)),
      ('Expiring Soon', '23', '+5 in next 7 days', Icons.schedule_outlined, _amber),
      ('Waste This Week', 'ETB 1,240', '-2% vs last week', Icons.delete_outline_rounded, _red),
    ];

    return SizedBox(
      height: 112,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: data.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, index) {
          final item = data[index];
          final positive = item.$3.startsWith('+');
          return Container(
            width: 166,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _border),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(.035), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(item.$4, size: 15, color: item.$5),
                  const SizedBox(width: 6),
                  Expanded(child: Text(item.$1, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _muted))),
                ]),
                const SizedBox(height: 6),
                Text(item.$2, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: _ink)),
                const SizedBox(height: 2),
                Text(item.$3, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                    color: positive ? _green : _red)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPeriodFilter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: _border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: ['Daily', 'Weekly', 'Monthly'].map((period) {
            final active = _period == period;
            return GestureDetector(
              onTap: () => setState(() => _period = period),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
                decoration: BoxDecoration(
                  color: active ? _blue : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: active ? [BoxShadow(color: _blue.withOpacity(.25), blurRadius: 10, offset: const Offset(0, 4))] : null,
                ),
                child: Text(period, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                    color: active ? Colors.white : _muted)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildReportGrid(BuildContext context) {
    final cards = [
      _ReportCardData('Current Stock', 'Today', Icons.assignment_outlined, [
        ('Total SKUs', '1,284', _ink), ('In Stock', '1,102', _ink),
        ('Low Stock (< 10)', '46', _amber), ('Out of Stock', '18', _red), ('Stock Health', '● 86%', _green),
      ], 'View all'),
      _ReportCardData('Inventory Valuation', 'ETB 48.2K', Icons.monetization_on_outlined, [
        ('Raw Materials', 'ETB 22.4K', _ink), ('Work-in-Progress', 'ETB 8.7K', _ink),
        ('Finished Goods', 'ETB 17.1K', _ink), ('Avg. Cost / Item', 'ETB 37.60', _ink),
      ], 'Breakdown'),
      _ReportCardData('Stock Movement', 'Last 7d', Icons.swap_horiz_rounded, [
        ('Inbound (Received)', '+218', _green), ('Outbound (Issued)', '-192', _red),
        ('Transfers', '37', _ink), ('Net Change', '+26', _green),
      ], 'Details'),
      _ReportCardData('Purchase Report', 'This week', Icons.shopping_cart_outlined, [
        ('Orders Placed', '14', _ink), ('Items Ordered', '342', _ink),
        ('Total Spent', 'ETB 11,820', _ink), ('Avg. Order Value', 'ETB 844', _ink),
      ], 'Orders'),
      _ReportCardData('Supplier Report', 'Top 5', Icons.local_shipping_outlined, [
        ('Apex Supplies', 'ETB 4.2K', _ink), ('Riverside Ltd', 'ETB 3.8K', _ink),
        ('GreenLeaf Co', 'ETB 2.9K', _ink), ('On-time Delivery', '94%', _green),
      ], 'All suppliers'),
      _ReportCardData('Expiry Report', 'Urgent', Icons.hourglass_bottom_rounded, [
        ('Expiring in 0–3 days', '8', _red), ('Expiring in 4–7 days', '15', _amber),
        ('Expiring in 8–30 days', '34', _ink), ('Total at risk', '23', _red),
      ], 'Manage expiries'),
      _ReportCardData('Waste Report', 'This week', Icons.delete_outline_rounded, [
        ('Spoilage', 'ETB 740', _ink), ('Damaged', 'ETB 320', _ink),
        ('Expired', 'ETB 180', _ink), ('Waste as % of Sales', '1.8%', _ink),
      ], 'Analyze waste'),
      _ReportCardData('Consumption Report', 'This week', Icons.restaurant_outlined, [
        ('Total Consumption', '1,847 kg', _blue), ('Theoretical', '1,690 kg', _ink),
        ('Wastage', '87 kg', _amber), ('Variance Cost', 'ETB 710', _red),
      ], 'View consumption', highlighted: true),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 980 ? 3 : constraints.maxWidth >= 620 ? 2 : 1;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cards.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              mainAxisExtent: 246,
            ),
            itemBuilder: (context, index) {
              final card = cards[index];
              return _ReportCard(
                data: card,
                onTap: card.title == 'Consumption Report'
                    ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ConsumptionReportScreen()))
                    : () => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${card.title} details'), duration: const Duration(seconds: 1))),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInsightBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF3FF),
          borderRadius: BorderRadius.circular(16),
          border: const Border(left: BorderSide(color: _blue, width: 4)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.lightbulb_outline_rounded, color: _blue, size: 22),
            const SizedBox(width: 10),
            const Expanded(
              child: Text.rich(TextSpan(
                text: 'Insight: ',
                style: TextStyle(fontWeight: FontWeight.w800, color: _ink, fontSize: 12),
                children: [
                  TextSpan(text: 'Stock turnover is ', style: TextStyle(fontWeight: FontWeight.w500)),
                  TextSpan(text: '4.2x', style: TextStyle(fontWeight: FontWeight.w800)),
                  TextSpan(text: ' this month — above target. ', style: TextStyle(fontWeight: FontWeight.w500)),
                  TextSpan(text: 'Great performance!', style: TextStyle(color: _green, fontWeight: FontWeight.w700)),
                ],
              )),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Full report generation started'), duration: Duration(seconds: 1))),
              icon: const Icon(Icons.file_present_outlined, color: _green, size: 20),
              tooltip: 'Generate full report',
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 22, 20, 0),
      child: Center(
        child: Text('Data refreshed: Aug 16, 2026 14:32  •  Sample data for demonstration',
            textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
      ),
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025),
      lastDate: DateTime(2027),
      initialDateRange: DateTimeRange(
        start: DateTime(2026, 8, 10),
        end: DateTime(2026, 8, 16),
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
  final bool highlighted;

  const _ReportCardData(this.title, this.badge, this.icon, this.rows, this.action, {this.highlighted = false});
}

class _ReportCard extends StatelessWidget {
  final _ReportCardData data;
  final VoidCallback onTap;

  const _ReportCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
          decoration: BoxDecoration(
            color: data.highlighted ? const Color(0xFFFBFDFF) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: data.highlighted ? _blue.withOpacity(.28) : _border),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(.035), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(data.icon, color: _blue, size: 19),
                const SizedBox(width: 9),
                Expanded(child: Text(data.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _ink))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: data.highlighted ? _blue.withOpacity(.1) : const Color(0xFFF1F4F8),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(data.badge, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: _muted)),
                ),
              ]),
              const SizedBox(height: 10),
              Expanded(
                child: Column(
                  children: data.rows.map((row) => Container(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F4F8)))),
                    child: Row(children: [
                      Expanded(child: Text(row.$1, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, color: _muted, fontWeight: FontWeight.w500))),
                      Text(row.$2, style: TextStyle(fontSize: 11, color: row.$3, fontWeight: FontWeight.w800)),
                    ]),
                  )).toList(),
                ),
              ),
              const SizedBox(height: 7),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(data.action, style: const TextStyle(fontSize: 11, color: _blue, fontWeight: FontWeight.w800)),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right_rounded, color: _blue, size: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}