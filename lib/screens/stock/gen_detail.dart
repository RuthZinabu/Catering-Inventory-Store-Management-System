// ignore_for_file: unused_local_variable
import 'dart:convert';
import 'dart:io';

void main() {
  final path = r'lib\screens\stock\stock_detail_screen.dart';
  final sb = StringBuffer();

  sb.writeln("import 'package:flutter/material.dart';");
  sb.writeln("import '../../models/stock_models.dart';");
  sb.writeln("import '../../services/mock_repository.dart';");
  sb.writeln("import 'stock_history_screen.dart';");
  sb.writeln("import 'stock_form_screen.dart';");
  sb.writeln();
  sb.writeln("class StockDetailScreen extends StatelessWidget {");
  sb.writeln("  final StockItem item;");
  sb.writeln("  const StockDetailScreen({super.key, required this.item});");
  sb.writeln();
  sb.writeln("  Color _accentFor(StockItem item) {");
  sb.writeln("    if (item is FoodStockItem) {");
  sb.writeln("      switch (item.category) {");
  sb.writeln("        case 'Meat': return const Color(0xFFEF4444);");
  sb.writeln("        case 'Dairy': return const Color(0xFF3B82F6);");
  sb.writeln("        case 'Oil': return const Color(0xFF0F766E);");
  sb.writeln("        case 'Vegetables': return const Color(0xFF10B981);");
  sb.writeln("        default: return const Color(0xFF2563EB);");
  sb.writeln("      }");
  sb.writeln("    }");
  sb.writeln("    if (item is CateringStockItem) {");
  sb.writeln("      return item.subtype == CateringSubtype.permanent");
  sb.writeln("          ? const Color(0xFF7C3AED) : const Color(0xFFF59E0B);");
  sb.writeln("    }");
  sb.writeln("    return const Color(0xFF0369A1);");
  sb.writeln("  }");
  sb.writeln();
  sb.writeln("  Color _statusColor(String status) {");
  sb.writeln("    switch (status) {");
  sb.writeln("      case 'Healthy': return const Color(0xFF16A34A);");
  sb.writeln("      case 'Low Stock': return const Color(0xFFF59E0B);");
  sb.writeln("      case 'Out of Stock': return const Color(0xFFEF4444);");
  sb.writeln("      default: return const Color(0xFF64748B);");
  sb.writeln("    }");
  sb.writeln("  }");
  sb.writeln();
  sb.writeln("  String _formatDate(DateTime d) {");
  sb.writeln(
      "    const months = ['','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];");
  sb.writeln("    return '\${d.day} \${months[d.month]} \${d.year}';");
  sb.writeln("  }");
  sb.writeln();
  sb.writeln("  Widget _card(Widget child) => Container(");
  sb.writeln("        width: double.infinity,");
  sb.writeln("        padding: const EdgeInsets.all(18),");
  sb.writeln("        margin: const EdgeInsets.only(bottom: 16),");
  sb.writeln("        decoration: BoxDecoration(");
  sb.writeln("          color: Colors.white,");
  sb.writeln("          borderRadius: BorderRadius.circular(22),");
  sb.writeln(
      "          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 18, offset: const Offset(0, 10))],");
  sb.writeln("        ),");
  sb.writeln("        child: child,");
  sb.writeln("      );");
  sb.writeln();
  sb.writeln(
      "  Widget _sectionTitle(BuildContext context, String title) => Padding(");
  sb.writeln("        padding: const EdgeInsets.only(bottom: 10),");
  sb.writeln(
      "        child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: const Color(0xFF10162B))),");
  sb.writeln("      );");
  sb.writeln();
  sb.writeln("  Widget _detailRow(String label, String value) => Padding(");
  sb.writeln("        padding: const EdgeInsets.only(bottom: 8),");
  sb.writeln("        child: Row(children: [");
  sb.writeln(
      "          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF475569), fontSize: 13))),");
  sb.writeln(
      "          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF10162B))),");
  sb.writeln("        ]),");
  sb.writeln("      );");
  sb.writeln();
  sb.writeln(
      "  Widget _chip(String label, {Color? bg, Color? fg}) => Container(");
  sb.writeln(
      "        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),");
  sb.writeln(
      "        decoration: BoxDecoration(color: bg ?? const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(999)),");
  sb.writeln(
      "        child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg ?? const Color(0xFF334155))),");
  sb.writeln("      );");

  // build method
  sb.writeln();
  sb.writeln("  @override");
  sb.writeln("  Widget build(BuildContext context) {");
  sb.writeln("    final accent = _accentFor(item);");
  sb.writeln("    final statusColor = _statusColor(item.status);");
  sb.writeln("    final stockFraction = item.stockFraction;");
  sb.writeln("    final recentMovements = MockRepository.stockMovements");
  sb.writeln("        .where((m) => m.stockItemId == item.id)");
  sb.writeln("        .toList()");
  sb.writeln("        .reversed");
  sb.writeln("        .take(3)");
  sb.writeln("        .toList();");
  sb.writeln();
  sb.writeln("    return Scaffold(");
  sb.writeln("      backgroundColor: const Color(0xFFF4F6FB),");
  sb.writeln("      body: CustomScrollView(");
  sb.writeln("        slivers: [");
  // Gradient header
  sb.writeln("          SliverToBoxAdapter(");
  sb.writeln("            child: Container(");
  sb.writeln("              decoration: BoxDecoration(");
  sb.writeln("                gradient: LinearGradient(");
  sb.writeln("                  colors: [accent, accent.withOpacity(0.75)],");
  sb.writeln("                  begin: Alignment.topLeft,");
  sb.writeln("                  end: Alignment.bottomRight,");
  sb.writeln("                ),");
  sb.writeln("              ),");
  sb.writeln("              child: SafeArea(");
  sb.writeln("                bottom: false,");
  sb.writeln("                child: Padding(");
  sb.writeln(
      "                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),");
  sb.writeln("                  child: Column(");
  sb.writeln(
      "                    crossAxisAlignment: CrossAxisAlignment.start,");
  sb.writeln("                    children: [");
  sb.writeln("                      Row(children: [");
  sb.writeln("                        GestureDetector(");
  sb.writeln(
      "                          onTap: () => Navigator.of(context).pop(),");
  sb.writeln("                          child: Container(");
  sb.writeln("                            padding: const EdgeInsets.all(10),");
  sb.writeln("                            decoration: BoxDecoration(");
  sb.writeln(
      "                              color: Colors.white.withOpacity(0.2),");
  sb.writeln(
      "                              borderRadius: BorderRadius.circular(14),");
  sb.writeln("                            ),");
  sb.writeln(
      "                            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white),");
  sb.writeln("                          ),");
  sb.writeln("                        ),");
  sb.writeln("                        const Spacer(),");
  sb.writeln("                        Container(");
  sb.writeln(
      "                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),");
  sb.writeln("                          decoration: BoxDecoration(");
  sb.writeln(
      "                            color: Colors.white.withOpacity(0.2),");
  sb.writeln(
      "                            borderRadius: BorderRadius.circular(999),");
  sb.writeln("                          ),");
  sb.writeln(
      "                          child: Text(item.code, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),");
  sb.writeln("                        ),");
  sb.writeln("                      ]),");
  sb.writeln("                      const SizedBox(height: 20),");
  sb.writeln(
      "                      Text(item.name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5)),");
  sb.writeln("                      const SizedBox(height: 6),");
  sb.writeln("                      Row(children: [");
  sb.writeln(
      "                        _chip(item.category, bg: Colors.white.withOpacity(0.2), fg: Colors.white),");
  sb.writeln("                        const SizedBox(width: 8),");
  sb.writeln("                        Container(");
  sb.writeln(
      "                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),");
  sb.writeln(
      "                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(999)),");
  sb.writeln(
      "                          child: Text(item.status, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),");
  sb.writeln("                        ),");
  sb.writeln("                      ]),");
  sb.writeln("                    ],");
  sb.writeln("                  ),");
  sb.writeln("                ),");
  sb.writeln("              ),");
  sb.writeln("            ),");
  sb.writeln("          ),");

  // Body content
  sb.writeln("          SliverToBoxAdapter(");
  sb.writeln("            child: Transform.translate(");
  sb.writeln("              offset: const Offset(0, -20),");
  sb.writeln("              child: Padding(");
  sb.writeln(
      "                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),");
  sb.writeln("                child: Column(");
  sb.writeln("                  crossAxisAlignment: CrossAxisAlignment.start,");
  sb.writeln("                  children: [");

  // Stock level card
  sb.writeln("                    _card(Column(");
  sb.writeln(
      "                      crossAxisAlignment: CrossAxisAlignment.start,");
  sb.writeln("                      children: [");
  sb.writeln("                        _sectionTitle(context, 'Stock Level'),");
  sb.writeln("                        Row(children: [");
  sb.writeln("                          Expanded(child: ClipRRect(");
  sb.writeln(
      "                            borderRadius: BorderRadius.circular(999),");
  sb.writeln("                            child: LinearProgressIndicator(");
  sb.writeln("                              value: stockFraction,");
  sb.writeln("                              minHeight: 8,");
  sb.writeln(
      "                              backgroundColor: const Color(0xFFF1F5F9),");
  sb.writeln("                              color: accent,");
  sb.writeln("                            ),");
  sb.writeln("                          )),");
  sb.writeln("                          const SizedBox(width: 10),");
  sb.writeln(
      "                          Text('\${(stockFraction * 100).toStringAsFixed(0)}%', style: TextStyle(color: accent, fontWeight: FontWeight.w800, fontSize: 13)),");
  sb.writeln("                        ]),");
  sb.writeln("                        const SizedBox(height: 14),");
  sb.writeln(
      "                        _detailRow('Quantity', '\${item.quantity.toStringAsFixed(0)} \${item.unit}'),");
  sb.writeln(
      "                        _detailRow('Min Quantity', '\${item.minQuantity.toStringAsFixed(0)} \${item.unit}'),");
  sb.writeln(
      "                        _detailRow('Max Quantity', '\${item.maxQuantity.toStringAsFixed(0)} \${item.unit}'),");
  sb.writeln("                        _detailRow('Location', item.location),");
  sb.writeln("                      ],");
  sb.writeln("                    )),");

  // Pricing card
  sb.writeln("                    _card(Column(");
  sb.writeln(
      "                      crossAxisAlignment: CrossAxisAlignment.start,");
  sb.writeln("                      children: [");
  sb.writeln("                        _sectionTitle(context, 'Pricing'),");
  sb.writeln(
      "                        _detailRow('Purchase Price', 'ETB \${item.purchasePrice.toStringAsFixed(2)}'),");
  sb.writeln(
      "                        _detailRow('Total Value', 'ETB \${item.totalValue.toStringAsFixed(2)}'),");
  sb.writeln("                        _detailRow('Supplier', item.supplier),");
  sb.writeln("                      ],");
  sb.writeln("                    )),");

  // Category-specific card
  sb.writeln("                    _buildCategoryCard(context, accent),");

  // Movement history card
  sb.writeln("                    _card(Column(");
  sb.writeln(
      "                      crossAxisAlignment: CrossAxisAlignment.start,");
  sb.writeln("                      children: [");
  sb.writeln(
      "                        _sectionTitle(context, 'Recent Movements'),");
  sb.writeln("                        if (recentMovements.isEmpty)");
  sb.writeln("                          const Padding(");
  sb.writeln(
      "                            padding: EdgeInsets.symmetric(vertical: 12),");
  sb.writeln(
      "                            child: Text('No movement records yet.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),");
  sb.writeln("                          )");
  sb.writeln("                        else");
  sb.writeln("                          ...recentMovements.map((m) {");
  sb.writeln(
      "                            final typeColor = _movementColor(m.type);");
  sb.writeln("                            return Padding(");
  sb.writeln(
      "                              padding: const EdgeInsets.only(bottom: 10),");
  sb.writeln("                              child: Row(children: [");
  sb.writeln("                                Container(");
  sb.writeln("                                  width: 36, height: 36,");
  sb.writeln(
      "                                  decoration: BoxDecoration(color: typeColor.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),");
  sb.writeln(
      "                                  child: Icon(Icons.swap_vert_rounded, color: typeColor, size: 18),");
  sb.writeln("                                ),");
  sb.writeln("                                const SizedBox(width: 10),");
  sb.writeln(
      "                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [");
  sb.writeln(
      "                                  Text(m.type, style: TextStyle(color: typeColor, fontSize: 12, fontWeight: FontWeight.w700)),");
  sb.writeln(
      "                                  Text('\${m.quantity.toStringAsFixed(0)} \${m.unit} · \${m.performedBy}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),");
  sb.writeln("                                ])),");
  sb.writeln(
      "                                Text(_formatDate(m.date), style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),");
  sb.writeln("                              ]),");
  sb.writeln("                            );");
  sb.writeln("                          }),");
  sb.writeln("                      ],");
  sb.writeln("                    )),");

  // Action buttons
  sb.writeln("                    const SizedBox(height: 8),");
  sb.writeln("                    Row(children: [");
  sb.writeln(
      "                      Expanded(child: _actionBtn(context, 'Edit', Icons.edit_outlined, const Color(0xFF2563EB), () {");
  sb.writeln(
      "                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => StockFormScreen(item: item)));");
  sb.writeln("                      })),");
  sb.writeln("                      const SizedBox(width: 10),");
  sb.writeln(
      "                      Expanded(child: _actionBtn(context, 'Stock In', Icons.arrow_downward_rounded, const Color(0xFF16A34A), () {})),");
  sb.writeln("                    ]),");
  sb.writeln("                    const SizedBox(height: 10),");
  sb.writeln("                    Row(children: [");
  sb.writeln(
      "                      Expanded(child: _actionBtn(context, 'Stock Out', Icons.arrow_upward_rounded, const Color(0xFFEF4444), () {})),");
  sb.writeln("                      const SizedBox(width: 10),");
  sb.writeln(
      "                      Expanded(child: _actionBtn(context, 'History', Icons.history_rounded, const Color(0xFF475569), () {");
  sb.writeln(
      "                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => StockHistoryScreen(item: item)));");
  sb.writeln("                      })),");
  sb.writeln("                    ]),");
  sb.writeln("                    const SizedBox(height: 112),");
  sb.writeln("                  ],");
  sb.writeln("                ),");
  sb.writeln("              ),");
  sb.writeln("            ),");
  sb.writeln("          ),");
  sb.writeln("        ],");
  sb.writeln("      ),");
  sb.writeln("    );");
  sb.writeln("  }");

  // _buildCategoryCard helper
  sb.writeln();
  sb.writeln(
      "  Widget _buildCategoryCard(BuildContext context, Color accent) {");
  sb.writeln("    if (item is FoodStockItem) {");
  sb.writeln("      final f = item as FoodStockItem;");
  sb.writeln(
      "      return _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [");
  sb.writeln("        _sectionTitle(context, 'Food Details'),");
  sb.writeln("        _detailRow('Batch Number', f.batchNumber),");
  sb.writeln(
      "        _detailRow('Expiry Date', f.expiryDate != null ? _formatDate(f.expiryDate!) : 'N/A'),");
  sb.writeln("        _detailRow('Expiry Status', f.expiryStatus),");
  sb.writeln("        const SizedBox(height: 6),");
  sb.writeln("        if (f.requiresRefrigeration)");
  sb.writeln(
      "          _chip('Requires Refrigeration', bg: const Color(0xFF3B82F6).withOpacity(0.1), fg: const Color(0xFF3B82F6)),");
  sb.writeln("      ]));");
  sb.writeln("    }");
  sb.writeln("    if (item is CateringStockItem) {");
  sb.writeln("      final c = item as CateringStockItem;");
  sb.writeln(
      "      final isPermanent = c.subtype == CateringSubtype.permanent;");
  sb.writeln(
      "      final subtypeColor = isPermanent ? const Color(0xFF7C3AED) : const Color(0xFFF59E0B);");
  sb.writeln(
      "      return _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [");
  sb.writeln("        _sectionTitle(context, 'Catering Details'),");
  sb.writeln("        Row(children: [");
  sb.writeln(
      "          _chip(isPermanent ? 'Permanent' : 'Temporary', bg: subtypeColor.withOpacity(0.1), fg: subtypeColor),");
  sb.writeln("        ]),");
  sb.writeln("        const SizedBox(height: 10),");
  sb.writeln("        if (isPermanent) ...[ ");
  sb.writeln("          _detailRow('Condition', c.condition ?? 'N/A'),");
  sb.writeln(
      "          if (c.isReserved == true) _detailRow('Reserved For', c.reservedFor ?? ''),");
  sb.writeln("          if (c.isReserved == true)");
  sb.writeln(
      "            _chip('Reserved', bg: const Color(0xFFEF4444).withOpacity(0.1), fg: const Color(0xFFEF4444)),");
  sb.writeln("        ] else ...[");
  sb.writeln(
      "          _detailRow('Pack Size', '\${c.packSize ?? 'N/A'} pcs/pack'),");
  sb.writeln(
      "          _detailRow('Consumption Rate', c.consumptionRate ?? 'N/A'),");
  sb.writeln("        ],");
  sb.writeln("      ]));");
  sb.writeln("    }");
  sb.writeln("    if (item is ElectronicsStockItem) {");
  sb.writeln("      final e = item as ElectronicsStockItem;");
  sb.writeln("      final mainColor = e.maintenanceStatus == 'OK'");
  sb.writeln("          ? const Color(0xFF16A34A)");
  sb.writeln("          : e.maintenanceStatus == 'Due'");
  sb.writeln("              ? const Color(0xFFF59E0B)");
  sb.writeln("              : const Color(0xFFEF4444);");
  sb.writeln(
      "      return _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [");
  sb.writeln("        _sectionTitle(context, 'Electronics Details'),");
  sb.writeln("        _detailRow('Brand', e.brand),");
  sb.writeln("        _detailRow('Model', e.model),");
  sb.writeln("        _detailRow('Serial Number', e.serialNumber),");
  sb.writeln("        _detailRow('Asset Tag', e.assetTag),");
  sb.writeln("        _detailRow('Warranty Status', e.warrantyStatus),");
  sb.writeln(
      "        if (e.warrantyExpiry != null) _detailRow('Warranty Expiry', _formatDate(e.warrantyExpiry!)),");
  sb.writeln("        const SizedBox(height: 8),");
  sb.writeln("        Row(children: [");
  sb.writeln(
      "          _chip('Maintenance: \${e.maintenanceStatus}', bg: mainColor.withOpacity(0.1), fg: mainColor),");
  sb.writeln("          if (e.lastMaintenanceDate != null) ...[");
  sb.writeln("            const SizedBox(width: 8),");
  sb.writeln(
      "            _chip('Last: \${_formatDate(e.lastMaintenanceDate!)}', bg: const Color(0xFFF8FAFC), fg: const Color(0xFF64748B)),");
  sb.writeln("          ],");
  sb.writeln("        ]),");
  sb.writeln("      ]));");
  sb.writeln("    }");
  sb.writeln("    return const SizedBox.shrink();");
  sb.writeln("  }");

  sb.writeln();
  sb.writeln("  Color _movementColor(String type) {");
  sb.writeln("    switch (type) {");
  sb.writeln("      case 'Stock In': return const Color(0xFF16A34A);");
  sb.writeln("      case 'Stock Out': return const Color(0xFFEF4444);");
  sb.writeln("      case 'Transfer': return const Color(0xFF4F46E5);");
  sb.writeln("      case 'Return': return const Color(0xFF0F766E);");
  sb.writeln("      case 'Adjustment': return const Color(0xFFF59E0B);");
  sb.writeln("      default: return const Color(0xFF64748B);");
  sb.writeln("    }");
  sb.writeln("  }");

  sb.writeln();
  sb.writeln(
      "  Widget _actionBtn(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {");
  sb.writeln("    return GestureDetector(");
  sb.writeln("      onTap: onTap,");
  sb.writeln("      child: Container(");
  sb.writeln("        padding: const EdgeInsets.symmetric(vertical: 14),");
  sb.writeln("        decoration: BoxDecoration(");
  sb.writeln("          color: color.withOpacity(0.08),");
  sb.writeln("          borderRadius: BorderRadius.circular(16),");
  sb.writeln(
      "          border: Border.all(color: color.withOpacity(0.2), width: 1),");
  sb.writeln("        ),");
  sb.writeln(
      "        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [");
  sb.writeln("          Icon(icon, color: color, size: 18),");
  sb.writeln("          const SizedBox(width: 8),");
  sb.writeln(
      "          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 14)),");
  sb.writeln("        ]),");
  sb.writeln("      ),");
  sb.writeln("    );");
  sb.writeln("  }");
  sb.writeln("}");

  File(path).writeAsStringSync(sb.toString(), encoding: utf8);
  print('Written: $path (${sb.length} chars)');
}
