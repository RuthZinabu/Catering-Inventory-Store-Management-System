import 'package:flutter/material.dart';

import '../models/inventory_models.dart';
import '../services/api_repository.dart';
import '../widgets/loading_error_widgets.dart';
import 'inventory_create_screen.dart';

class InventoryDetailScreen extends StatefulWidget {
  final InventoryItem item;

  const InventoryDetailScreen({super.key, required this.item});

  @override
  State<InventoryDetailScreen> createState() => _InventoryDetailScreenState();
}

class _InventoryDetailScreenState extends State<InventoryDetailScreen> {
  late InventoryItem _item;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
  }

  Future<void> _deleteItem() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Delete Item'),
        content: Text(
            'Are you sure you want to delete "${_item.name}"? This action cannot be undone.'),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() {
        _isLoading = true;
      });

      try {
        await ApiRepository.instance.deleteInventoryItem(_item.id);

        if (mounted) {
          Navigator.of(context).pop(true); // Return true to indicate deletion
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              title: const Text('Error'),
              content: Text('Failed to delete item: ${e.toString()}'),
              actions: [
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    }
  }

  Future<void> _editItem() async {
    // For now, navigate to create screen with pre-filled data
    // In a real app, you'd have a separate edit screen or modify create screen
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Edit Item'),
        content: const Text(
            'Edit functionality will be available in a future update. For now, you can create a new item with updated information.'),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const InventoryCreateScreen()),
              );
            },
            child: const Text('Create New'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentForCategory(_item.category);
    final stockFraction = (_item.stockOnHand != null &&
            _item.maxStock != null &&
            _item.maxStock! > 0)
        ? (_item.stockOnHand! / _item.maxStock!).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _isLoading
          ? const Center(child: LoadingWidget())
          : SafeArea(
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
                                style: IconButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    padding: const EdgeInsets.all(10)),
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: _editItem,
                                icon: const Icon(Icons.edit_note_rounded),
                                style: IconButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    padding: const EdgeInsets.all(10)),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: _deleteItem,
                                icon: const Icon(Icons.delete_outline_rounded,
                                    color: Colors.red),
                                style: IconButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    padding: const EdgeInsets.all(10)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              gradient: LinearGradient(colors: [
                                accent.withOpacity(0.92),
                                accent.withOpacity(0.7)
                              ]),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(999)),
                                  child: Text(_item.category,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700)),
                                ),
                                const SizedBox(height: 12),
                                Text(_item.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -0.5)),
                                const SizedBox(height: 8),
                                Text(_item.description,
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 14,
                                        height: 1.45)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                  child: _statTile(
                                      'In stock',
                                      '${_item.stockOnHand} ${_item.unit}',
                                      accent)),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: _statTile(
                                      'Reorder',
                                      '${_item.reorderPoint} ${_item.unit}',
                                      const Color(0xFFF59E0B))),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Stock overview',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 10),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(999),
                                    child: LinearProgressIndicator(
                                        value: stockFraction,
                                        minHeight: 8,
                                        backgroundColor:
                                            const Color(0xFFF1F5F9),
                                        color: accent),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Text(
                                          'Min: ${_item.minStock} ${_item.unit}',
                                          style: const TextStyle(
                                              color: Color(0xFF64748B))),
                                      const Spacer(),
                                      Text(
                                          'Max: ${_item.maxStock} ${_item.unit}',
                                          style: const TextStyle(
                                              color: Color(0xFF64748B))),
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
                                  Text('Pricing',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 10),
                                  _detailRow('Purchase price',
                                      'ETB ${_item.purchasePrice.toStringAsFixed(0)}'),
                                  _detailRow('Internal cost',
                                      'ETB ${_item.internalCost?.toStringAsFixed(0)}'),
                                  _detailRow('Status', _item.status),
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
                                  Text('Tracking',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 10),
                                  _detailRow('Item code', _item.code),
                                  _detailRow('Unit', _item.unit),
                                  _detailRow('Location', 'Main Store'),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                              color: const Color(0xFFF8FAFC),
                                              borderRadius:
                                                  BorderRadius.circular(18)),
                                          child: Column(
                                            children: [
                                              const Icon(
                                                  Icons.qr_code_2_rounded,
                                                  size: 38,
                                                  color: Color(0xFF2563EB)),
                                              const SizedBox(height: 6),
                                              Text('QR',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleSmall
                                                      ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.w700)),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                              color: const Color(0xFFF8FAFC),
                                              borderRadius:
                                                  BorderRadius.circular(18)),
                                          child: Column(
                                            children: [
                                              const Icon(Icons.barcode_reader,
                                                  size: 38,
                                                  color: Color(0xFF2563EB)),
                                              const SizedBox(height: 6),
                                              Text('Barcode',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleSmall
                                                      ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.w700)),
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
                                  onPressed: _editItem,
                                  icon: const Icon(Icons.edit_rounded),
                                  label: const Text('Edit'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    // Update stock functionality - show dialog for stock adjustment
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(24)),
                                        title: const Text('Update Stock'),
                                        content: const Text(
                                            'Stock update functionality will be available in a future update.'),
                                        actions: [
                                          FilledButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
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
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 14,
                offset: const Offset(0, 8))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 16, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, color: Color(0xFF334155)))),
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
