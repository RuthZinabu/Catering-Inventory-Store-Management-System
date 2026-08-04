import 'package:flutter/material.dart';
import '../../models/stock_models.dart';

// Status color
Color stockStatusColor(String status) {
  switch (status) {
    case 'Healthy':
      return const Color(0xFF16A34A);
    case 'Low Stock':
      return const Color(0xFFF59E0B);
    case 'Out of Stock':
      return const Color(0xFFEF4444);
    default:
      return const Color(0xFF64748B);
  }
}

// Accent color for any StockItem
Color stockAccentColor(StockItem item) {
  if (item is FoodStockItem) {
    switch (item.category) {
      case 'Meat':
        return const Color(0xFFEF4444);
      case 'Dairy':
        return const Color(0xFF3B82F6);
      case 'Oil':
        return const Color(0xFF0F766E);
      case 'Vegetables':
        return const Color(0xFF10B981);
      case 'Dry Food':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF2563EB);
    }
  }
  if (item is CateringStockItem) {
    return item.subtype == CateringSubtype.permanent
        ? const Color(0xFF7C3AED)
        : const Color(0xFFF59E0B);
  }
  return const Color(0xFF0369A1);
}

// Icon for food category
IconData foodCategoryIcon(String category) {
  switch (category) {
    case 'Meat':
      return Icons.kebab_dining_outlined;
    case 'Dairy':
      return Icons.set_meal_outlined;
    case 'Oil':
      return Icons.oil_barrel_outlined;
    case 'Vegetables':
      return Icons.eco_outlined;
    case 'Dry Food':
      return Icons.rice_bowl_outlined;
    default:
      return Icons.restaurant_outlined;
  }
}

// Shared info chip widget
Widget infoChip(String label, {Color? bgColor, Color? textColor}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: bgColor ?? const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: textColor ?? const Color(0xFF334155),
      ),
    ),
  );
}

// Status badge
Widget statusBadge(String status) {
  final color = stockStatusColor(status);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      status,
      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
    ),
  );
}

// Section title
Widget sectionTitle(BuildContext context, String title) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF10162B),
            ),
      ),
    );

// Detail row
Widget detailRow(String label, String value) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                      fontSize: 13))),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: Color(0xFF10162B))),
        ],
      ),
    );
