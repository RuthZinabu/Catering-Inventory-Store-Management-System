import 'package:flutter/material.dart';
import '../../models/store_model.dart';
import '../../services/api_repository.dart';
import 'stock_transfer_models.dart';

class StockTransferCreateScreen extends StatefulWidget {
  const StockTransferCreateScreen({super.key});

  @override
  State<StockTransferCreateScreen> createState() => _StockTransferCreateScreenState();
}

class _StockTransferCreateScreenState extends State<StockTransferCreateScreen> {
  int _step = 0;
  final _requestedDate = TextEditingController(
    text: DateTime.now().toIso8601String().split('T').first,
  );
  final _notes = TextEditingController();
  final Map<String, TextEditingController> _quantities = {};
  final Set<String> _selectedItemIds = {};
  List<Store> _stores = [];
  List<TransferStockItemViewModel> _sourceStock = [];
  Store? _fromStore;
  Store? _toStore;
  bool _loadingStores = true;
  bool _loadingStock = false;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStores();
  }

  @override
  void dispose() {
    _requestedDate.dispose();
    _notes.dispose();
    for (final controller in _quantities.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadStores() async {
    try {
      final stores = await ApiRepository.instance.getStores(active: true);
      if (!mounted) return;
      setState(() {
        _stores = stores;
        _fromStore = stores.isNotEmpty ? stores.first : null;
        _toStore = stores.length > 1 ? stores[1] : null;
        _loadingStores = false;
        if (stores.length < 2) {
          _error = 'At least two accessible active stores are required.';
        }
      });
      if (stores.isNotEmpty) await _loadSourceStock(stores.first.id);
    } catch (error) {
      if (mounted) {
        setState(() {
          _loadingStores = false;
          _error = error.toString();
        });
      }
    }
  }

  Future<void> _loadSourceStock(String storeId) async {
    setState(() {
      _loadingStock = true;
      _selectedItemIds.clear();
      for (final controller in _quantities.values) {
        controller.dispose();
      }
      _quantities.clear();
    });
    try {
      final stock = await ApiRepository.instance.getTransferStock(storeId);
      if (!mounted) return;
      setState(() {
        _sourceStock = stock;
        _loadingStock = false;
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _sourceStock = [];
          _loadingStock = false;
          _error = error.toString();
        });
      }
    }
  }

  void _selectItem(TransferStockItemViewModel item, bool selected) {
    setState(() {
      if (selected) {
        _selectedItemIds.add(item.itemId);
        _quantities[item.itemId] = TextEditingController(text: '');
      } else {
        _selectedItemIds.remove(item.itemId);
        _quantities.remove(item.itemId)?.dispose();
      }
    });
  }

  bool get _quantitiesValid {
    if (_selectedItemIds.isEmpty) return false;
    for (final item in _sourceStock.where((item) => _selectedItemIds.contains(item.itemId))) {
      final quantity = double.tryParse(_quantities[item.itemId]?.text ?? '') ?? 0;
      if (quantity <= 0 || quantity > item.availableQuantity) return false;
    }
    return true;
  }

  Future<void> _submitTransfer() async {
    if (_fromStore == null || _toStore == null || _fromStore!.id == _toStore!.id) {
      setState(() => _error = 'Choose different source and destination stores.');
      return;
    }
    if (!_quantitiesValid) {
      setState(() => _error = 'Select items and enter quantities within available stock.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ApiRepository.instance.createStockTransfer({
        'from_store_id': _fromStore!.id,
        'to_store_id': _toStore!.id,
        'requested_date': _requestedDate.text.trim(),
        'notes': _notes.text.trim(),
        'items': _sourceStock
            .where((item) => _selectedItemIds.contains(item.itemId))
            .map((item) => {
                  'item_id': item.itemId,
                  'quantity_requested':
                      double.parse(_quantities[item.itemId]!.text),
                })
            .toList(),
      });
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _stepBadge(int index, String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFDCEAFE) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(color: active ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(999)),
            alignment: Alignment.center,
            child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: active ? const Color(0xFF2563EB) : const Color(0xFF64748B), fontWeight: FontWeight.w700, fontSize: 12)),
        ],
      ),
    );
  }

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
              IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back_rounded), style: IconButton.styleFrom(backgroundColor: Colors.white, padding: const EdgeInsets.all(10))),
              const SizedBox(height: 16),
              Text('New Stock Transfer', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.6)),
              const SizedBox(height: 8),
              Text('Move inventory between catering locations with a premium mobile workflow.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14.5)),
              const SizedBox(height: 16),
              Row(
                children: [
                  _stepBadge(0, 'Locations', _step >= 0),
                  const SizedBox(width: 8),
                  _stepBadge(1, 'Items', _step >= 1),
                  const SizedBox(width: 8),
                  _stepBadge(2, 'Details', _step >= 2),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 8))]),
                child: _buildDataStepContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Step 1 • Select Locations', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            _buildField('Transfer Number', 'TR-1004'),
            _buildField('From Store', 'Main Store'),
            _buildField('To Store', 'Branch2 Store'),
            const SizedBox(height: 8),
            SizedBox(width: double.infinity, child: FilledButton(onPressed: () => setState(() => _step = 1), child: const Text('Next'))),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Step 2 • Select Items', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            _selectItemCard('Chicken Breast', 'Meat', '48 Kg', 'Available'),
            const SizedBox(height: 8),
            _selectItemCard('Basmati Rice', 'Dry Food', '14 Kg', 'Available'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => setState(() => _step = 0), child: const Text('Back'))),
                const SizedBox(width: 12),
                Expanded(child: FilledButton(onPressed: () => setState(() => _step = 2), child: const Text('Next'))),
              ],
            ),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Step 3 • Enter Quantities', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            _quantityCard('Chicken Breast', '48 Kg', '8 Kg', 'Kg'),
            const SizedBox(height: 8),
            _quantityCard('Basmati Rice', '14 Kg', '6 Kg', 'Kg'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => setState(() => _step = 1), child: const Text('Back'))),
                const SizedBox(width: 12),
                Expanded(child: FilledButton(onPressed: () => setState(() => _step = 3), child: const Text('Next'))),
              ],
            ),
          ],
        );
      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Step 4 • Transfer Details', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            _buildField('Transfer Date', '24 Jul 2026'),
            _buildField('Person Responsible', 'Alemu Bekele'),
            _buildField('Notes', 'Urgent for branch service'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => setState(() => _step = 2), child: const Text('Back'))),
                const SizedBox(width: 12),
                Expanded(child: FilledButton(onPressed: () => setState(() => _step = 4), child: const Text('Review'))),
              ],
            ),
          ],
        );
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Step 5 • Review & Confirm', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(18)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _summaryRow('Transfer Number', 'TR-1004'),
                  _summaryRow('From Store', 'Main Store'),
                  _summaryRow('To Store', 'Branch2 Store'),
                  _summaryRow('Transfer Date', '24 Jul 2026'),
                  _summaryRow('Person Responsible', 'Alemu Bekele'),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  _summaryRow('Items', '2'),
                  _summaryRow('Total Quantity', '14 Kg'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => setState(() => _step = 3), child: const Text('Back'))),
                const SizedBox(width: 12),
                Expanded(child: FilledButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StockTransferSuccessScreen())), child: const Text('Complete Transfer'))),
              ],
            ),
          ],
        );
    }
  }

  Widget _buildDataStepContent() {
    if (_loadingStores) {
      return const Center(child: CircularProgressIndicator());
    }

    final selectedItems = _sourceStock
        .where((item) => _selectedItemIds.contains(item.itemId))
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_error != null) ...[
          Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          const SizedBox(height: 12),
        ],
        if (_step == 0) ...[
          Text('Select locations', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          _storeDropdown(
            'From Store',
            _fromStore,
            _stores,
            (store) async {
              if (store == null) return;
              setState(() {
                _fromStore = store;
                if (_toStore?.id == store.id) {
                  _toStore = _stores.firstWhere((candidate) => candidate.id != store.id);
                }
                _error = null;
              });
              await _loadSourceStock(store.id);
            },
          ),
          _storeDropdown(
            'To Store',
            _toStore,
            _stores.where((store) => store.id != _fromStore?.id).toList(),
            (store) => setState(() => _toStore = store),
          ),
          _stepButtons(
            backStep: null,
            nextLabel: 'Choose Items',
            onNext: _fromStore == null || _toStore == null
                ? null
                : () => setState(() => _step = 1),
          ),
        ] else if (_step == 1) ...[
          Text('Select items', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          if (_loadingStock)
            const Center(child: CircularProgressIndicator())
          else if (_sourceStock.isEmpty)
            const Text('No stock is available in the selected source store.')
          else
            ..._sourceStock.map((item) => CheckboxListTile(
                  value: _selectedItemIds.contains(item.itemId),
                  title: Text(item.name),
                  subtitle: Text('${item.availableQuantity} ${item.unit} available'),
                  onChanged: (selected) => _selectItem(item, selected == true),
                  contentPadding: EdgeInsets.zero,
                )),
          _stepButtons(
            backStep: 0,
            nextLabel: 'Enter Quantities',
            onNext: _selectedItemIds.isEmpty
                ? null
                : () => setState(() => _step = 2),
          ),
        ] else if (_step == 2) ...[
          Text('Enter quantities', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          ...selectedItems.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${item.name} · ${item.availableQuantity} ${item.unit} available'),
                    TextField(
                      controller: _quantities[item.itemId],
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: 'Quantity (${item.unit})'),
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ),
              )),
          _stepButtons(
            backStep: 1,
            nextLabel: 'Transfer Details',
            onNext: !_quantitiesValid ? null : () => setState(() => _step = 3),
          ),
        ] else if (_step == 3) ...[
          Text('Transfer details', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          TextField(
            controller: _requestedDate,
            readOnly: true,
            decoration: const InputDecoration(labelText: 'Requested Date'),
            onTap: () async {
              final today = DateTime.now();
              final selected = await showDatePicker(
                context: context,
                initialDate: today,
                firstDate: today.subtract(const Duration(days: 365)),
                lastDate: today.add(const Duration(days: 365)),
              );
              if (selected != null) {
                _requestedDate.text = selected.toIso8601String().split('T').first;
              }
            },
          ),
          TextField(
            controller: _notes,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Notes'),
          ),
          _stepButtons(
            backStep: 2,
            nextLabel: 'Review Request',
            onNext: () => setState(() => _step = 4),
          ),
        ] else ...[
          Text('Review transfer request', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          _summaryRow('From Store', _fromStore?.name ?? ''),
          _summaryRow('To Store', _toStore?.name ?? ''),
          _summaryRow('Requested Date', _requestedDate.text),
          _summaryRow('Items', '${selectedItems.length}'),
          _summaryRow(
            'Total Quantity',
            selectedItems.fold<double>(0, (total, item) =>
                total + (double.tryParse(_quantities[item.itemId]?.text ?? '') ?? 0))
                .toStringAsFixed(3),
          ),
          const SizedBox(height: 12),
          _stepButtons(
            backStep: 3,
            nextLabel: _saving ? 'Creating…' : 'Create Transfer Request',
            onNext: _saving ? null : _submitTransfer,
          ),
        ],
      ],
    );
  }

  Widget _storeDropdown(
    String label,
    Store? value,
    List<Store> options,
    ValueChanged<Store?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<Store>(
        value: value != null && options.any((store) => store.id == value.id) ? value : null,
        decoration: InputDecoration(labelText: label),
        items: options.map((store) => DropdownMenuItem(
          value: store,
          child: Text('${store.name} (${store.code})'),
        )).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _stepButtons({
    required int? backStep,
    required String nextLabel,
    required VoidCallback? onNext,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          if (backStep != null) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _step = backStep),
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: FilledButton(
              onPressed: onNext,
              child: Text(nextLabel),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(initialValue: value, decoration: InputDecoration(labelText: label)),
    );
  }

  Widget _selectItemCard(String name, String category, String stock, String availability) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontWeight: FontWeight.w700)), Text(category, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12))])),
          const SizedBox(width: 10),
          Text(stock, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(width: 10),
          Icon(Icons.check_circle_outline_rounded, color: availability == 'Available' ? const Color(0xFF14B8A6) : const Color(0xFF64748B)),
        ],
      ),
    );
  }

  Widget _quantityCard(String name, String currentStock, String quantity, String unit) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Current stock: $currentStock', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
          const SizedBox(height: 8),
          TextFormField(initialValue: quantity, decoration: InputDecoration(labelText: 'Quantity to Transfer', suffixText: unit)),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))), Text(value, style: const TextStyle(fontWeight: FontWeight.w700))]));
  }
}

class StockTransferSuccessScreen extends StatelessWidget {
  const StockTransferSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 8))]),
                child: Column(
                  children: [
                    Container(width: 72, height: 72, decoration: BoxDecoration(color: const Color(0xFFDCEAFE), borderRadius: BorderRadius.circular(999)), child: const Icon(Icons.check_circle_rounded, size: 38, color: Color(0xFF2563EB))),
                    const SizedBox(height: 16),
                    Text('Stock Transfer Completed Successfully', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Text('Transfer TR-1004 was created and routed to Branch2 Store.', style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _chip('TR-1004'),
                        _chip('Main Store'),
                        _chip('Branch2 Store'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: OutlinedButton(onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst), child: const Text('Done'))),
                        const SizedBox(width: 10),
                        Expanded(child: FilledButton(onPressed: () {}, child: const Text('Print Transfer Note'))),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
