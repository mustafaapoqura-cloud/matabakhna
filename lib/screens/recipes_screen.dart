import 'package:flutter/material.dart';
import 'package:matebakhna/screens/widget/app_bar.dart';

import '../models/recipe.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';
import 'add_recipe_screen.dart';

class RecipesScreen extends StatefulWidget {
  final RecipeCategory? initialCategory;

  const RecipesScreen({super.key, this.initialCategory});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  RecipeCategory? _selectedCategory;
  CostTier? _selectedCostTier;
  String _searchQuery = '';

  final TextEditingController _searchController = TextEditingController();
  List<Recipe> _allRecipes = [];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _allRecipes = StorageService.getAllRecipes();
  }

  void _loadRecipes() {
    final recipes = StorageService.getAllRecipes();
    if (!mounted) return;

    setState(() {
      _allRecipes = recipes;
    });
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _selectedCategory = null;
      _selectedCostTier = null;
    });
  }

  Future<void> _addRecipe() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddRecipeScreen(),
      ),
    );

    if (result == true) _loadRecipes();
  }

  List<Recipe> get _filteredRecipes {
    final query = _searchQuery.toLowerCase();

    return _allRecipes.where((recipe) {
      if (_selectedCategory != null &&
          recipe.category != _selectedCategory) {
        return false;
      }

      if (_selectedCostTier != null &&
          recipe.costTier != _selectedCostTier) {
        return false;
      }

      if (query.isNotEmpty) {
        final matchesName = recipe.name.toLowerCase().contains(query);
        final matchesDescription =
            recipe.description.toLowerCase().contains(query);
        final matchesIngredients = recipe.ingredients.any(
          (ingredient) => ingredient.name.toLowerCase().contains(query),
        );

        if (!matchesName &&
            !matchesDescription &&
            !matchesIngredients) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredRecipes;
    final hasFilters = _searchQuery.isNotEmpty ||
        _selectedCategory != null ||
        _selectedCostTier != null;

    return Scaffold(
      appBar: CustomAppBar.batbakhnaBar(
        context: context,
        title: 'دليل وصفات طبختنا',
        wid: IconButton(
          onPressed: _addRecipe,
          tooltip: 'إضافة وصفة جديدة',
          icon: const Icon(
            Icons.add_circle_rounded,
            color: AppTheme.primary,
            size: 30,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() => _searchQuery = value.trim());
                },
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'بتدوري على أكلة إيه النهارده؟',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppTheme.primary,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          tooltip: 'مسح البحث',
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                          icon: const Icon(Icons.close_rounded),
                        )
                      : null,
                  filled: true,
                  fillColor: AppTheme.primary.withAlpha(12),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(
                      color: AppTheme.borderLight,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(
                      color: AppTheme.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),

            // Category heading
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(
                    Icons.restaurant_menu_rounded,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'اختاري القسم',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  if (hasFilters)
                    TextButton(
                      onPressed: _clearFilters,
                      child: const Text(
                        'مسح الفلاتر',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Categories
            SizedBox(
              height: 46,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _categoryChip(
                    label: '🍽️ كل الأكلات',
                    selected: _selectedCategory == null,
                    onSelected: () {
                      setState(() => _selectedCategory = null);
                    },
                  ),
                  ...RecipeCategory.values.map((category) {
                    return _categoryChip(
                      label: '${category.emoji} ${category.label}',
                      selected: _selectedCategory == category,
                      onSelected: () {
                        setState(() {
                          _selectedCategory =
                              _selectedCategory == category
                                  ? null
                                  : category;
                        });
                      },
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Budget filters
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'على قد ميزانيتك',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            SizedBox(
              height: 42,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _costChip(
                    label: 'الكل',
                    selected: _selectedCostTier == null,
                    onSelected: () {
                      setState(() => _selectedCostTier = null);
                    },
                  ),
                  ...CostTier.values.map((tier) {
                    return _costChip(
                      label: '${tier.icon} ${tier.label}',
                      selected: _selectedCostTier == tier,
                      onSelected: () {
                        setState(() {
                          _selectedCostTier =
                              _selectedCostTier == tier ? null : tier;
                        });
                      },
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Results heading
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text(
                    'وصفات ليكي ❤️',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withAlpha(18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${filtered.length} وصفة',
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Recipe results
            Expanded(
              child: filtered.isEmpty
                  ? _emptyState(hasFilters: hasFilters)
                  : RefreshIndicator(
                      color: AppTheme.primary,
                      onRefresh: () async => _loadRecipes(),
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final recipe = filtered[index];

                          return RecipeCard(
                            recipe: recipe,
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      RecipeDetailScreen(recipe: recipe),
                                ),
                              );
                              _loadRecipes();
                            },
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryChip({
    required String label,
    required bool selected,
    required VoidCallback onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        showCheckmark: false,
        selected: selected,
        onSelected: (_) => onSelected(),
        label: Text(label),
        labelStyle: TextStyle(
          color: selected ? Colors.white : AppTheme.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.white,
        selectedColor: AppTheme.primary,
        side: BorderSide(
          color: selected ? AppTheme.primary : AppTheme.borderLight,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  Widget _costChip({
    required String label,
    required bool selected,
    required VoidCallback onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        selected: selected,
        onSelected: (_) => onSelected(),
        label: Text(label),
        labelStyle: TextStyle(
          color: selected ? Colors.white : AppTheme.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.white,
        selectedColor: AppTheme.primary,
        side: BorderSide(
          color: selected ? AppTheme.primary : AppTheme.borderLight,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _emptyState({required bool hasFilters}) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primary.withAlpha(15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.soup_kitchen_rounded,
                size: 58,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              hasFilters
                  ? 'ملقيناش وصفة مناسبة 🥹'
                  : 'لسه مفيش وصفات!',
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilters
                  ? 'جربي كلمات بحث مختلفة أو اختاري قسم تاني.'
                  : 'ابدئي رحلتك في المطبخ وضيفي أول وصفة ليكي!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 20),
            if (hasFilters)
              OutlinedButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.filter_alt_off_rounded),
                label: const Text('مسح كل الفلاتر'),
              )
            else
              FilledButton.icon(
                onPressed: _addRecipe,
                icon: const Icon(Icons.add_rounded),
                label: const Text('ضيفي أول وصفة'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}