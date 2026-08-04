import 'package:flutter/material.dart';
import 'barcode_service.dart';
import '../stock/food_stock_form_screen.dart';
import '../stock/catering_stock_form_screen.dart';
import '../stock/electronics_stock_form_screen.dart';
import '../../models/store_model.dart';
import '../../models/store_repository.dart';

class BarcodeManagementScreen extends StatefulWidget {
  const BarcodeManagementScreen({super.key});

  @override
  State<BarcodeManagementScreen> createState() =>
      _BarcodeManagementScreenState();
}

class _BarcodeManagementScreenState extends State<BarcodeManagementScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Barcode Management',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _BarcodeGeneratorScreen(),
          _BarcodeScannerScreen(),
          _BarcodePrintingScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF2563EB),
        unselectedItemColor: const Color(0xFF94A3B8),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner_outlined),
            label: 'Generate',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.print),
            label: 'Print',
          ),
        ],
      ),
    );
  }
}

class _BarcodeGeneratorScreen extends StatefulWidget {
  @override
  State<_BarcodeGeneratorScreen> createState() =>
      _BarcodeGeneratorScreenState();
}

class _BarcodeGeneratorScreenState extends State<_BarcodeGeneratorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _barcodeCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _storeCtrl = TextEditingController();

  BarcodeType _selectedType = BarcodeType.qrCode;
  Store? _selectedStore;

  @override
  void dispose() {
    _barcodeCtrl.dispose();
    _descriptionCtrl.dispose();
    _storeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Generate New Barcode',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 24),

            // Store selection
            DropdownButtonFormField<Store?>(
              decoration: InputDecoration(
                labelText: 'Select Store',
                prefixIcon: const Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF2563EB), width: 2),
                ),
              ),
              value: _selectedStore,
              items: (StoreRepository.stores as List<Store>).map((store) {
                return DropdownMenuItem<Store>(
                  value: store,
                  child: Text(store.name ?? ''),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedStore = value),
            ),
            const SizedBox(height: 16),

            // Barcode type selection
            DropdownButtonFormField<BarcodeType>(
              decoration: InputDecoration(
                labelText: 'Barcode Type',
                prefixIcon: const Icon(Icons.barcode_reader),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF2563EB), width: 2),
                ),
              ),
              value: _selectedType,
              items: BarcodeType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.label),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedType = value!),
            ),
            const SizedBox(height: 16),

            // Barcode data input
            TextFormField(
              controller: _barcodeCtrl,
              decoration: InputDecoration(
                labelText: 'Barcode Data',
                hintText: 'e.g., ITEM-001 or Stock ID',
                prefixIcon: const Icon(Icons.tag_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF2563EB), width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter barcode data';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionCtrl,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Item description...',
                prefixIcon: const Icon(Icons.description_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF2563EB), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Generate button
            ElevatedButton.icon(
              onPressed: _generateBarcode,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Generate Barcode'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Generated barcode preview
            if (_barcodeCtrl.text.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getIconForType(_selectedType),
                          size: 120,
                          color: const Color(0xFF2563EB),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _barcodeCtrl.text,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Print barcode
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Print function coming soon for: ${_barcodeCtrl.text}'),
                          backgroundColor: const Color(0xFF16A34A),
                        ),
                      );
                    },
                    icon: const Icon(Icons.print),
                    label: const Text('Print'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(BarcodeType type) {
    switch (type) {
      case BarcodeType.qrCode:
        return Icons.qr_code;
      case BarcodeType.code128:
        return Icons.barcode_reader;
      case BarcodeType.ean13:
        return Icons.receipt_long;
      case BarcodeType.upc:
        return Icons.shopping_cart;
    }
  }

  void _generateBarcode() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Barcode generated successfully: ${_barcodeCtrl.text}'),
          backgroundColor: const Color(0xFF16A34A),
        ),
      );
    }
  }
}

class _BarcodeScannerScreen extends StatefulWidget {
  @override
  State<_BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<_BarcodeScannerScreen> {
  final _scanController = TextEditingController();
  bool _isScanning = false;

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Scan Barcode',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 24),

          // Scanner UI
          Container(
            width: double.infinity,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isScanning
                    ? const Color(0xFF2563EB)
                    : const Color(0xFFE2E8F0),
                width: 2,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Simulated camera view
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFE0E7FF),
                        const Color(0xFFF4F6FB),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt_rounded,
                        size: 80,
                        color: const Color(0xFF94A3B8),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _isScanning ? 'Scanning...' : 'Camera Ready',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                // Scanner overlay
                Positioned(
                  top: 50,
                  left: 20,
                  right: 20,
                  bottom: 50,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF2563EB),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFF2563EB),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Manual input fallback
          TextFormField(
            controller: _scanController,
            decoration: InputDecoration(
              labelText: 'Or Enter Barcode Manually',
              prefixIcon: const Icon(Icons.qr_code_scanner),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFF2563EB), width: 2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Actions
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _startScan,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: Text(_isScanning ? 'Stop Scanning' : 'Start Scanning'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isScanning
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Scanned result
          if (_scanController.text.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Scanned Result',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Barcode',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: const Color(0xFF64748B)),
                          ),
                          Text(
                            BarcodeService.parseScannedBarcode(
                                _scanController.text)['data'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Timestamp',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: const Color(0xFF64748B)),
                          ),
                          Text(
                            BarcodeService.parseScannedBarcode(
                                _scanController.text)['timestamp'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Type',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: const Color(0xFF64748B)),
                          ),
                          Text(
                            BarcodeService.parseScannedBarcode(
                                _scanController.text)['type'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Quick stock update
                ElevatedButton.icon(
                  onPressed: _showQuickUpdateSheet,
                  icon: const Icon(Icons.update),
                  label: const Text('Quick Stock Update'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _startScan() {
    setState(() => _isScanning = !_isScanning);
    if (_isScanning) {
      // Simulate scanning after delay
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _scanController.text =
              'QR:ITEM-001-${DateTime.now().millisecondsSinceEpoch}';
          _isScanning = false;
        });
      });
    }
  }

  void _showQuickUpdateSheet() {
    final TextEditingController quantityCtrl = TextEditingController();
    String selectedStore =
        StoreRepository.stores.isNotEmpty ? StoreRepository.stores[0].name : '';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).padding.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Stock Update',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 24),

            // Store selection
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Select Store',
                prefixIcon: const Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              value: selectedStore,
              items: StoreRepository.stores.map((store) {
                return DropdownMenuItem(
                  value: store.name,
                  child: Text(store.name),
                );
              }).toList(),
              onChanged: (value) => setState(() => selectedStore = value!),
            ),
            const SizedBox(height: 16),

            // Quantity input
            TextFormField(
              controller: quantityCtrl,
              decoration: InputDecoration(
                labelText: 'New Quantity',
                hintText: 'Enter quantity',
                prefixIcon: const Icon(Icons.inventory_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (quantityCtrl.text.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Stock updated to ${quantityCtrl.text}'),
                            backgroundColor: const Color(0xFF16A34A),
                          ),
                        );
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Update'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BarcodePrintingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Print Barcodes',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 24),

          // Print settings
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Print Settings',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),

                // Paper size
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Paper Size',
                    prefixIcon: const Icon(Icons.print_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFF2563EB), width: 2),
                    ),
                  ),
                  value: 'A4',
                  items:
                      const ['A4', 'A5', 'Label 1x1', 'Label 2x4'].map((size) {
                    return DropdownMenuItem(value: size, child: Text(size));
                  }).toList(),
                  onChanged: (String? value) {},
                ),
                const SizedBox(height: 16),

                // Print quantity
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    prefixIcon: const Icon(Icons.numbers_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFF2563EB), width: 2),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: '1'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Print preview
          Text(
            'Recent Prints',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),

          if (StoreRepository.stores.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Icon(
                    Icons.print_rounded,
                    size: 64,
                    color: const Color(0xFF94A3B8),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No barcodes to print yet',
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
