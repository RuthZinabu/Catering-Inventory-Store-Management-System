import 'package:flutter/material.dart';

import '../../models/inventory_models.dart';
import 'recipe_create_screen.dart';

class RecipeDetailScreen extends StatelessWidget {
  final RecipeItem recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final costColor = recipe.foodCostPercentage > 40
        ? const Color(0xFFEF4444)
        : recipe.foodCostPercentage > 30
            ? const Color(0xFFF59E0B)
            : const Color(0xFF16A34A);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_rounded),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.all(10),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            recipe.name,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => RecipeCreateScreen(
                                    isEditing: true, recipe: recipe),
                              ));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Recipe exported.')),
                              );
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'edit', child: Text('Edit Recipe')),
                            PopupMenuItem(value: 'export', child: Text('Export / Print')),
                          ],
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10)
                              ],
                            ),
                            child: const Icon(Icons.more_horiz_rounded,
                                color: Color(0xFF64748B)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // Hero banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFF16A34A), Color(0xFF059669)]),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.green.withOpacity(0.2),
                              blurRadius: 24,
                              offset: const Offset(0, 14))
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(Icons.restaurant_menu_rounded,
                                color: Colors.white, size: 32),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(recipe.name,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 18)),
                                const SizedBox(height: 4),
                                Text(
                                    '${recipe.category} • ${recipe.servings} servings • ${recipe.prepTime}',
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.85),
                                        fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Cost breakdown cards
                    Row(
                      children: [
                        Expanded(
                            child: _metricCard('Food Cost',
                                'ETB ${recipe.totalFoodCost.toStringAsFixed(0)}',
                                const Color(0xFF2563EB),
                                Icons.shopping_basket_rounded)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _metricCard(
                                'Selling Price',
                                'ETB ${recipe.sellingPrice.toStringAsFixed(0)}',
                                const Color(0xFF16A34A),
                                Icons.sell_rounded)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _metricCard(
                                'Cost %',
                                '${recipe.foodCostPercentage.toStringAsFixed(1)}%',
                                costColor,
                                Icons.percent_rounded)),
                      ],
                    ),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Description
                  _sectionCard(
                    context,
                    title: 'Description',
                    icon: Icons.info_outline_rounded,
                    child: Text(recipe.description,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ),
                  const SizedBox(height: 14),
                  // Ingredients
                  _sectionCard(
                    context,
                    title: 'Ingredients (${recipe.ingredients.length})',
                    icon: Icons.list_alt_rounded,
                    child: Column(
                      children: [
                        // header
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: const [
                              Expanded(
                                  flex: 3,
                                  child: Text('Ingredient',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                          color: Color(0xFF64748B)))),
                              Expanded(
                                  flex: 2,
                                  child: Text('Qty',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                          color: Color(0xFF64748B)))),
                              Expanded(
                                  flex: 2,
                                  child: Text('Cost',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                          color: Color(0xFF64748B)))),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        const SizedBox(height: 8),
                        ...recipe.ingredients.map((ing) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                children: [
                                  Expanded(
                                      flex: 3,
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 28,
                                            height: 28,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFDCFCE7),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                                Icons.eco_rounded,
                                                color: Color(0xFF16A34A),
                                                size: 14),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(ing.name,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13)),
                                          ),
                                        ],
                                      )),
                                  Expanded(
                                      flex: 2,
                                      child: Text(
                                          '${ing.quantity} ${ing.unit}',
                                          style: const TextStyle(
                                              color: Color(0xFF64748B),
                                              fontSize: 13))),
                                  Expanded(
                                      flex: 2,
                                      child: Text(
                                          'ETB ${ing.totalCost.toStringAsFixed(0)}',
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13))),
                                ],
                              ),
                            )),
                        const Divider(height: 1),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Expanded(
                              flex: 5,
                              child: Text('Total Food Cost',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14)),
                            ),
                            Text(
                                'ETB ${recipe.totalFoodCost.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: Color(0xFF2563EB))),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Cost analysis
                  _sectionCard(
                    context,
                    title: 'Cost Analysis',
                    icon: Icons.analytics_rounded,
                    child: Column(
                      children: [
                        _analysisRow('Food Cost per Serving',
                            'ETB ${(recipe.totalFoodCost / recipe.servings).toStringAsFixed(2)}'),
                        _analysisRow('Selling Price per Serving',
                            'ETB ${(recipe.sellingPrice / recipe.servings).toStringAsFixed(2)}'),
                        _analysisRow(
                            'Gross Profit',
                            'ETB ${(recipe.sellingPrice - recipe.totalFoodCost).toStringAsFixed(2)}'),
                        _analysisRow(
                            'Food Cost %',
                            '${recipe.foodCostPercentage.toStringAsFixed(1)}%',
                            valueColor: costColor),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: (recipe.foodCostPercentage / 100).clamp(0.0, 1.0),
                            minHeight: 8,
                            backgroundColor: const Color(0xFFF1F5F9),
                            color: costColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('0%',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall),
                            Text('Target ≤30%',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(fontWeight: FontWeight.w600)),
                            Text('100%',
                                style:
                                    Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricCard(String title, String value, Color color, IconData icon) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 14, color: color)),
          const SizedBox(height: 2),
          Text(title,
              style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _sectionCard(BuildContext context,
      {required String title,
      required IconData icon,
      required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF16A34A), size: 20),
              const SizedBox(width: 8),
              Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _analysisRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                      fontSize: 13))),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: valueColor ?? const Color(0xFF10162B))),
        ],
      ),
    );
  }
}
