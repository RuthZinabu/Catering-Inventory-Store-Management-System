import 'package:flutter/material.dart';

import '../../models/inventory_models.dart';

class SupplierDetailScreen extends StatelessWidget {
  final Supplier supplier;

  const SupplierDetailScreen({super.key, required this.supplier});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back_rounded), style: IconButton.styleFrom(backgroundColor: Colors.white, padding: const EdgeInsets.all(10))),
                  const Spacer(),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)), child: Text(supplier.status, style:const TextStyle(fontWeight: FontWeight.w700))),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 8))]),
                child: Column(
                  children: [
                    Container(width: 70, height: 70, decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(20)), child: const Icon(Icons.business_outlined, size: 32, color: Color(0xFF2563EB))),
                    const SizedBox(height: 12),
                    Text(supplier.company, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Text(supplier.contactPerson, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _sectionCard(context, 'Contact', [
                _detailRow('Phone', supplier.phone),
                _detailRow('Email', supplier.email),
                _detailRow('Address', supplier.address),
              ]),
              const SizedBox(height: 12),
              _sectionCard(context, 'Finance', [
                _detailRow('Tax Number', supplier.taxNumber),
                _detailRow('Outstanding Balance', 'ETB ${supplier.outstandingBalance.toInt()}'),
                _detailRow('Rating', '★ 4.8'),
              ]),
              const SizedBox(height: 12),
              _sectionCard(context, 'Recent Purchases', [
                _detailRow('PO-1048', 'Chicken Breast • 40 Kg'),
                _detailRow('PO-1049', 'Basmati Rice • 25 Kg'),
              ]),
              const SizedBox(height: 12),
              _sectionCard(context, 'Invoices & Payments', [
                _detailRow('Invoice #INV-112', 'Paid'),
                _detailRow('Invoice #INV-113', 'Pending'),
              ]),
              const SizedBox(height: 12),
              _sectionCard(context, 'Products Supplied', [
                _detailRow('Meat', 'Chicken, Beef'),
                _detailRow('Dry Food', 'Rice, Flour'),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionCard(BuildContext context, String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 8))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)), const SizedBox(height: 10), ...children]),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF334155)))), Text(value, style: const TextStyle(color: Color(0xFF64748B)))]),
    );
  }
}
