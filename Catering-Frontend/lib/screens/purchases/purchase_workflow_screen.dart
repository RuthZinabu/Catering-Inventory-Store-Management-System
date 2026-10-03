import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import 'purchase_actions_screen.dart';
import 'purchase_form_screen.dart';
import 'purchase_models.dart';

class PurchaseListScreen extends StatefulWidget {
  const PurchaseListScreen({super.key});

  @override
  State<PurchaseListScreen> createState() => _PurchaseListScreenState();
}

class _PurchaseListScreenState extends State<PurchaseListScreen> {
  final _search = TextEditingController();
  List<PurchaseViewModel> _purchases = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final storeId = ApiClient.instance.storeId;
    if (storeId == null) {
      setState(() {
        _loading = false;
        _error = 'No destination store is selected.';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await ApiClient.instance.get('/purchase-orders?store_id=$storeId&per_page=100');
      final rows = (response['data'] as Map)['purchase_orders'] as List? ?? const [];
      if (!mounted) return;
      setState(() {
        _purchases = rows
            .map((row) => PurchaseViewModel.fromJson(Map<String, dynamic>.from(row as Map)))
            .toList();
        _loading = false;
      });
    } on ApiException catch (error) {
      if (mounted) setState(() {
        _loading = false;
        _error = error.message;
      });
    }
  }

  List<PurchaseViewModel> get _filtered {
    final query = _search.text.trim().toLowerCase();
    if (query.isEmpty) return _purchases;
    return _purchases.where((purchase) =>
        purchase.number.toLowerCase().contains(query) ||
        purchase.supplier.toLowerCase().contains(query) ||
        purchase.status.toLowerCase().contains(query)).toList();
  }

  Future<void> _openForm([PurchaseViewModel? purchase]) async {
    final changed = await Navigator.of(context).push<bool>(MaterialPageRoute(
      builder: (_) => PurchaseFormScreen(purchase: purchase),
    ));
    if (changed == true) _load();
  }

  Future<void> _openAction(Widget screen) async {
    final changed = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => screen));
    if (changed == true) _load();
  }

  Future<void> _approve(PurchaseViewModel purchase) async {
    try {
      await ApiClient.instance.post('/purchase-orders/${purchase.id}/approve', {});
      _load();
    } on ApiException catch (error) {
      _showError(error.message);
    }
  }

  Future<void> _delete(PurchaseViewModel purchase) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete purchase order?'),
        content: Text('Delete ${purchase.number}? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await ApiClient.instance.delete('/purchase-orders/${purchase.id}');
      _load();
    } on ApiException catch (error) {
      _showError(error.message);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final purchases = _filtered;
    final pending = purchases.where((purchase) => purchase.status == 'Pending' || purchase.status == 'Approved' || purchase.status == 'Partially Received').length;
    final total = purchases.fold<double>(0, (sum, purchase) => sum + purchase.totalAmount);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('New Purchase'),
      ),
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Purchases', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 6),
              const Text('Purchase orders, receiving, supplier returns, and invoices.'),
              const SizedBox(height: 16),
              TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search purchase number, supplier, or status',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _search.text.isEmpty ? null : IconButton(onPressed: () => setState(_search.clear), icon: const Icon(Icons.close)),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(spacing: 10, runSpacing: 8, children: [
                _summary('Purchase Orders', '${purchases.length}'),
                _summary('Open Deliveries', '$pending'),
                _summary('Purchase Value', 'ETB ${total.toStringAsFixed(2)}'),
              ]),
            ]),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [Text(_error!, textAlign: TextAlign.center), const SizedBox(height: 12), OutlinedButton.icon(onPressed: _load, icon: const Icon(Icons.refresh), label: const Text('Retry'))])))
                    : purchases.isEmpty
                        ? const Center(child: Text('No purchase orders found.'))
                        : RefreshIndicator(
                            onRefresh: _load,
                            child: ListView.separated(
                              padding: const EdgeInsets.fromLTRB(20, 4, 20, 96),
                              itemCount: purchases.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) => _purchaseTile(purchases[index]),
                            ),
                          ),
          ),
        ]),
      ),
    );
  }

  Widget _purchaseTile(PurchaseViewModel purchase) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(purchase.number, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 3),
            Text(purchase.supplier),
          ])),
          _statusBadge(purchase.status),
        ]),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 6, children: [
          _chip('Order ${purchase.date}'),
          _chip('${purchase.items.length} items'),
          if (purchase.expectedDelivery.isNotEmpty) _chip('Due ${purchase.expectedDelivery}'),
          _chip(purchase.paymentStatus),
        ]),
        const SizedBox(height: 10),
        Text(purchase.amount, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        Wrap(spacing: 4, runSpacing: 4, children: [
          IconButton(tooltip: 'View purchase', onPressed: () => _openAction(PurchaseDetailScreen(purchase: purchase)), icon: const Icon(Icons.visibility_outlined)),
          if (purchase.status == 'Draft' || purchase.status == 'Pending')
            IconButton(tooltip: 'Update purchase', onPressed: () => _openForm(purchase), icon: const Icon(Icons.edit_outlined)),
          if (purchase.status == 'Draft' || purchase.status == 'Pending')
            IconButton(tooltip: 'Approve purchase', onPressed: () => _approve(purchase), icon: const Icon(Icons.check_circle_outline)),
          if (purchase.status == 'Approved' || purchase.status == 'Partially Received')
            IconButton(tooltip: 'Receive goods', onPressed: () => _openAction(GoodsReceivingScreen(purchase: purchase)), icon: const Icon(Icons.move_to_inbox_outlined)),
          if (purchase.items.any((line) => line.receivedQuantity > 0))
            IconButton(tooltip: 'Return purchase', onPressed: () => _openAction(PurchaseReturnScreen(purchase: purchase)), icon: const Icon(Icons.keyboard_return)),
          IconButton(tooltip: 'Invoice PDF', onPressed: () => _openAction(InvoicePreviewScreen(purchase: purchase)), icon: const Icon(Icons.receipt_long_outlined)),
          if (purchase.status == 'Draft' || purchase.status == 'Pending')
            IconButton(tooltip: 'Delete purchase', onPressed: () => _delete(purchase), icon: const Icon(Icons.delete_outline)),
        ]),
      ]),
    );
  }

  Widget _summary(String title, String value) => Container(
        constraints: const BoxConstraints(minWidth: 130),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(10)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: Theme.of(context).textTheme.bodySmall), Text(value, style: const TextStyle(fontWeight: FontWeight.w700))]),
      );

  Widget _chip(String value) => Chip(label: Text(value), visualDensity: VisualDensity.compact);

  Widget _statusBadge(String status) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(color: _statusColor(status).withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
        child: Text(status, style: TextStyle(color: _statusColor(status), fontSize: 12, fontWeight: FontWeight.w700)),
      );

  Color _statusColor(String status) => switch (status) {
        'Draft' => Colors.blueGrey,
        'Pending' => Colors.orange.shade800,
        'Approved' => Colors.blue.shade800,
        'Partially Received' => Colors.deepPurple,
        'Received' => Colors.green.shade800,
        _ => Colors.red.shade800,
      };
}
