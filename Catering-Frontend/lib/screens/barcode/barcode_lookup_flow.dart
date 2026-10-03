import 'package:flutter/material.dart';

import '../../models/inventory_models.dart';
import '../../services/api_repository.dart';
import '../inventory_create_screen.dart';
import '../inventory_detail_screen.dart';
import 'barcode_scanner_page.dart';
import 'scan_result.dart';

enum _LookupChoice { scanAgain, addProduct }

class BarcodeLookupFlow {
  const BarcodeLookupFlow._();

  static Future<void> lookupValue(BuildContext context, String rawValue) async {
    final value = rawValue.trim();
    if (value.isEmpty) return;

    final items = await _search(context, value);
    if (items == null || !context.mounted) return;
    if (items.isNotEmpty) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => InventoryDetailScreen(item: items.first),
        ),
      );
      return;
    }

    final choice = await _showNotFound(context, value);
    if (!context.mounted) return;
    if (choice == _LookupChoice.scanAgain) {
      await start(context);
    } else if (choice == _LookupChoice.addProduct) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => InventoryCreateScreen(initialBarcode: value),
        ),
      );
    }
  }

  static Future<void> start(BuildContext context) async {
    while (context.mounted) {
      final result = await Navigator.of(context).push<ScanResult>(
        MaterialPageRoute(builder: (_) => const BarcodeScannerPage()),
      );
      if (result == null || !context.mounted) return;

      final items = await _search(context, result.value);
      if (items == null) return;
      if (!context.mounted) return;
      if (items.isNotEmpty) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => InventoryDetailScreen(item: items.first),
          ),
        );
        return;
      }

      final choice = await _showNotFound(context, result.value);

      if (choice == _LookupChoice.scanAgain) continue;
      if (choice == _LookupChoice.addProduct && context.mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => InventoryCreateScreen(initialBarcode: result.value),
          ),
        );
      }
      return;
    }
  }

  static Future<List<InventoryItem>?> _search(
    BuildContext context,
    String value,
  ) async {
    while (context.mounted) {
      try {
        return await ApiRepository.instance.searchInventoryItems(value);
      } catch (_) {
        if (!context.mounted) return null;
        final retry = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Lookup unavailable'),
            content: const Text(
              'The inventory could not be checked. Check your connection and try again.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
        if (retry != true) return null;
      }
    }
    return null;
  }

  static Future<_LookupChoice?> _showNotFound(
    BuildContext context,
    String value,
  ) {
    return showDialog<_LookupChoice>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Product not found'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('No inventory item matches this barcode:'),
            const SizedBox(height: 8),
            SelectableText(value,
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext)
                .pop(_LookupChoice.scanAgain),
            child: const Text('Scan Again'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext)
                .pop(_LookupChoice.addProduct),
            child: const Text('Add Product'),
          ),
        ],
      ),
    );
  }

}