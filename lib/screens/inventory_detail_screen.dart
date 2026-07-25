import 'package:flutter/material.dart';

import '../models/inventory_models.dart';

class InventoryDetailScreen extends StatelessWidget {
  final InventoryItem item;

  const InventoryDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final accent = _accentForCategory(item.category);
    final stockFraction = (item.stockOnHand / item.maxStock).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_rounded),
                          style: IconButton.styleFrom(backgroundColor: Colors.white, padding: const EdgeInsets.all(10)),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.edit_note_rounded),
                          style: IconButton.styleFrom(backgroundColor: Colors.white, padding: const EdgeInsets.all(10)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: LinearGradient(colors: [accent.withOpacity(0.92), accent.withOpacity(0.7)]),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(999)),
                            child: Text(item.category, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                          ),
                          const SizedBox(height: 12),
                          Text(item.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                          const SizedBox(height: 8),
                          Text(item.description, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14, height: 1.45)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _statTile('In stock', '${item.stockOnHand} ${item.unit}', accent)),
                        const SizedBox(width: 12),
                        Expanded(child: _statTile('Reorder', '${item.reorderPoint} ${item.unit}', const Color(0xFFF59E0B))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Stock overview', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: LinearProgressIndicator(value: stockFraction, minHeight: 8, backgroundColor: const Color(0xFFF1F5F9), color: accent),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Text('Min: ${item.minStock} ${item.unit}', style: const TextStyle(color: Color(0xFF64748B))),
                                const Spacer(),
                                Text('Max: ${item.maxStock} ${item.unit}', style: const TextStyle(color: Color(0xFF64748B))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Pricing', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 10),
                            _detailRow('Purchase price', 'ETB ${item.purchasePrice.toStringAsFixed(0)}'),
                            _detailRow('Internal cost', 'ETB ${item.internalCost.toStringAsFixed(0)}'),
                            _detailRow('Status', item.status),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tracking', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 10),
                            _detailRow('Item code', item.code),
                            _detailRow('Unit', item.unit),
                            _detailRow('Location', 'Main Store'),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(18)),
                                    child: Column(
                                      children: [
                                        const Icon(Icons.qr_code_2_rounded, size: 38, color: Color(0xFF2563EB)),
                                        const SizedBox(height: 6),
                                        Text('QR', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(18)),
                                    child: Column(
                                      children: [
                                        const Icon(Icons.barcode_reader, size: 38, color: Color(0xFF2563EB)),
                                        const SizedBox(height: 6),
                                        Text('Barcode', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.edit_rounded),
                            label: const Text('Edit'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.sync_alt_rounded),
                            label: const Text('Update Stock'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statTile(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 14, offset: const Offset(0, 8))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF334155)))),
          Text(value, style: const TextStyle(color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  Color _accentForCategory(String category) {
    switch (category) {
      case 'Meat':
        return const Color(0xFFEF4444);
      case 'Vegetables':
        return const Color(0xFF10B981);
      case 'Fruits':
        return const Color(0xFFF59E0B);
      case 'Dairy':
        return const Color(0xFF3B82F6);
      case 'Beverages':
        return const Color(0xFF8B5CF6);
      case 'Spices':
        return const Color(0xFFEC4899);
      case 'Oil':
        return const Color(0xFF0F766E);
      case 'Cleaning Supplies':
        return const Color(0xFF6366F1);
      case 'Packaging Materials':
        return const Color(0xFF84CC16);
      default:
        return const Color(0xFF2563EB);
    }
  }
}
