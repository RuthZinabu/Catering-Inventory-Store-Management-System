import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/api_service.dart';
import '../inventory_screen.dart';
import '../purchases/purchase_list_screen.dart';
import '../stock_transfers/stock_transfer_list_screen.dart';
import '../waste/waste_list_screen.dart';
import 'consumption_report_screen.dart';
import '../expiry/expiry_list_screen.dart';

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
  bool _customRange = false;
  DateTime? _from;
  DateTime? _to;
  Map<String, dynamic> _report = {};
  String? _error;
  DateTime? _refreshedAt;
  bool _loading = true;
  int _requestNumber = 0;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    final requestNumber = ++_requestNumber;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await ApiClient.instance.restoreSession();
      final query = <String, String>{'period': _period.toLowerCase()};
      final storeId = ApiClient.instance.storeId;
      if (storeId != null) query['store_id'] = storeId;
      if (_customRange && _from != null && _to != null) {
        query['from'] = _dateString(_from!);
        query['to'] = _dateString(_to!);
      }

      final path =
          Uri(path: '/reports/overview', queryParameters: query).toString();
      final response = await ApiClient.instance.get(path);
      final report = Map<String, dynamic>.from(response['data'] as Map);
      if (!mounted || requestNumber != _requestNumber) return;
      setState(() {
        _report = report;
        _refreshedAt = DateTime.now();
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted || requestNumber != _requestNumber) return;
      setState(() {
        _error = error.message;
        _loading = false;
      });
    } catch (error) {
      if (!mounted || requestNumber != _requestNumber) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Map<String, dynamic> _mapValue(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

  Map<String, dynamic> _reportSection(String key) =>
      _mapValue(_mapValue(_report['reports'])[key]);

  String _formatNumber(dynamic value) {
    final number = value is num ? value : num.tryParse(value?.toString() ?? '');
    return number == null ? '—' : NumberFormat('#,##0.##').format(number);
  }

  String _formatMoney(dynamic value) {
    if (value is! num) return '—';
    return 'ETB ${NumberFormat('#,##0.00').format(value)}';
  }

  String _quantityValue(dynamic total, dynamic quantitiesByUnit, String key) {
    final unitQuantities = _mapValue(quantitiesByUnit);
    if (total is num) {
      final unit = unitQuantities.length == 1
          ? ' ${unitQuantities.keys.first}'
          : '';
      return '${_formatNumber(total)}$unit';
    }
    if (unitQuantities.isEmpty) return '—';
    return unitQuantities.entries
        .map((entry) {
          final values = entry.value is num
              ? entry.value
              : _mapValue(entry.value)[key];
          return '${_formatNumber(values)} ${entry.key}';
        })
        .join(' · ');
  }

  String _dateString(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  String _periodLabel() {
    final period = _mapValue(_report['period']);
    final from = DateTime.tryParse(period['from']?.toString() ?? '');
    final to = DateTime.tryParse(period['to']?.toString() ?? '');
    if (from == null || to == null) return 'Loading report period';
    final format = DateFormat('MMM d, yyyy');
    return from.year == to.year && from.month == to.month && from.day == to.day
        ? format.format(from)
        : '${format.format(from)} – ${format.format(to)}';
  }

  String _periodBadge() => _customRange ? 'Custom' : _period;

  bool get _hasReportActivity {
    if (_report.isEmpty) return false;
    final kpis = _mapValue(_report['kpis']);
    final purchases = _reportSection('purchases');
    final expiry = _reportSection('expiry');
    final consumption = _mapValue(_reportSection('consumption')['summary']);
    return [
      kpis['total_items'],
      kpis['stock_movements'],
      kpis['expiring_soon'],
      kpis['waste_record_count'],
      purchases['orders_placed'],
      expiry['tracked_batch_count'],
      consumption['production_run_count'],
    ].any((value) => value is num && value > 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            if (_loading)
              const SliverToBoxAdapter(
                child: LinearProgressIndicator(minHeight: 2),
              ),
            if (_error != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: Material(
                    color: const Color(0xFFFFF1F0),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Could not load live reports: $_error',
                              style: const TextStyle(color: _red, fontSize: 12),
                            ),
                          ),
                          TextButton(
                            onPressed: _loadReport,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            if (!_loading &&
                _error == null &&
                _report.isNotEmpty &&
                !_hasReportActivity)
              SliverToBoxAdapter(child: _buildEmptyState()),
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
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                                color: _ink,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.7)),
                    const SizedBox(height: 4),
                    Row(
                      children: const [
                        Icon(Icons.circle, size: 7, color: _green),
                        SizedBox(width: 6),
                        Text('Daily · Weekly · Monthly',
                            style: TextStyle(
                                color: _muted,
                                fontSize: 12,
                                fontWeight: FontWeight.w500)),
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
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(.035),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 15, color: _blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _customRange && _from != null && _to != null
                          ? '${DateFormat('MMM d, yyyy').format(_from!)} – ${DateFormat('MMM d, yyyy').format(_to!)}'
                          : _periodLabel(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ),
                  const Icon(Icons.expand_more_rounded,
                      size: 18, color: Color(0xFF94A3B8)),
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
        onTap: label == 'Refresh'
            ? _loadReport
            : () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Report export is not available yet.'),
                    duration: Duration(seconds: 2),
                  ),
                ),
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
    final kpis = _mapValue(_report['kpis']);
    final stock = _reportSection('current_stock');
    final data = <(String, String, String, IconData, Color)>[
      (
        'Total Items',
        _formatNumber(kpis['total_items']),
        '${_formatNumber(stock['in_stock_items'])} currently in stock',
        Icons.inventory_2_outlined,
        _blue,
      ),
      (
        'Inventory Value',
        _formatMoney(kpis['inventory_value']),
        'Current stock valuation',
        Icons.account_balance_wallet_outlined,
        const Color(0xFF0F766E),
      ),
      (
        'Stock Movements',
        _formatNumber(kpis['stock_movements']),
        'During selected period',
        Icons.swap_vert_rounded,
        const Color(0xFF7C3AED),
      ),
      (
        'Expiring Soon',
        _formatNumber(kpis['expiring_soon']),
        'Tracked batches · next 7 days',
        Icons.schedule_outlined,
        _amber,
      ),
      (
        'Waste This Period',
        _formatMoney(kpis['waste_value']),
        '${_formatNumber(kpis['waste_record_count'])} confirmed records',
        Icons.delete_outline_rounded,
        _red,
      ),
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
          final captionColor = item.$3.startsWith('+')
              ? _green
              : item.$3.startsWith('-')
                  ? _red
                  : _muted;
          return Container(
            width: 166,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _border),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(.035),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(item.$4, size: 15, color: item.$5),
                  const SizedBox(width: 6),
                  Expanded(
                      child: Text(item.$1,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _muted))),
                ]),
                const SizedBox(height: 6),
                Text(item.$2,
                    style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: _ink)),
                const SizedBox(height: 2),
                Text(item.$3,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: captionColor)),
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
            final active = _period == period && !_customRange;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _period = period;
                  _customRange = false;
                  _from = null;
                  _to = null;
                });
                _loadReport();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
                decoration: BoxDecoration(
                  color: active ? _blue : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: active
                      ? [
                          BoxShadow(
                              color: _blue.withOpacity(.25),
                              blurRadius: 10,
                              offset: const Offset(0, 4))
                        ]
                      : null,
                ),
                child: Text(period,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: active ? Colors.white : _muted)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildReportGrid(BuildContext context) {
    final stock = _reportSection('current_stock');
    final valuation = _reportSection('inventory_valuation');
    final movements = _reportSection('stock_movement');
    final purchases = _reportSection('purchases');
    final suppliers = _reportSection('suppliers');
    final expiry = _reportSection('expiry');
    final waste = _reportSection('waste');
    final consumption = _mapValue(_reportSection('consumption')['summary']);
    final valuationByType = _mapValue(valuation['by_item_type']);
    final valuationRows = valuationByType.entries
        .take(3)
        .map((entry) => (
              entry.key.replaceAll('_', ' '),
              _formatMoney(_mapValue(entry.value)['value']),
              _ink,
            ))
        .toList();
    if (valuationRows.isEmpty) {
      valuationRows.add(('Item types', 'No stock records', _muted));
    }
    final topSuppliers =
        suppliers['top_suppliers'] as List? ?? const <dynamic>[];
    final supplierRows = topSuppliers
        .take(3)
        .map((supplier) {
          final row = _mapValue(supplier);
          return (
            row['name']?.toString() ?? 'Supplier',
            _formatMoney(row['total_spend']),
            _ink,
          );
        })
        .toList();
    if (supplierRows.isEmpty) {
      supplierRows.add(('Suppliers', 'No purchase records', _muted));
    }
    final wasteReasons = _mapValue(waste['cost_by_reason']);
    final expiryBuckets = _mapValue(expiry['day_buckets']);
    final productionRecorded = consumption['production_data_available'] == true;
    final cards = [
      _ReportCardData(
          'Current Stock',
          'Current',
          Icons.assignment_outlined,
          [
            ('Total SKUs', _formatNumber(stock['total_skus']), _ink),
            ('In Stock', _formatNumber(stock['in_stock_items']), _ink),
            ('Low Stock', _formatNumber(stock['low_stock_items']), _amber),
            ('Out of Stock', _formatNumber(stock['out_of_stock_items']), _red),
            (
              'Stock Health',
              stock['stock_health_percent'] is num
                  ? '${_formatNumber(stock['stock_health_percent'])}%'
                  : '—',
              _green,
            ),
          ],
          'View inventory'),
      _ReportCardData(
          'Inventory Valuation',
          _formatMoney(valuation['total_value']),
          Icons.monetization_on_outlined,
          [
            ...valuationRows,
            (
              'Average / Item',
              _formatMoney(valuation['average_value_per_item']),
              _ink,
            ),
          ],
          'View inventory'),
      _ReportCardData(
          'Stock Movement',
          _periodBadge(),
          Icons.swap_horiz_rounded,
          [
            (
              'Inbound',
              _quantityValue(
                movements['inbound_quantity'],
                movements['quantity_by_unit'],
                'inbound_quantity',
              ),
              _green,
            ),
            (
              'Outbound',
              _quantityValue(
                movements['outbound_quantity'],
                movements['quantity_by_unit'],
                'outbound_quantity',
              ),
              _red,
            ),
            ('Transfers', _formatNumber(movements['transfer_count']), _ink),
            (
              'Net Change',
              _quantityValue(
                movements['net_quantity_change'],
                movements['quantity_by_unit'],
                'net_quantity_change',
              ),
              _ink,
            ),
          ],
          'View transfers'),
      _ReportCardData(
          'Purchase Report',
          _periodBadge(),
          Icons.shopping_cart_outlined,
          [
            ('Orders Placed', _formatNumber(purchases['orders_placed']), _ink),
            (
              'Items Ordered',
              _quantityValue(
                purchases['items_ordered'],
                purchases['items_ordered_by_unit'],
                'items_ordered',
              ),
              _ink,
            ),
            ('Total Spent', _formatMoney(purchases['total_spent']), _ink),
            (
              'Average Order',
              _formatMoney(purchases['average_order_value']),
              _ink,
            ),
          ],
          'View orders'),
      _ReportCardData(
          'Supplier Report',
          'Top suppliers',
          Icons.local_shipping_outlined,
          [
            ...supplierRows,
            (
              'On-time Delivery (${_formatNumber(suppliers['on_time_delivery_sample_size'])} orders)',
              suppliers['on_time_delivery_percent'] is num
                  ? '${_formatNumber(suppliers['on_time_delivery_percent'])}%'
                  : 'Not available',
              _green,
            ),
          ],
          'View orders'),
      _ReportCardData(
          'Expiry Report',
          '${_formatNumber(expiry['tracked_batch_count'])} lots tracked',
          Icons.hourglass_bottom_rounded,
          [
            ('Expired items', _formatNumber(expiry['expired_items']), _red),
            (
              'Expiring in 0–3 days',
              _formatNumber(expiryBuckets['0_to_3_days']),
              _red,
            ),
            (
              'Expiring in 4–7 days',
              _formatNumber(expiryBuckets['4_to_7_days']),
              _amber,
            ),
            (
              'Expiring in 8–30 days',
              _formatNumber(expiryBuckets['8_to_30_days']),
              _ink,
            ),
            (
              'At risk · next 30 days',
              _formatNumber(expiry['total_at_risk_items']),
              _red,
            ),
            (
              'Items without expiry lots',
              _formatNumber(expiry['untracked_stock_items_count']),
              _amber,
            ),
          ],
          'Manage lots'),
      _ReportCardData(
          'Waste Report',
          _periodBadge(),
          Icons.delete_outline_rounded,
          [
            ('Spoilage', _formatMoney(wasteReasons['spoilage']), _ink),
            ('Damaged', _formatMoney(wasteReasons['damaged']), _ink),
            ('Expired', _formatMoney(wasteReasons['expired']), _ink),
            ('Other', _formatMoney(wasteReasons['other']), _ink),
            (
              'Confirmed Records',
              _formatNumber(waste['record_count']),
              _ink,
            ),
          ],
          'View waste'),
      _ReportCardData(
          'Consumption Report',
          productionRecorded ? 'Production recorded' : 'No production records',
          Icons.restaurant_outlined,
          [
            (
              'Issued to Kitchen',
              _quantityValue(
                consumption['total_consumption_quantity'],
                consumption['actual_quantity_by_unit'],
                'actual_quantity',
              ),
              _blue,
            ),
            (
              'Produced Servings',
              _formatNumber(consumption['produced_servings']),
              _ink,
            ),
            (
              'Theoretical',
              _quantityValue(
                consumption['theoretical_quantity'],
                consumption['theoretical_quantity_by_unit'],
                'theoretical_quantity',
              ),
              _ink,
            ),
            (
              'Wastage',
              _quantityValue(
                consumption['wastage_quantity'],
                consumption['actual_quantity_by_unit'],
                'wastage_quantity',
              ),
              _amber,
            ),
            ('Variance Cost', _formatMoney(consumption['variance_cost']), _red),
          ],
          'View details',
          highlighted: true),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 980
              ? 3
              : constraints.maxWidth >= 620
                  ? 2
                  : 1;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cards.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              mainAxisExtent: 264,
            ),
            itemBuilder: (context, index) {
              final card = cards[index];
              return _ReportCard(
                data: card,
                onTap: () => _openReportDestination(context, card.title),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _openReportDestination(
      BuildContext context, String title) async {
    final Widget? destination = switch (title) {
      'Current Stock' => const InventoryScreen(),
      'Inventory Valuation' => const InventoryScreen(),
      'Stock Movement' => const StockTransferListScreen(),
      'Purchase Report' => const PurchaseListScreen(),
      'Supplier Report' => const PurchaseListScreen(),
      'Expiry Report' => const ExpiryListScreen(),
      'Waste Report' => const WasteListScreen(),
      'Consumption Report' => const ConsumptionReportScreen(),
      _ => null,
    };
    if (destination == null) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => destination),
    );
    if (mounted) await _loadReport();
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.assessment_outlined, color: _blue),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'No report activity was recorded for the selected scope and period. Current stock and expiry summaries are shown below.',
                style: TextStyle(
                  color: _muted,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightBanner(BuildContext context) {
    final expiry = _reportSection('expiry');
    final untrackedValue = expiry['untracked_stock_items_count'];
    final untrackedCount = untrackedValue is num
        ? untrackedValue.toInt()
        : int.tryParse(untrackedValue?.toString() ?? '');
    final insight = untrackedCount == null
        ? 'Expiry coverage will appear when the live report has loaded.'
        : untrackedCount > 0
            ? '$untrackedCount stocked items have quantities not assigned to tracked expiry lots. Record batches to include their expiry dates.'
            : 'Current stock quantities are covered by tracked expiry batches.';
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
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: 'Expiry coverage: ',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, color: _ink, fontSize: 12),
                  children: [
                    TextSpan(
                      text: insight,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _loadReport,
              icon: const Icon(Icons.refresh_rounded, color: _green, size: 20),
              tooltip: 'Refresh expiry coverage',
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    final refreshedAt = _refreshedAt;
    final status = refreshedAt == null
        ? (_error == null ? 'Loading live database report' : 'Live report unavailable')
        : 'Live database data · refreshed ${DateFormat('MMM d, yyyy HH:mm').format(refreshedAt)} · $_periodLabel()';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
      child: Center(
        child: Text(
          status,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
        ),
      ),
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final today = DateUtils.dateOnly(DateTime.now());
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: today.add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(
        start: _from ?? today,
        end: _to ?? today,
      ),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _customRange = true;
      _from = DateUtils.dateOnly(picked.start);
      _to = DateUtils.dateOnly(picked.end);
    });
    _loadReport();
  }
}

class _ReportCardData {
  final String title;
  final String badge;
  final IconData icon;
  final List<(String, String, Color)> rows;
  final String action;
  final bool highlighted;

  const _ReportCardData(
      this.title, this.badge, this.icon, this.rows, this.action,
      {this.highlighted = false});
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
            border: Border.all(
                color: data.highlighted ? _blue.withOpacity(.28) : _border),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(.035),
                  blurRadius: 12,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(data.icon, color: _blue, size: 19),
                const SizedBox(width: 9),
                Expanded(
                    child: Text(data.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: _ink))),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: data.highlighted
                          ? _blue.withOpacity(.1)
                          : const Color(0xFFF1F4F8),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(data.badge,
                      style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: _muted)),
                ),
              ]),
              const SizedBox(height: 10),
              Expanded(
                child: Column(
                  children: data.rows
                      .map((row) => Container(
                            padding: const EdgeInsets.symmetric(vertical: 7),
                            decoration: const BoxDecoration(
                                border: Border(
                                    bottom:
                                        BorderSide(color: Color(0xFFF1F4F8)))),
                            child: Row(children: [
                              Expanded(
                                  child: Text(row.$1,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: _muted,
                                          fontWeight: FontWeight.w500))),
                              Text(row.$2,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: row.$3,
                                      fontWeight: FontWeight.w800)),
                            ]),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 7),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(data.action,
                      style: const TextStyle(
                          fontSize: 11,
                          color: _blue,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right_rounded,
                      color: _blue, size: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
