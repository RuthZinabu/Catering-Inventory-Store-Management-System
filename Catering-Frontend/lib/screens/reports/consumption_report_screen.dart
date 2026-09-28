import 'package:flutter/material.dart';

const _consumptionBlue = Color(0xFF2A7DE1);
const _consumptionInk = Color(0xFF1A2639);
const _consumptionMuted = Color(0xFF64748B);
const _consumptionBorder = Color(0xFFEEF2F6);
const _consumptionGreen = Color(0xFF0B8A5E);
const _consumptionAmber = Color(0xFFD97706);
const _consumptionRed = Color(0xFFD1453B);

class ConsumptionReportScreen extends StatefulWidget {
  const ConsumptionReportScreen({super.key});

  @override
  State<ConsumptionReportScreen> createState() => _ConsumptionReportScreenState();
}

class _ConsumptionReportScreenState extends State<ConsumptionReportScreen> {
  String _range = 'This Week';
  String _search = '';
  String _filter = 'All';
  String _sort = 'Consumption';
  bool _filtersVisible = false;

  final List<_ConsumptionItem> _items = const [
    _ConsumptionItem('Chicken', 'Meat', 184.2, 172.0, 6.5, 2.1, _ConsumptionStatus.normal),
    _ConsumptionItem('Rice', 'Grains', 165.8, 151.0, 5.8, 9.8, _ConsumptionStatus.moderate),
    _ConsumptionItem('Tomato', 'Vegetables', 124.5, 116.0, 3.2, 7.3, _ConsumptionStatus.moderate),
    _ConsumptionItem('Cooking Oil', 'Ingredients', 98.4, 94.0, 1.4, 3.2, _ConsumptionStatus.normal),
    _ConsumptionItem('Onion', 'Vegetables', 86.1, 84.0, 2.4, 2.1, _ConsumptionStatus.normal),
    _ConsumptionItem('Beef', 'Meat', 79.6, 66.0, 6.8, 10.3, _ConsumptionStatus.high),
    _ConsumptionItem('Flour', 'Grains', 72.3, 69.0, 1.7, 3.0, _ConsumptionStatus.normal),
    _ConsumptionItem('Milk', 'Dairy', 58.7, 54.0, 2.2, 8.1, _ConsumptionStatus.moderate),
    _ConsumptionItem('Black Pepper', 'Spices', 26.4, 25.0, .4, 4.0, _ConsumptionStatus.normal),
    _ConsumptionItem('Lemon', 'Fruits', 22.8, 21.0, .8, 8.6, _ConsumptionStatus.moderate),
  ];

  List<_ConsumptionItem> get _visibleItems {
    final results = _items.where((item) {
      final matchesSearch = item.name.toLowerCase().contains(_search.toLowerCase().trim());
      final matchesFilter = _filter == 'All' ||
          (_filter == 'High Variance' && item.status == _ConsumptionStatus.high) ||
          (_filter == 'Moderate' && item.status == _ConsumptionStatus.moderate) ||
          (_filter == 'Normal' && item.status == _ConsumptionStatus.normal) ||
          (_filter == 'Wastage' && item.wastage > 3) ||
          (_filter == 'High Usage' && item.actual > 100);
      return matchesSearch && matchesFilter;
    }).toList();
    results.sort((a, b) {
      if (_sort == 'Variance') return b.variance.abs().compareTo(a.variance.abs());
      if (_sort == 'Wastage') return b.wastage.compareTo(a.wastage);
      if (_sort == 'Name') return a.name.compareTo(b.name);
      return b.actual.compareTo(a.actual);
    });
    return results;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverToBoxAdapter(child: _buildSearchAndFilters()),
            SliverToBoxAdapter(child: _buildSummary()),
            SliverToBoxAdapter(child: _buildListHeader()),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = _visibleItems[index];
                  return Padding(
                    padding: EdgeInsets.fromLTRB(20, index == 0 ? 0 : 8, 20, index == _visibleItems.length - 1 ? 18 : 0),
                    child: _buildItemCard(context, item),
                  );
                },
                childCount: _visibleItems.length,
              ),
            ),
            if (_visibleItems.isEmpty)
              const SliverToBoxAdapter(child: _EmptyState()),
            const SliverToBoxAdapter(child: SizedBox(height: 86)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded, color: _consumptionInk),
                tooltip: 'Back to reports',
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(width: 4),
              const Expanded(
                child: Row(
                  children: [
                    Icon(Icons.restaurant_rounded, color: _consumptionBlue, size: 21),
                    SizedBox(width: 9),
                    Text('Consumption', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _consumptionInk)),
                  ],
                ),
              ),
              IconButton(
                onPressed: _exportReport,
                icon: const Icon(Icons.file_upload_outlined, color: _consumptionMuted),
                tooltip: 'Export',
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                onPressed: () => setState(() {}),
                icon: const Icon(Icons.refresh_rounded, color: _consumptionMuted),
                tooltip: 'Refresh',
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 30,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: ['Today', 'This Week', 'This Month', 'Custom'].map((range) {
                final active = _range == range;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(range),
                    selected: active,
                    onSelected: (_) => setState(() => _range = range),
                    avatar: range == 'Custom' ? const Icon(Icons.calendar_today_outlined, size: 13) : null,
                    labelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: active ? Colors.white : _consumptionMuted),
                    backgroundColor: Colors.white,
                    selectedColor: _consumptionBlue,
                    side: BorderSide(color: active ? _consumptionBlue : const Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    visualDensity: VisualDensity.compact,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 11, 20, 12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) => setState(() => _search = value),
                  decoration: InputDecoration(
                    hintText: 'Search items...',
                    hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                    prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFF94A3B8)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 9),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _consumptionBlue)),
                  ),
                ),
              ),
              const SizedBox(width: 9),
              OutlinedButton.icon(
                onPressed: () => setState(() => _filtersVisible = !_filtersVisible),
                icon: Icon(Icons.tune_rounded, size: 16, color: _filtersVisible ? Colors.white : _consumptionMuted),
                label: Text(_filter == 'All' ? 'Filter' : '1', style: TextStyle(fontSize: 12, color: _filtersVisible ? Colors.white : _consumptionMuted)),
                style: OutlinedButton.styleFrom(
                  backgroundColor: _filtersVisible ? _consumptionBlue : const Color(0xFFF8FAFC),
                  side: BorderSide(color: _filtersVisible ? _consumptionBlue : const Color(0xFFE2E8F0)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          if (_filtersVisible) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: ['All', 'High Variance', 'Moderate', 'Normal', 'Wastage', 'High Usage'].map((filter) {
                  final active = _filter == filter;
                  return FilterChip(
                    label: Text(filter),
                    selected: active,
                    onSelected: (_) => setState(() => _filter = filter),
                    labelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: active ? Colors.white : _consumptionMuted),
                    selectedColor: _consumptionBlue,
                    backgroundColor: const Color(0xFFF1F5F9),
                    checkmarkColor: Colors.white,
                    side: BorderSide.none,
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth < 360 ? 2 : 3;
          const cards = [
            ('Total Consumption', '1,847', 'kg', _consumptionBlue),
            ('Theoretical', '1,690', 'kg', _consumptionInk),
            ('Wastage', '87', 'kg', _consumptionAmber),
            ('Variance', '+157', 'kg · +9.3%', _consumptionRed),
            ('Consumption Cost', 'ETB 8,240', 'this period', _consumptionInk),
            ('Variance Cost', 'ETB 710', 'potential loss', _consumptionRed),
          ];
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cards.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 9,
              mainAxisSpacing: 9,
              mainAxisExtent: 86,
            ),
            itemBuilder: (_, index) {
              final card = cards[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: index == 0 ? _consumptionBlue : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: index == 0 ? _consumptionBlue : _consumptionBorder),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(.035), blurRadius: 8, offset: const Offset(0, 3))],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(card.$1.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: .4,
                          color: index == 0 ? Colors.white.withOpacity(.72) : const Color(0xFF94A3B8))),
                  const SizedBox(height: 4),
                  Text(card.$2, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800,
                      color: index == 0 ? Colors.white : card.$4)),
                  const SizedBox(height: 2),
                  Text(card.$3, style: TextStyle(fontSize: 9, color: index == 0 ? Colors.white.withOpacity(.72) : const Color(0xFF94A3B8))),
                ]),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildListHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 20, 11),
      child: Row(
        children: [
          const Text('Items', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _consumptionInk)),
          const SizedBox(width: 5),
          Text('(${_visibleItems.length})', style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
          const Spacer(),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _sort,
              isDense: true,
              icon: const Icon(Icons.expand_more_rounded, size: 16, color: _consumptionMuted),
              style: const TextStyle(fontSize: 11, color: _consumptionInk, fontWeight: FontWeight.w600),
              items: ['Consumption', 'Variance', 'Wastage', 'Name'].map((value) =>
                  DropdownMenuItem(value: value, child: Text('Sort: $value'))).toList(),
              onChanged: (value) => setState(() => _sort = value ?? _sort),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, _ConsumptionItem item) {
    final status = _statusDetails(item.status);
    final variance = item.variance >= 0 ? '+${item.variance.toStringAsFixed(1)}' : item.variance.toStringAsFixed(1);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showItemDetail(context, item),
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _consumptionBorder),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Flexible(child: Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _consumptionInk))),
                    const SizedBox(width: 7),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
                      child: Text(item.category, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: _consumptionMuted)),
                    ),
                  ]),
                  const SizedBox(height: 5),
                  Text('Actual: ${item.actual.toStringAsFixed(1)} kg   •   Theoretical: ${item.theoretical.toStringAsFixed(1)} kg',
                      style: const TextStyle(fontSize: 10, color: _consumptionMuted)),
                ]),
              ),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: status.$2, borderRadius: BorderRadius.circular(12)),
                  child: Text('${status.$1} $variance kg', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: status.$3)),
                ),
                const SizedBox(height: 3),
                Text('${item.variancePercent.toStringAsFixed(1)}% variance',
                    style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8))),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  (String, Color, Color) _statusDetails(_ConsumptionStatus status) {
    switch (status) {
      case _ConsumptionStatus.high:
        return ('⚠', const Color(0xFFFEE2E2), _consumptionRed);
      case _ConsumptionStatus.moderate:
        return ('●', const Color(0xFFFEF3C7), _consumptionAmber);
      case _ConsumptionStatus.normal:
        return ('✓', const Color(0xFFDCFCE7), _consumptionGreen);
    }
  }

  void _showItemDetail(BuildContext context, _ConsumptionItem item) {
    final status = _statusDetails(item.status);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        constraints: const BoxConstraints(maxHeight: 610),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 42, height: 4, decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(4)))),
              const SizedBox(height: 15),
              Row(children: [
                Expanded(child: Text(item.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _consumptionInk))),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded, color: _consumptionMuted)),
              ]),
              Text(item.category, style: const TextStyle(fontSize: 11, color: _consumptionMuted, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: status.$2, borderRadius: BorderRadius.circular(14)),
                child: Text('${status.$1} ${item.status.label}', style: TextStyle(color: status.$3, fontSize: 12, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 9,
                mainAxisSpacing: 9,
                childAspectRatio: 2.3,
                children: [
                  _detailTile('Opening Stock', '42.0 kg'),
                  _detailTile('Purchases', '88.0 kg'),
                  _detailTile('Total Available', '130.0 kg'),
                  _detailTile('Theoretical', '${item.theoretical.toStringAsFixed(1)} kg'),
                  _detailTile('Actual Consumption', '${item.actual.toStringAsFixed(1)} kg'),
                  _detailTile('Wastage', '${item.wastage.toStringAsFixed(1)} kg', color: _consumptionAmber),
                  _detailTile('Variance', '+${item.variance.toStringAsFixed(1)} kg', color: _consumptionRed),
                  _detailTile('Variance Cost', 'ETB ${(item.variance * 4.5).toStringAsFixed(0)}', color: _consumptionRed),
                ],
              ),
              const SizedBox(height: 18),
              const Text('Wastage Breakdown', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _consumptionInk)),
              const SizedBox(height: 7),
              _wastageRow('Spoilage', item.wastage * .4),
              _wastageRow('Preparation Waste', item.wastage * .3),
              _wastageRow('Spillage', item.wastage * .2),
              _wastageRow('Damaged', item.wastage * .1),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.book_outlined, size: 16), label: const Text('Recipes'))),
                const SizedBox(width: 8),
                Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.swap_horiz_rounded, size: 16), label: const Text('Transactions'))),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailTile(String label, String value, {Color color = _consumptionInk}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(label.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 8, color: Color(0xFF94A3B8), fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.w800)),
      ]),
    );
  }

  Widget _wastageRow(String reason, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Expanded(child: Text(reason, style: const TextStyle(fontSize: 12, color: _consumptionMuted))),
        Text('${amount.toStringAsFixed(1)} kg', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _consumptionInk)),
      ]),
    );
  }

  void _exportReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Consumption report export started'), duration: Duration(seconds: 1)),
    );
  }
}

enum _ConsumptionStatus {
  normal('Normal'),
  moderate('Moderate Variance'),
  high('High Variance');

  final String label;
  const _ConsumptionStatus(this.label);
}

class _ConsumptionItem {
  final String name;
  final String category;
  final double actual;
  final double theoretical;
  final double wastage;
  final double variance;
  final _ConsumptionStatus status;

  const _ConsumptionItem(this.name, this.category, this.actual, this.theoretical, this.wastage, this.variance, this.status);

  double get variancePercent => theoretical == 0 ? 0 : variance / theoretical * 100;
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(children: const [
        Icon(Icons.search_off_rounded, size: 42, color: Color(0xFFCBD5E1)),
        SizedBox(height: 10),
        Text('No items found', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _consumptionMuted)),
        SizedBox(height: 4),
        Text('Try another search or filter.', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
      ]),
    );
  }
}