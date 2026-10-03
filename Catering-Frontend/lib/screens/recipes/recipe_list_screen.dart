import 'package:catering_inventory_store_management_system/widgets/search_bar.dart';
import 'package:flutter/material.dart';

import '../../models/inventory_models.dart';
import '../../services/api_repository.dart';
import 'recipe_detail_screen.dart';
import 'recipe_create_screen.dart';

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({super.key});

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  String searchQuery = '';
  String selectedCategory = 'All';
  List<RecipeItem> _allRecipes = [];
  bool _isLoading = true;
  String? _error;

  final List<String> categories = const [
    'All',
    'Main Course',
    'Dessert',
    'Beverage',
    'Appetizer',
    'Salad',
    'Soup',
  ];

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final recipes = await ApiRepository.instance.getRecipeItems();
      if (mounted) {
        setState(() {
          _allRecipes = recipes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  List<RecipeItem> get _filtered => _allRecipes.where((r) {
        final matchCat =
            selectedCategory == 'All' || r.category == selectedCategory;
        final matchSearch = searchQuery.isEmpty ||
            r.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            r.category.toLowerCase().contains(searchQuery.toLowerCase());
        return matchCat && matchSearch;
      }).toList();

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 70),
          child: FloatingActionButton.extended(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RecipeCreateScreen()),
              );
              _loadRecipes(); // Reload after creating
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('New Recipe'),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Recipe Management',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.6),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                      style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.all(10)),
                    ),
                  ],
                ),
              ),
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 70),
          child: FloatingActionButton.extended(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RecipeCreateScreen()),
              );
              _loadRecipes(); // Reload after creating
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('New Recipe'),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Recipe Management',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.6),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                      style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.all(10)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadRecipes,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final filtered = _filtered;
    final activeCount = filtered.where((r) => r.status == 'Active').length;
    final totalServings = filtered.fold<int>(0, (s, r) => s + r.servings);
    final avgCostPct = filtered.isEmpty
        ? 0.0
        : filtered.fold<double>(0, (s, r) => s + r.foodCostPercentage) /
            filtered.length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70),
        child: FloatingActionButton.extended(
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const RecipeCreateScreen()),
            );
            _loadRecipes(); // Reload after creating
          },
          icon: const Icon(Icons.add_rounded),
          label: const Text('New Recipe'),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Recipes',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.6,
                                ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_rounded),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.all(10),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Manage dish recipes, ingredient breakdowns and food costing.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontSize: 14.5),
                    ),
                    const SizedBox(height: 16),
                    // Search bar
                    CateringSearch(
                      hintText: 'Search recipies...',
                      onChanged: (value) {
                        setState(() => searchQuery = value);
                      },
                    ),
                    const SizedBox(height: 14),
                    // Category chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: categories.map((cat) {
                          final isSelected = cat == selectedCategory;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(cat),
                              selected: isSelected,
                              onSelected: (_) =>
                                  setState(() => selectedCategory = cat),
                              selectedColor: const Color(0xFFDCFCE7),
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? const Color(0xFF16A34A)
                                    : const Color(0xFF475569),
                                fontWeight: FontWeight.w600,
                              ),
                              side: BorderSide.none,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Summary cards
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _summaryCard(
                            'Active Recipes',
                            '$activeCount',
                            const Color(0xFF16A34A),
                            Icons.restaurant_menu_rounded),
                        _summaryCard('Total Servings', '$totalServings',
                            const Color(0xFF2563EB), Icons.people_rounded),
                        _summaryCard(
                            'Avg Food Cost',
                            '${avgCostPct.toStringAsFixed(1)}%',
                            const Color(0xFFF59E0B),
                            Icons.percent_rounded),
                        _summaryCard('Total Recipes', '${filtered.length}',
                            const Color(0xFF8B5CF6), Icons.menu_book_rounded),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 112),
              sliver: filtered.isEmpty
                  ? SliverToBoxAdapter(child: _emptyState())
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            _recipeCard(context, filtered[index]),
                        childCount: filtered.length,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _recipeCard(BuildContext context, RecipeItem recipe) {
    final costColor = recipe.foodCostPercentage > 40
        ? const Color(0xFFEF4444)
        : recipe.foodCostPercentage > 30
            ? const Color(0xFFF59E0B)
            : const Color(0xFF16A34A);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 18,
              offset: const Offset(0, 10))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => RecipeDetailScreen(recipe: recipe))),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(Icons.restaurant_menu_rounded,
                          color: Color(0xFF16A34A), size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  recipe.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 5),
                                decoration: BoxDecoration(
                                  color: (recipe.status == 'Active'
                                          ? const Color(0xFF16A34A)
                                          : const Color(0xFF64748B))
                                      .withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  recipe.status,
                                  style: TextStyle(
                                    color: recipe.status == 'Active'
                                        ? const Color(0xFF16A34A)
                                        : const Color(0xFF64748B),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 6,
                            runSpacing: 5,
                            children: [
                              _infoChip(recipe.category),
                              _infoChip('${recipe.servings} servings'),
                              _infoChip(recipe.prepTime),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  recipe.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _infoChip(
                              'Food Cost: ETB ${recipe.totalFoodCost.toStringAsFixed(0)}'),
                          _infoChip(
                              'Sell: ETB ${recipe.sellingPrice.toStringAsFixed(0)}'),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: costColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${recipe.foodCostPercentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                            color: costColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _summaryCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      width: MediaQuery.of(context).size.width > 360 ? 162 : 148,
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
            width: 38,
            height: 38,
            decoration: BoxDecoration(
                color: color.withOpacity(0.14),
                borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 12)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        color: Color(0xFF64748B), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(999)),
      child: Text(value,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155))),
    );
  }

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 14,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.restaurant_menu_rounded,
              size: 44, color: Color(0xFF64748B)),
          const SizedBox(height: 8),
          Text('No recipes found',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Add your first recipe to get started.',
              style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
