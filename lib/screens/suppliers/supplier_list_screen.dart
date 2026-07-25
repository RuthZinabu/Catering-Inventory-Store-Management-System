import 'package:flutter/material.dart';

import '../../models/inventory_models.dart';
import '../../services/mock_repository.dart';
import 'supplier_detail_screen.dart';
import 'supplier_form_screen.dart';

class SupplierListScreen extends StatefulWidget {
  const SupplierListScreen({super.key});

  @override
  State<SupplierListScreen> createState() => _SupplierListScreenState();
}

class _SupplierListScreenState extends State<SupplierListScreen> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final suppliers = MockRepository.suppliers.where((supplier) {
      final query = searchQuery.toLowerCase();
      return query.isEmpty ||
          supplier.company.toLowerCase().contains(query) ||
          supplier.contactPerson.toLowerCase().contains(query) ||
          supplier.phone.toLowerCase().contains(query);
    }).toList();

    final totalSuppliers = suppliers.length;
    final activeSuppliers = suppliers.where((supplier) => supplier.status == 'Active').length;
    final outstandingBalance = suppliers.fold<double>(0.0, (sum, supplier) => sum + supplier.outstandingBalance);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToForm(context, null),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Supplier'),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Suppliers', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.6)),
                    const SizedBox(height: 8),
                    Text('Manage supplier relationships with calm, modern workflows.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14.5)),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 8))],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              onChanged: (value) => setState(() => searchQuery = value),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Search suppliers',
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(onPressed: () {}, icon: const Icon(Icons.tune_rounded, color: Color(0xFF2563EB))),
                          IconButton(onPressed: () {}, icon: const Icon(Icons.sort_rounded, color: Color(0xFF2563EB))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _summaryCard('Total Suppliers', '$totalSuppliers', const Color(0xFF2563EB), Icons.group_outlined)),
                        const SizedBox(width: 10),
                        Expanded(child: _summaryCard('Active Suppliers', '$activeSuppliers', const Color(0xFF14B8A6), Icons.check_circle_rounded)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _summaryCard('Outstanding Balance', 'ETB ${outstandingBalance.toInt().toString()}', const Color(0xFFF59E0B), Icons.account_balance_wallet_rounded),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 112),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final supplier = suppliers[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 16, offset: const Offset(0, 10))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(18)),
                              child: const Icon(Icons.business_outlined, color: Color(0xFF2563EB), size: 28),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(child: Text(supplier.company, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700))),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: supplier.status == 'Active' ? const Color(0xFFDCFCE7) : const Color(0xFFFDE68A),
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                        child: Text(supplier.status, style: TextStyle(color: supplier.status == 'Active' ? const Color(0xFF15803D) : const Color(0xFFB45309), fontSize: 11, fontWeight: FontWeight.w700)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(supplier.contactPerson, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 6,
                                    children: [
                                      _infoChip(supplier.phone),
                                      _infoChip(supplier.email),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _infoChip('Balance ETB ${supplier.outstandingBalance.toInt()}')),
                            const SizedBox(width: 8),
                            Expanded(child: _infoChip('Last: ${_formatDate(DateTime.now())}')),
                            const SizedBox(width: 8),
                            Expanded(child: _infoChip('★ ${supplier.taxNumber.substring(0, 3)}')),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => SupplierDetailScreen(supplier: supplier))),
                                icon: const Icon(Icons.visibility_rounded),
                                label: const Text('View Details'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _navigateToForm(context, supplier),
                                icon: const Icon(Icons.edit_rounded),
                                label: const Text('Update'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () => _showDeleteSheet(context, supplier),
                              icon: const Icon(Icons.more_horiz_rounded, color: Color(0xFF64748B)),
                              style: IconButton.styleFrom(backgroundColor: const Color(0xFFF8FAFC)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }, childCount: suppliers.length),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 14, offset: const Offset(0, 8))]),
      child: Row(
        children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withOpacity(0.14), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: color, size: 20)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)), const SizedBox(height: 2), Text(value, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12))]))
        ],
      ),
    );
  }

  Widget _infoChip(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(999)),
      child: Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
    );
  }

  void _navigateToForm(BuildContext context, Supplier? supplier) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => SupplierFormScreen(supplier: supplier)));
  }

  void _showDeleteSheet(BuildContext context, Supplier supplier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 44, height: 5, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(999))),
            const SizedBox(height: 16),
            Text('Delete Supplier', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('Are you sure you want to delete this supplier?', style: const TextStyle(color: Color(0xFF64748B))),
            const SizedBox(height: 18),
            SizedBox(width: double.infinity, child: FilledButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Delete Supplier'))),
            const SizedBox(height: 10),
            SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel'))),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
