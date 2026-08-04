// Generator script for stock_screen.dart
import 'dart:io';

void main() {
  final path = r'c:\Users\ruthz\Catering-Inventory-Store-Management-System\lib\screens\stock\stock_screen.dart';
  final sb = StringBuffer();

  // Imports
  sb.writeln("import 'package:flutter/material.dart';");
  sb.writeln("import '../../models/stock_models.dart';");
  sb.writeln("import '../../services/mock_repository.dart';");
  sb.writeln("import 'stock_detail_screen.dart';");
  sb.writeln("import 'stock_form_screen.dart';");
  sb.writeln("import '../../utils/responsive.dart';");
  sb.writeln();
  sb.writeln("class StockScreen extends StatefulWidget {");
  sb.writeln("  const StockScreen({super.key});");
  sb.writeln("  @override");
  sb.writeln("  State<StockScreen> createState() => _StockScreenState();");
  sb.writeln("}");
  sb.writeln();
  sb.writeln("class _StockScreenState extends State<StockScreen> with SingleTickerProviderStateMixin {");
  sb.writeln("  late final TabController _tabController;");
  sb.writeln("  String _search = '';");
  sb.writeln("  bool _showPermanent = true;");
  sb.writeln();
  sb.writeln("  @override");
  sb.writeln("  void initState() {");
  sb.writeln("    super.initState();");
  sb.writeln("    _tabController = TabController(length: 3, vsync: this);");
  sb.writeln("    _tabController.addListener(() => setState(() {}));");
  sb.writeln("  }");
  sb.writeln();
  sb.writeln("  @override");
  sb.writeln("  void dispose() {");
  sb.writeln("    _tabController.dispose();");
  sb.writeln("    super.dispose();");
  sb.writeln("  }");
  sb.writeln();
  // helpers
  sb.writeln("  Color _statusColor(String status) {");
  sb.writeln("    switch (status) {");
  sb.writeln("      case 'Healthy': return const Color(0xFF16A34A);");
  sb.writeln("      case 'Low Stock': return const Color(0xFFF59E0B);");
  sb.writeln("      case 'Out of Stock': return const Color(0xFFEF4444);");
  sb.writeln("      default: return const Color(0xFF64748B);");
  sb.writeln("    }");
  sb.writeln("  }");
  sb.writeln();
  sb.writeln("  Color _foodAccent(String cat) {");
  sb.writeln("    switch (cat) {");
  sb.writeln("      case 'Meat': return const Color(0xFFEF4444);");
  sb.writeln("      case 'Dairy': return const Color(0xFF3B82F6);");
  sb.writeln("      case 'Oil': return const Color(0xFF0F766E);");
  sb.writeln("      case 'Vegetables': return const Color(0xFF10B981);");
  sb.writeln("      case 'Dry Food': return const Color(0xFFF59E0B);");
  sb.writeln("      default: return const Color(0xFF2563EB);");
  sb.writeln("    }");
  sb.writeln("  }");
  sb.writeln();
  sb.writeln("  IconData _foodIcon(String cat) {");
  sb.writeln("    switch (cat) {");
  sb.writeln("      case 'Meat': return Icons.kebab_dining_outlined;");
  sb.writeln("      case 'Dairy': return Icons.set_meal_outlined;");
  sb.writeln("      case 'Oil': return Icons.oil_barrel_outlined;");
  sb.writeln("      case 'Vegetables': return Icons.eco_outlined;");
  sb.writeln("      case 'Dry Food': return Icons.rice_bowl_outlined;");
  sb.writeln("      default: return Icons.restaurant_outlined;");
  sb.writeln("    }");
  sb.writeln("  }");

  File(path).writeAsStringSync(sb.toString(), encoding: utf8);
  print('Part 1 written');
}
