import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import 'production_run_screen.dart';

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
  final _summary = <String, dynamic>{};
  final List<_ConsumptionItem> _items = [];
  DateTime? _from;
  DateTime? _to;
  Timer? _searchTimer;
  bool _loading = true;
  String? _error;

  List<_ConsumptionItem> get _visibleItems => _items;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadReport() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final query = <String, String>{
        'page': '1',
        'per_page': '100',
        'filter': _backendFilter(_filter),
        'sort': _sort.toLowerCase(),
      };
      if (ApiClient.instance.storeId != null) {
        query['store_id'] = ApiClient.instance.storeId!;
      }
      if (_search.trim().isNotEmpty) query['search'] = _search.trim();
      if (_range == 'Custom' && _from != null && _to != null) {
        query['from'] = _dateString(_from!);
        query['to'] = _dateString(_to!);
      } else {
        query['period'] = switch (_range) {
          'Today' => 'daily',
          'This Month' => 'monthly',
          _ => 'weekly',
        };
      }
      final path = Uri(path: '/reports/consumption', queryParameters: query).toString();
      final response = await ApiClient.instance.get(path);
      final data = Map<String, dynamic>.from(response['data'] as Map);
      final summary = Map<String, dynamic>.from(data['summary'] as Map? ?? const {});
      final items = (data['items'] as List? ?? const [])
          .map((item) => _ConsumptionItem.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
      if (!mounted) return;
      setState(() {
        _summary
          ..clear()
          ..addAll(summary);
        _items
          ..clear()
          ..addAll(items);
        _loading = false;
      });
    } on ApiException catch (error) {
      if (mounted) setState(() {
        _error = error.message;
        _loading = false;
      });
    } catch (error) {
      if (mounted) setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  void _scheduleSearch() {
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 350), _loadReport);
  }

  Future<void> _openProductionForm() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const ProductionRunScreen()),
    );
    if (saved == true) _loadReport();
  }

  String _backendFilter(String value) => switch (value) {
        'High Variance' => 'high_variance',
        'Moderate' => 'moderate',
        'Normal' => 'normal',
        'Wastage' => 'wastage',
        'High Usage' => 'high_usage',
        _ => 'all',
      };

  Future<void> _pickCustomRange() async {
    final today = DateTime.now();
    final end = _to ?? today;
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: today.add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(
        start: _from ?? end.subtract(const Duration(days: 6)),
        end: end,
      ),
    );
    if (range == null) return;
    setState(() {
      _range = 'Custom';
      _from = range.start;
      _to = range.end;
    });
    _loadReport();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            if (_loading)
              const SliverToBoxAdapter(
                child: LinearProgressIndicator(minHeight: 2),
              ),
            if (_error != null && _items.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _loadReport,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            SliverToBoxAdapter(child: _buildSearchAndFilters()),
            SliverToBoxAdapter(child: _buildSummary()),
            SliverToBoxAdapter(child: _buildListHeader()),
            if (!_loading && _error == null && _visibleItems.isNotEmpty)
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
            if (!_loading && _error == null && _visibleItems.isEmpty)
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
                onPressed: _openProductionForm,
                icon: const Icon(Icons.add_chart_rounded, color: _consumptionBlue),
                tooltip: 'Record kitchen production',
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                onPressed: _exportReport,
                icon: const Icon(Icons.file_upload_outlined, color: _consumptionMuted),
                tooltip: 'Export',
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                onPressed: _loadReport,
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
                    onSelected: (_) {
                      if (range == 'Custom') {
                        _pickCustomRange();
                      } else {
                        setState(() {
                          _range = range;
                          _from = null;
                          _to = null;
                        });
                        _loadReport();
                      }
                    },
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
                  onChanged: (value) {
                    setState(() => _search = value);
                    _scheduleSearch();
                  },
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
                    onSelected: (_) {
                      setState(() => _filter = filter);
                      _loadReport();
                    },
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
          final units = Map<String, dynamic>.from(
            _summary['actual_quantity_by_unit'] as Map? ?? const {},
          );
          final unitCaption = units.isEmpty
              ? 'No issue data'
              : units.length == 1
                  ? units.keys.first
                  : 'Separate units';
          String quantity(String key, {bool theory = false}) {
            final value = _summary[key];
            if (value == null) {
              return theory && _summary['theoretical_data_available'] != true
                  ? 'Not tracked'
                  : '—';
            }
            final formatted = _formatNumber(value);
            if (key == 'variance_quantity' && (value as num) > 0) {
              return '+$formatted';
            }
            return units.length == 1 ? '$formatted ${units.keys.first}' : formatted;
          }

          final theoretical = _summary['theoretical_quantity'];
          final variancePercent = theoretical is num && theoretical > 0 &&
                  _summary['variance_quantity'] is num
              ? '${(_summary['variance_quantity'] as num) * 100 ~/ theoretical}% vs recipe'
              : (_summary['theoretical_data_available'] == true
                  ? 'Incomplete comparison'
                  : 'Record production for comparison');
          final productionRuns = _summary['production_run_count'];
          final producedServings = _summary['produced_servings'];
          final summaryCards = [
            ('Issued to Kitchen', quantity('total_consumption_quantity'), unitCaption, _consumptionBlue),
            ('Theoretical', quantity('theoretical_quantity', theory: true), 'Recipe-based requirement', _consumptionInk),
            (
              'Produced Servings',
              producedServings is num
                  ? '${_formatNumber(producedServings)} servings'
                  : '—',
              productionRuns is num
                  ? '${_formatNumber(productionRuns)} recorded runs'
                  : 'Production not loaded',
              _consumptionBlue,
            ),
            ('Confirmed Wastage', quantity('wastage_quantity'), unitCaption, _consumptionAmber),
            ('Variance', quantity('variance_quantity'), variancePercent, _consumptionRed),
            ('Issue Cost', _formatMoney(_summary['consumption_cost']), 'this period', _consumptionInk),
            ('Variance Cost', _formatMoney(_summary['variance_cost']), 'potential excess cost', _consumptionRed),
          ];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: summaryCards.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 9,
                  mainAxisSpacing: 9,
                  mainAxisExtent: 86,
                ),
                itemBuilder: (_, index) {
                  final card = summaryCards[index];
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
                      Text(card.$2, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800,
                              color: index == 0 ? Colors.white : card.$4)),
                      const SizedBox(height: 2),
                      Text(card.$3, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 9, color: index == 0 ? Colors.white.withOpacity(.72) : const Color(0xFF94A3B8))),
                    ]),
                  );
                },
              ),
              if (_summary['actual_quantity_basis'] != null) ...[
                const SizedBox(height: 8),
                Text(
                  _summary['actual_quantity_basis'] as String,
                  style: const TextStyle(fontSize: 10, color: _consumptionMuted),
                ),
              ],
            ],
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
              onChanged: (value) {
                setState(() => _sort = value ?? _sort);
                _loadReport();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, _ConsumptionItem item) {
    final status = _statusDetails(item.status);
    final variance = item.variance == null
        ? 'No recipe data'
        : '${item.variance! >= 0 ? '+' : ''}${item.variance!.toStringAsFixed(1)} ${item.unit}';
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
                   Text(
                       'Issued: ${item.actual.toStringAsFixed(1)} ${item.unit}   •   Recipe: ${item.theoretical?.toStringAsFixed(1) ?? '—'} ${item.unit}',
                      style: const TextStyle(fontSize: 10, color: _consumptionMuted)),
                ]),
              ),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: status.$2, borderRadius: BorderRadius.circular(12)),
                   child: Text('${status.$1} $variance', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: status.$3)),
                ),
                const SizedBox(height: 3),
                 Text(item.variancePercent == null
                         ? 'No comparison'
                         : '${item.variancePercent!.toStringAsFixed(1)}% variance',
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
      case _ConsumptionStatus.unavailable:
        return ('—', const Color(0xFFF1F5F9), _consumptionMuted);
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
                   _detailTile('Requested', '${item.planned.toStringAsFixed(1)} ${item.unit}'),
                   _detailTile('Recipe Requirement', '${item.theoretical?.toStringAsFixed(1) ?? '—'} ${item.unit}'),
                   _detailTile('Issued to Kitchen', '${item.actual.toStringAsFixed(1)} ${item.unit}'),
                   _detailTile('Confirmed Waste', '${item.wastage.toStringAsFixed(1)} ${item.unit}', color: _consumptionAmber),
                   _detailTile('Variance', '${item.variance?.toStringAsFixed(1) ?? '—'} ${item.unit}', color: _consumptionRed),
                   _detailTile('Issue Cost', _formatMoney(item.consumptionCost)),
                   _detailTile('Variance Cost', _formatMoney(item.varianceCost), color: _consumptionRed),
                   _detailTile('Unit Cost', _formatMoney(item.unitCost)),
                ],
              ),
              const SizedBox(height: 18),
               const Text('Confirmed Waste', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _consumptionInk)),
              const SizedBox(height: 7),
               _wastageRow('Recorded quantity', item.wastage, item.unit),
              const SizedBox(height: 14),
               const Text(
                 'Issued quantities are a kitchen-usage proxy. The app does not record the quantity actually consumed during preparation.',
                 style: TextStyle(fontSize: 11, color: _consumptionMuted),
               ),
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

  Widget _wastageRow(String reason, double amount, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Expanded(child: Text(reason, style: const TextStyle(fontSize: 12, color: _consumptionMuted))),
        Text('${amount.toStringAsFixed(1)} $unit', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _consumptionInk)),
      ]),
    );
  }

  String _formatMoney(dynamic value) =>
      value is num ? 'ETB ${value.toStringAsFixed(2)}' : 'Not available';

  void _exportReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Consumption report export started'), duration: Duration(seconds: 1)),
    );
  }
}

enum _ConsumptionStatus {
  normal('Normal'),
  moderate('Moderate Variance'),
  high('High Variance'),
  unavailable('Not tracked');

  final String label;
  const _ConsumptionStatus(this.label);
}

class _ConsumptionItem {
  final String id;
  final String name;
  final String category;
  final String unit;
  final double actual;
  final double planned;
  final double? theoretical;
  final double wastage;
  final double? variance;
  final double? variancePercent;
  final double? unitCost;
  final double? consumptionCost;
  final double? varianceCost;
  final _ConsumptionStatus status;

  const _ConsumptionItem({
    required this.id,
    required this.name,
    required this.category,
    required this.unit,
    required this.actual,
    required this.planned,
    required this.theoretical,
    required this.wastage,
    required this.variance,
    required this.variancePercent,
    required this.unitCost,
    required this.consumptionCost,
    required this.varianceCost,
    required this.status,
  });

  factory _ConsumptionItem.fromJson(Map<String, dynamic> json) {
    final status = switch (json['status']) {
      'high' => _ConsumptionStatus.high,
      'moderate' => _ConsumptionStatus.moderate,
      'normal' => _ConsumptionStatus.normal,
      _ => _ConsumptionStatus.unavailable,
    };
    return _ConsumptionItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown item',
      category: json['category']?.toString() ?? 'Uncategorized',
      unit: json['unit']?.toString() ?? '',
      actual: _asDouble(json['actual_quantity']),
      planned: _asDouble(json['planned_quantity']),
      theoretical: _asNullableDouble(json['theoretical_quantity']),
      wastage: _asDouble(json['wastage_quantity']),
      variance: _asNullableDouble(json['variance_quantity']),
      variancePercent: _asNullableDouble(json['variance_percent']),
      unitCost: _asNullableDouble(json['unit_cost']),
      consumptionCost: _asNullableDouble(json['consumption_cost']),
      varianceCost: _asNullableDouble(json['variance_cost']),
      status: status,
    );
  }
}

double _asDouble(dynamic value) =>
    value is num ? value.toDouble() : double.tryParse(value?.toString() ?? '') ?? 0;

double? _asNullableDouble(dynamic value) => value == null
    ? null
    : value is num
        ? value.toDouble()
        : double.tryParse(value.toString());

String _formatNumber(dynamic value) {
  final number = value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
  return number.toStringAsFixed(1);
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