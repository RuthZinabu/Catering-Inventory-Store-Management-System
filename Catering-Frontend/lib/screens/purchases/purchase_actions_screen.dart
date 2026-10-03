import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../services/api_service.dart';
import 'purchase_models.dart';

class GoodsReceivingScreen extends StatefulWidget {
  final PurchaseViewModel purchase;

  const GoodsReceivingScreen({super.key, required this.purchase});

  @override
  State<GoodsReceivingScreen> createState() => _GoodsReceivingScreenState();
}

class _GoodsReceivingScreenState extends State<GoodsReceivingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _date = TextEditingController(text: _today());
  final _driver = TextEditingController();
  final _vehicle = TextEditingController();
  final _notes = TextEditingController();
  late final List<_ReceiptLineForm> _lines;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _lines = widget.purchase.items
        .where((line) => line.quantity > line.receivedQuantity)
        .map(_ReceiptLineForm.new)
        .toList();
  }

  @override
  void dispose() {
    _date.dispose();
    _driver.dispose();
    _vehicle.dispose();
    _notes.dispose();
    for (final line in _lines) {
      line.dispose();
    }
    super.dispose();
  }

  Future<void> _receive() async {
    if (!_formKey.currentState!.validate()) return;
    final receiving =
        _lines.where((line) => line.received.text.trim().isNotEmpty).toList();
    if (receiving.isEmpty) {
      setState(
          () => _error = 'Enter a received quantity for at least one item.');
      return;
    }
    for (final line in receiving) {
      final received = double.tryParse(line.received.text) ?? 0;
      final accepted = double.tryParse(line.accepted.text) ?? 0;
      final rejected = double.tryParse(line.rejected.text) ?? 0;
      if (received <= 0 ||
          (received - accepted - rejected).abs() > 0.001 ||
          received >
              line.orderLine.quantity - line.orderLine.receivedQuantity) {
        setState(() => _error =
            'Received quantity must match accepted plus rejected and cannot exceed the outstanding quantity.');
        return;
      }
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final response = await ApiClient.instance.post(
        '/purchase-orders/${widget.purchase.id}/receive',
        {
          'delivery_date': _date.text,
          'driver_name':
              _driver.text.trim().isEmpty ? null : _driver.text.trim(),
          'vehicle_number':
              _vehicle.text.trim().isEmpty ? null : _vehicle.text.trim(),
          'notes': _notes.text.trim().isEmpty ? null : _notes.text.trim(),
          'items': receiving
              .map((line) => {
                    'purchase_order_item_id': line.orderLine.id,
                    'received_quantity': double.parse(line.received.text),
                    'accepted_quantity': double.parse(line.accepted.text),
                    'rejected_quantity': double.parse(line.rejected.text),
                    'quality_status': line.qualityStatus,
                    'rejection_reason': line.reason.text.trim().isEmpty
                        ? null
                        : line.reason.text.trim(),
                  })
              .toList(),
        },
      );
      if (!mounted) return;
      final data = Map<String, dynamic>.from(response['data'] as Map);
      final grnNumber = data['grn_number'] as String? ?? 'GRN';
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Goods receipt recorded'),
          content: Text('GRN number: $grnNumber'),
          actions: [
            TextButton(
              onPressed: () async => Printing.sharePdf(
                  bytes: await _grnPdf(grnNumber, receiving),
                  filename: '$grnNumber.pdf'),
              child: const Text('Download GRN'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop(true);
              },
              child: const Text('Done'),
            ),
          ],
        ),
      );
    } on ApiException catch (error) {
      if (mounted)
        setState(() {
          _saving = false;
          _error = error.message;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Receive ${widget.purchase.number}')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(widget.purchase.supplier,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextFormField(
                controller: _date,
                readOnly: true,
                decoration: const InputDecoration(
                    labelText: 'Delivery Date',
                    suffixIcon: Icon(Icons.calendar_today)),
                onTap: _pickDate),
            const SizedBox(height: 10),
            TextFormField(
                controller: _driver,
                decoration: const InputDecoration(labelText: 'Driver Name')),
            const SizedBox(height: 10),
            TextFormField(
                controller: _vehicle,
                decoration: const InputDecoration(labelText: 'Vehicle Number')),
            const SizedBox(height: 20),
            Text('Verify Delivery',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (_lines.isEmpty)
              const Text('All ordered quantities have already been received.'),
            for (final line in _lines) _receiptLine(line),
            TextFormField(
                controller: _notes,
                maxLines: 3,
                decoration:
                    const InputDecoration(labelText: 'Receiving Notes')),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _saving || _lines.isEmpty ? null : _receive,
              child: _saving
                  ? const CircularProgressIndicator()
                  : const Text('Record Goods Receipt'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _receiptLine(_ReceiptLineForm line) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${line.orderLine.name} • ${line.orderLine.unit}',
              style: const TextStyle(fontWeight: FontWeight.w700)),
          Text(
              'Outstanding ${_qty(line.orderLine.quantity - line.orderLine.receivedQuantity)}'),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _quantityField(line.received, 'Received')),
            const SizedBox(width: 8),
            Expanded(child: _quantityField(line.accepted, 'Accepted')),
            const SizedBox(width: 8),
            Expanded(child: _quantityField(line.rejected, 'Rejected')),
          ]),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: line.qualityStatus,
            decoration: const InputDecoration(labelText: 'Quality Status'),
            items: const ['Accepted', 'Partially Accepted', 'Rejected']
                .map((status) =>
                    DropdownMenuItem(value: status, child: Text(status)))
                .toList(),
            onChanged: (value) =>
                setState(() => line.qualityStatus = value ?? 'Accepted'),
          ),
          const SizedBox(height: 8),
          TextFormField(
              controller: line.reason,
              decoration: const InputDecoration(labelText: 'Rejection Reason')),
        ]),
      ),
    );
  }

  Widget _quantityField(TextEditingController controller, String label) =>
      TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: label, isDense: true),
        onChanged: (value) {
          if (label == 'Received') {
            final line =
                _lines.firstWhere((entry) => entry.received == controller);
            line.accepted.text = value;
            line.rejected.text = '0';
            setState(() {});
          }
        },
      );

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_date.text) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) _date.text = _dateString(date);
  }

  Future<Uint8List> _grnPdf(
      String grnNumber, List<_ReceiptLineForm> lines) async {
    final document = pw.Document();
    document.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (_) =>
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text('GOODS RECEIVED NOTE',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 16),
        pw.Text('GRN: $grnNumber'),
        pw.Text('Purchase: ${widget.purchase.number}'),
        pw.Text('Supplier: ${widget.purchase.supplier}'),
        pw.Text('Delivery date: ${_date.text}'),
        pw.SizedBox(height: 16),
        pw.TableHelper.fromTextArray(
          headers: const ['Item', 'Received', 'Accepted', 'Rejected'],
          data: lines
              .map((line) => [
                    line.orderLine.name,
                    '${line.received.text} ${line.orderLine.unit}',
                    '${line.accepted.text} ${line.orderLine.unit}',
                    '${line.rejected.text} ${line.orderLine.unit}',
                  ])
              .toList(),
        ),
        if (_notes.text.trim().isNotEmpty) ...[
          pw.SizedBox(height: 14),
          pw.Text('Notes: ${_notes.text.trim()}'),
        ],
      ]),
    ));
    return document.save();
  }
}

class PurchaseReturnScreen extends StatefulWidget {
  final PurchaseViewModel purchase;

  const PurchaseReturnScreen({super.key, required this.purchase});

  @override
  State<PurchaseReturnScreen> createState() => _PurchaseReturnScreenState();
}

class _PurchaseReturnScreenState extends State<PurchaseReturnScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantity = TextEditingController();
  final _reason = TextEditingController();
  final _date = TextEditingController(text: _today());
  String? _lineId;
  String? _error;
  bool _saving = false;

  List<PurchaseLineViewModel> get _receivedLines =>
      widget.purchase.items.where((line) => line.receivedQuantity > 0).toList();

  @override
  void initState() {
    super.initState();
    if (_receivedLines.isNotEmpty) _lineId = _receivedLines.first.id;
  }

  @override
  void dispose() {
    _quantity.dispose();
    _reason.dispose();
    _date.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ApiClient.instance
          .post('/purchase-orders/${widget.purchase.id}/returns', {
        'return_date': _date.text,
        'reason': _reason.text.trim(),
        'items': [
          {
            'purchase_order_item_id': _lineId,
            'quantity': double.parse(_quantity.text),
          }
        ],
      });
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      if (mounted)
        setState(() {
          _saving = false;
          _error = error.message;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Return ${widget.purchase.number}')),
      body: Form(
        key: _formKey,
        child: ListView(padding: const EdgeInsets.all(20), children: [
          Text(widget.purchase.supplier,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _lineId,
            decoration: const InputDecoration(labelText: 'Received Item'),
            items: _receivedLines
                .map((line) => DropdownMenuItem(
                    value: line.id, child: Text('${line.name} • ${line.unit}')))
                .toList(),
            onChanged: (value) => setState(() => _lineId = value),
            validator: (value) =>
                value == null ? 'Select a received item' : null,
          ),
          const SizedBox(height: 10),
          if (_lineId != null)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                  'Received quantity: ${_qty(_receivedLines.firstWhere((line) => line.id == _lineId).receivedQuantity)}'),
            ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _quantity,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Return Quantity'),
            validator: (value) {
              final number = double.tryParse(value ?? '');
              if (number == null || number <= 0)
                return 'Enter a quantity greater than zero';
              if (_lineId != null &&
                  number >
                      _receivedLines
                          .firstWhere((line) => line.id == _lineId)
                          .receivedQuantity) {
                return 'Cannot exceed the received quantity';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _date,
            readOnly: true,
            decoration: const InputDecoration(
                labelText: 'Return Date',
                suffixIcon: Icon(Icons.calendar_today)),
            onTap: () async {
              final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.tryParse(_date.text) ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100));
              if (date != null) _date.text = _dateString(date);
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _reason,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Reason for Return'),
            validator: (value) =>
                value == null || value.trim().isEmpty ? 'Enter a reason' : null,
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _saving || _receivedLines.isEmpty ? null : _submit,
            child: _saving
                ? const CircularProgressIndicator()
                : const Text('Submit Return for Review'),
          ),
        ]),
      ),
    );
  }
}

class PurchaseDetailScreen extends StatelessWidget {
  final PurchaseViewModel purchase;

  const PurchaseDetailScreen({super.key, required this.purchase});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(purchase.number)),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Text(purchase.supplier, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        _detail('Purchase Date', purchase.date),
        _detail(
            'Expected Delivery',
            purchase.expectedDelivery.isEmpty
                ? 'Not set'
                : purchase.expectedDelivery),
        _detail('Status', purchase.status),
        _detail('Payment Status', purchase.paymentStatus),
        const Divider(height: 28),
        for (final line in purchase.items)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(line.name),
            subtitle: Text(
                '${_qty(line.quantity)} ${line.unit} × ETB ${line.unitPrice.toStringAsFixed(2)}'),
            trailing: Text('ETB ${line.lineTotal.toStringAsFixed(2)}'),
          ),
        const Divider(height: 28),
        _detail('Subtotal', _money(purchase.subtotal)),
        _detail('VAT', _money(purchase.vatAmount)),
        _detail('Discount', _money(purchase.discountAmount)),
        _detail('Grand Total', _money(purchase.totalAmount), strong: true),
        if (purchase.notes.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('Notes', style: Theme.of(context).textTheme.titleMedium),
          Text(purchase.notes),
        ],
      ]),
    );
  }
}

class InvoicePreviewScreen extends StatelessWidget {
  final PurchaseViewModel purchase;

  const InvoicePreviewScreen({super.key, required this.purchase});

  Future<Uint8List> _pdfBytes() async {
    final document = pw.Document();
    document.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (context) => [
        pw.Text('PURCHASE INVOICE',
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 18),
        pw.Text('Purchase: ${purchase.number}'),
        pw.Text('Supplier: ${purchase.supplier}'),
        pw.Text('Order date: ${purchase.date}'),
        pw.Text('Expected delivery: ${purchase.expectedDelivery}'),
        pw.SizedBox(height: 18),
        pw.TableHelper.fromTextArray(
          headers: const ['Item', 'Quantity', 'Unit price', 'Total'],
          data: purchase.items
              .map((line) => [
                    line.name,
                    '${_qty(line.quantity)} ${line.unit}',
                    'ETB ${line.unitPrice.toStringAsFixed(2)}',
                    'ETB ${line.lineTotal.toStringAsFixed(2)}',
                  ])
              .toList(),
        ),
        pw.SizedBox(height: 16),
        pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('Subtotal: ${_money(purchase.subtotal)}'),
                  pw.Text('VAT: ${_money(purchase.vatAmount)}'),
                  pw.Text('Discount: ${_money(purchase.discountAmount)}'),
                  pw.SizedBox(height: 6),
                  pw.Text('Grand total: ${_money(purchase.totalAmount)}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ])),
      ],
    ));
    return document.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Invoice Preview')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Text(purchase.number, style: Theme.of(context).textTheme.headlineSmall),
        Text(purchase.supplier),
        const Divider(height: 28),
        for (final line in purchase.items)
          _detail('${line.name} • ${_qty(line.quantity)} ${line.unit}',
              _money(line.lineTotal)),
        const Divider(height: 28),
        _detail('Subtotal', _money(purchase.subtotal)),
        _detail('VAT', _money(purchase.vatAmount)),
        _detail('Discount', _money(purchase.discountAmount)),
        _detail('Grand Total', _money(purchase.totalAmount), strong: true),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: () async => Printing.sharePdf(
              bytes: await _pdfBytes(),
              filename: 'invoice-${purchase.number}.pdf'),
          icon: const Icon(Icons.download_outlined),
          label: const Text('Download PDF'),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: () async =>
              Printing.layoutPdf(onLayout: (_) => _pdfBytes()),
          icon: const Icon(Icons.print_outlined),
          label: const Text('Print'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () async => Printing.sharePdf(
              bytes: await _pdfBytes(),
              filename: 'invoice-${purchase.number}.pdf'),
          icon: const Icon(Icons.share_outlined),
          label: const Text('Share Invoice'),
        ),
      ]),
    );
  }
}

class _ReceiptLineForm {
  final PurchaseLineViewModel orderLine;
  final TextEditingController received;
  final TextEditingController accepted;
  final TextEditingController rejected = TextEditingController(text: '0');
  final TextEditingController reason = TextEditingController();
  String qualityStatus = 'Accepted';

  _ReceiptLineForm(this.orderLine)
      : received = TextEditingController(
            text: _qty(orderLine.quantity - orderLine.receivedQuantity)),
        accepted = TextEditingController(
            text: _qty(orderLine.quantity - orderLine.receivedQuantity));

  void dispose() {
    received.dispose();
    accepted.dispose();
    rejected.dispose();
    reason.dispose();
  }
}

Widget _detail(String label, String value, {bool strong = false}) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Expanded(
            child: Text(label,
                style: TextStyle(
                    fontWeight: strong ? FontWeight.w800 : FontWeight.w600))),
        Text(value,
            style: TextStyle(
                fontWeight: strong ? FontWeight.w800 : FontWeight.w600)),
      ]),
    );

String _money(double value) => 'ETB ${value.toStringAsFixed(2)}';
String _qty(double value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value.toString();
String _today() => _dateString(DateTime.now());
String _dateString(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
