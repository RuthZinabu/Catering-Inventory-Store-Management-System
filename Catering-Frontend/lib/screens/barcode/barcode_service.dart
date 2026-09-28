import 'dart:convert';
import 'dart:typed_data';
// import 'package:catering_inventory_store_management_system/screens/models/store_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/store_model.dart';

// Barcode types supported
enum BarcodeType {
  qrCode('QR Code'),
  code128('Code 128'),
  ean13('EAN-13'),
  upc('UPC-A');

  final String label;
  const BarcodeType(this.label);
}

// Mock repository for stock items
class StockRepository {
  static List<Map<String, dynamic>> _items = [];

  static List<Map<String, dynamic>> get items => _items;

  static void updateStock(String stockId, double quantity) {
    final index = _items.indexWhere((item) => item['id'] == stockId);
    if (index != -1) {
      _items[index]['quantity'] = quantity;
      _items[index]['updatedAt'] = DateTime.now();
    }
  }

  static Map<String, dynamic>? getItemById(String id) {
    try {
      return _items.firstWhere((item) => item['id'] == id);
    } catch (e) {
      return null;
    }
  }
}

// Barcode generation service
class BarcodeService {
  // Generate a QR code as a String (in production, use a barcode library like: flutter_qr_barcode_scanner)
  static String generateBarcode({
    required String type,
    required String data,
  }) {
    // For production, use a proper barcode generation library
    // For now, return the data with a prefix indicating the type
    switch (type) {
      case 'qr':
        return 'QR:$data';
      case 'code128':
        return 'CODE128:$data';
      case 'ean13':
        return 'EAN13:$data';
      case 'upc':
        return 'UPC:$data';
      default:
        return 'BARCODE:$data';
    }
  }

  // Generate a barcode image (in production, use a library like barcode_widget)
  static Uint8List? generateBarcodeImage({
    required String type,
    required String data,
    required double width,
    required double height,
  }) {
    // In production, use a proper barcode generation library
    // This is a placeholder - actual implementation would generate the image bytes
    return null;
  }

  // Parse scanned barcode data
  static Map<String, dynamic> parseScannedBarcode(String data) {
    // In production, parse the actual barcode format
    // For demo, we'll simulate parsing
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

    return {
      'data': data,
      'timestamp': formatter.format(now),
      'type': _detectBarcodeType(data),
      'isValid': data.isNotEmpty,
    };
  }

  static String _detectBarcodeType(String data) {
    if (data.startsWith('QR:')) return 'QR Code';
    if (data.startsWith('CODE128:')) return 'Code 128';
    if (data.startsWith('EAN13:')) return 'EAN-13';
    if (data.startsWith('UPC:')) return 'UPC-A';
    return 'Unknown';
  }
}
