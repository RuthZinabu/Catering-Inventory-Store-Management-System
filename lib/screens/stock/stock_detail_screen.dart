import 'package:flutter/material.dart';
import '../../models/stock_models.dart';
import '../../services/mock_repository.dart';
import 'stock_history_screen.dart';
import 'stock_form_screen.dart';

class StockDetailScreen extends StatelessWidget {
  final StockItem item;
  const StockDetailScreen({super.key, required this.item});

