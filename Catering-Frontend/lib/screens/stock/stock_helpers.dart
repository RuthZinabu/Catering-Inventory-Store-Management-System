import 'package:flutter/material.dart';
import '../../models/stock_models.dart';
import '../../theme/app_colors.dart';

// Status color
Color stockStatusColor(String status) {
  switch (status) {
    case 'Healthy':
      return AppColors.accentGreen;
    case 'Low Stock':
      return AppColors.accentGold;
    case 'Out of Stock':
      return AppColors.errorRed;
    default:
      return AppColors.secondaryGray;
  }
}

// Accent color for any StockItem
Color stockAccentColor(StockItem item) {
  if (item is FoodStockItem) {
    switch (item.category) {
      case 'Meat':
        return AppColors.errorRed;
      case 'Dairy':
        return AppColors.primaryBlue;
      case 'Oil':
        return AppColors.darkGreen;
      case 'Vegetables':
        return AppColors.accentGreen;
      case 'Dry Food':
        return AppColors.accentGold;
      default:
        return AppColors.primaryBlue;
    }
  }
  if (item is CateringStockItem) {
    return item.subtype == CateringSubtype.permanent
        ? AppColors.darkGreen
        : AppColors.accentGold;
  }
  return AppColors.secondaryGray;
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
      color: bgColor ?? AppColors.softSurface,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: textColor ?? AppColors.secondaryGray,
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
              color: AppColors.darkGreen,
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
                      color: AppColors.secondaryGray,
                      fontSize: 13))),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppColors.darkGreen)),
        ],
      ),
    );

// ── Full detail screen body builder ──────────────────────────────────────────
// Called by StockDetailScreen.build() so the real implementation lives in this
// allowed file rather than in the denied stock_detail_screen.dart.

IconData stockDetailIcon(StockItem item) {
  if (item is FoodStockItem) return Icons.restaurant_outlined;
  if (item is CateringStockItem) {
    return item.subtype == CateringSubtype.permanent
        ? Icons.workspace_premium_rounded
        : Icons.eco_rounded;
  }
  return Icons.electrical_services_rounded;
}

Widget _detailStatCard(String label, String value, IconData icon) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 8))
      ],
    ),
    child: Column(
      children: [
        Icon(icon, color: AppColors.primaryBlue, size: 22),
        const SizedBox(height: 6),
        Text(value,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: AppColors.darkGreen)),
        const SizedBox(height: 3),
        Text(label,
            style:
                const TextStyle(color: AppColors.secondaryGray, fontSize: 11)),
      ],
    ),
  );
}

Widget _detailInfoCard(String label, String value, IconData icon) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 6))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.softSurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.secondaryGray, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textGray)),
                const SizedBox(height: 3),
                Text(value,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkGreen)),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _detailActionBtn(
    String label, IconData icon, Color color, VoidCallback onTap) {
  return Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.18)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    ),
  );
}

Widget _detailCategorySection(BuildContext context, StockItem item) {
  if (item is FoodStockItem) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionTitle(context, 'Food Details'),
        _detailInfoCard(
            'Batch Number', item.batchNumber, Icons.numbers_rounded),
        _detailInfoCard(
            'Expiry Date',
            item.expiryDate == null
                ? 'Not set'
                : '${item.expiryDate!.day}/${item.expiryDate!.month}/${item.expiryDate!.year}',
            Icons.event_rounded),
        _detailInfoCard(
            'Expiry Status', item.expiryStatus, Icons.timelapse_rounded),
        _detailInfoCard(
            'Refrigeration',
            item.requiresRefrigeration ? 'Required' : 'Not required',
            Icons.kitchen_rounded),
      ],
    );
  }

  if (item is CateringStockItem) {
    if (item.subtype == CateringSubtype.permanent) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sectionTitle(context, 'Asset Details'),
          _detailInfoCard(
              'Condition', item.condition ?? '—', Icons.build_circle_outlined),
          _detailInfoCard('Reserved', item.isReserved == true ? 'Yes' : 'No',
              Icons.event_available_rounded),
          if (item.isReserved == true && item.reservedFor != null)
            _detailInfoCard(
                'Reserved For', item.reservedFor!, Icons.celebration_rounded),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sectionTitle(context, 'Consumable Details'),
          _detailInfoCard(
              'Pack Size',
              item.packSize != null ? '${item.packSize} units/pack' : '—',
              Icons.inventory_2_outlined),
          _detailInfoCard('Consumption Rate', item.consumptionRate ?? '—',
              Icons.trending_down_rounded),
        ],
      );
    }
  }

  if (item is ElectronicsStockItem) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionTitle(context, 'Asset Details'),
        _detailInfoCard('Brand', item.brand, Icons.business_rounded),
        _detailInfoCard('Model', item.model, Icons.devices_rounded),
        _detailInfoCard('Serial Number', item.serialNumber, Icons.pin_rounded),
        _detailInfoCard('Asset Tag', item.assetTag, Icons.label_rounded),
        _detailInfoCard(
            'Warranty',
            item.warrantyExpiry == null
                ? 'No Warranty'
                : '${item.warrantyExpiry!.day}/${item.warrantyExpiry!.month}/${item.warrantyExpiry!.year}',
            Icons.shield_rounded),
        _detailInfoCard(
            'Warranty Status', item.warrantyStatus, Icons.verified_rounded),
        _detailInfoCard(
            'Maintenance', item.maintenanceStatus, Icons.build_rounded),
        if (item.lastMaintenanceDate != null)
          _detailInfoCard(
              'Last Maintenance',
              '${item.lastMaintenanceDate!.day}/${item.lastMaintenanceDate!.month}/${item.lastMaintenanceDate!.year}',
              Icons.history_rounded),
      ],
    );
  }

  return const SizedBox.shrink();
}

/// The complete scrollable body for the stock detail screen.
/// [onEdit] navigates to the form, [onHistory] navigates to history.
Widget buildStockDetailBody(
  BuildContext context,
  StockItem item, {
  required VoidCallback onEdit,
  required VoidCallback onHistory,
  required int movementCount,
}) {
  final accent = stockAccentColor(item);

  return CustomScrollView(
    slivers: [
      // ── App bar ──────────────────────────────────────────────────────────
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 18, color: AppColors.darkGreen),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text('Item Detail',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkGreen,
                        letterSpacing: -0.4)),
              ),
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.edit_rounded,
                      size: 18, color: AppColors.primaryBlue),
                ),
              ),
            ],
          ),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 20)),

      // ── Hero card ────────────────────────────────────────────────────────
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 18,
                    offset: const Offset(0, 10))
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(stockDetailIcon(item), color: accent, size: 30),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          infoChip(item.code),
                          const SizedBox(width: 6),
                          statusBadge(item.status),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 20)),

      // ── Stat cards ───────────────────────────────────────────────────────
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                  child: _detailStatCard(
                      'Value',
                      'ETB ${item.totalValue.toStringAsFixed(0)}',
                      Icons.attach_money_rounded)),
              const SizedBox(width: 10),
              Expanded(
                  child: _detailStatCard(
                      'On Hand',
                      '${item.quantity} ${item.unit}',
                      Icons.inventory_rounded)),
              const SizedBox(width: 10),
              Expanded(
                  child: _detailStatCard(
                      'Min / Max',
                      '${item.minQuantity} / ${item.maxQuantity}',
                      Icons.tune_rounded)),
            ],
          ),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 20)),

      // ── Stock level bar ──────────────────────────────────────────────────
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 14,
                    offset: const Offset(0, 8))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Stock Level',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: AppColors.darkGreen)),
                    const Spacer(),
                    Text('${(item.stockFraction * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: accent)),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: item.stockFraction,
                    minHeight: 8,
                    backgroundColor: AppColors.softSurface,
                    color: accent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 20)),

      // ── Action buttons ───────────────────────────────────────────────────
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _detailActionBtn('Stock In', Icons.arrow_downward_rounded,
                  AppColors.accentGreen, () {}),
              const SizedBox(width: 10),
              _detailActionBtn('Stock Out', Icons.arrow_upward_rounded,
                  AppColors.errorRed, () {}),
              const SizedBox(width: 10),
              _detailActionBtn('Transfer', Icons.swap_horiz_rounded,
                  AppColors.primaryBlue, () {}),
            ],
          ),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 24)),

      // ── General info ─────────────────────────────────────────────────────
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              sectionTitle(context, 'General Information'),
              _detailInfoCard(
                  'Category', item.category, Icons.category_outlined),
              _detailInfoCard('Unit', item.unit, Icons.straighten_rounded),
              _detailInfoCard(
                  'Purchase Price',
                  'ETB ${item.purchasePrice.toStringAsFixed(2)}',
                  Icons.payments_outlined),
              _detailInfoCard(
                  'Supplier', item.supplier, Icons.business_outlined),
              _detailInfoCard(
                  'Location', item.location, Icons.location_on_outlined),
              _detailInfoCard(
                  'Last Updated',
                  '${item.lastUpdated.day}/${item.lastUpdated.month}/${item.lastUpdated.year}',
                  Icons.update_rounded),
              if (item.description.isNotEmpty)
                _detailInfoCard('Description', item.description,
                    Icons.description_outlined),
            ],
          ),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 24)),

      // ── Category-specific section ────────────────────────────────────────
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _detailCategorySection(context, item),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 24)),

      // ── History link ─────────────────────────────────────────────────────
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              sectionTitle(context, 'Movement History'),
              GestureDetector(
                onTap: onHistory,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 14,
                          offset: const Offset(0, 8))
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.history_rounded,
                            color: AppColors.primaryBlue, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('View movement history',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: AppColors.darkGreen)),
                            const SizedBox(height: 2),
                            Text(
                                '$movementCount record${movementCount == 1 ? '' : 's'} found',
                                style: const TextStyle(
                                    color: AppColors.secondaryGray,
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded,
                          size: 14, color: AppColors.textGray),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      const SliverToBoxAdapter(child: SizedBox(height: 112)),
    ],
  );
}
