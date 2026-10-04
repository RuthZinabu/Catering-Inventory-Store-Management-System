import 'package:flutter/material.dart';

import '../../models/inventory_models.dart';
import '../../models/store_model.dart';
import '../../services/api_repository.dart';

class StockReferenceFields extends StatefulWidget {
  final String? supplierId;
  final String? storeId;
  final ValueChanged<Supplier?> onSupplierChanged;
  final ValueChanged<Store?> onStoreChanged;

  const StockReferenceFields({
    super.key,
    required this.supplierId,
    required this.storeId,
    required this.onSupplierChanged,
    required this.onStoreChanged,
  });

  @override
  State<StockReferenceFields> createState() => _StockReferenceFieldsState();
}

class _StockReferenceFieldsState extends State<StockReferenceFields> {
  late Future<_StockReferenceOptions> _optionsFuture;

  @override
  void initState() {
    super.initState();
    _optionsFuture = _loadOptions();
  }

  Future<_StockReferenceOptions> _loadOptions() async {
    final results = await Future.wait([
      ApiRepository.instance.getAllActiveSuppliers(),
      ApiRepository.instance.getAllActiveStores(),
    ]);
    return _StockReferenceOptions(
      suppliers: results[0] as List<Supplier>,
      stores: results[1] as List<Store>,
    );
  }

  void _retry() {
    setState(() => _optionsFuture = _loadOptions());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_StockReferenceOptions>(
      future: _optionsFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Could not load suppliers and stores: ${snapshot.error}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                TextButton.icon(
                  onPressed: _retry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: LinearProgressIndicator(),
          );
        }

        final options = snapshot.data!;
        final supplierIds = options.suppliers.map((supplier) => supplier.id).toSet();
        final storeIds = options.stores.map((store) => store.id).toSet();
        final supplierValue =
            supplierIds.contains(widget.supplierId) ? widget.supplierId : null;
        final storeValue =
            storeIds.contains(widget.storeId) ? widget.storeId : null;

        return Column(
          children: [
            _field<String>(
              label: 'Supplier',
              icon: Icons.person_rounded,
              value: supplierValue,
              items: options.suppliers
                  .map(
                    (supplier) => DropdownMenuItem(
                      value: supplier.id,
                      child: Text(
                        supplier.company.isNotEmpty
                            ? supplier.company
                            : supplier.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              emptyHint: 'No active suppliers registered',
              onChanged: (id) {
                widget.onSupplierChanged(
                  options.suppliers.cast<Supplier?>().firstWhere(
                        (supplier) => supplier?.id == id,
                        orElse: () => null,
                      ),
                );
              },
            ),
            _field<String>(
              label: 'Location / Store',
              icon: Icons.location_on_rounded,
              value: storeValue,
              items: options.stores
                  .map(
                    (store) => DropdownMenuItem(
                      value: store.id,
                      child: Text(
                        store.code.isEmpty
                            ? store.name
                            : '${store.name} (${store.code})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              emptyHint: 'No active stores registered',
              validator: (value) {
                if (value == null) return 'Select a registered store';
                return null;
              },
              onChanged: (id) {
                widget.onStoreChanged(
                  options.stores.cast<Store?>().firstWhere(
                        (store) => store?.id == id,
                        orElse: () => null,
                      ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _field<T>({
    required String label,
    required IconData icon,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required String emptyHint,
    required ValueChanged<T?> onChanged,
    String? Function(T?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<T>(
        value: value,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF64748B)),
          hintText: items.isEmpty ? emptyHint : 'Select $label',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
          ),
        ),
        items: items,
        onChanged: items.isEmpty ? null : onChanged,
        validator: validator,
      ),
    );
  }
}

class _StockReferenceOptions {
  final List<Supplier> suppliers;
  final List<Store> stores;

  const _StockReferenceOptions({
    required this.suppliers,
    required this.stores,
  });
}