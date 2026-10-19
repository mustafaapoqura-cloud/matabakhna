import 'package:flutter/material.dart';
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
    _loadRecipes();
  }

  void _loadRecipes() {
    setState(() {
      _allRecipes = StorageService.getAllRecipes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Recipe> get _filteredRecipes {
    return _allRecipes.where((recipe) {
      // Category filter
      if (_selectedCategory != null && recipe.category != _selectedCategory) {
        return false;
      }
      // Cost Tier filter
      if (_selectedCostTier != null && recipe.costTier != _selectedCostTier) {
        return false;
      }
      // Search query filter (search by name, description or ingredient)
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesName = recipe.name.toLowerCase().contains(query);
        final matchesDesc = recipe.description.toLowerCase().contains(query);
        final matchesIng = recipe.ingredients
            .any((ing) => ing.name.toLowerCase().contains(query));
        if (!matchesName && !matchesDesc && !matchesIng) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredRecipes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('دليل وصفات طبختنا'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.primary),
            tooltip: 'إضافة وصفة جديدة',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddRecipeScreen()),
              );
              if (result == true) {
                _loadRecipes();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim();
                });
              },
              decoration: InputDecoration(
                hintText: 'ابحثي عن أكلة، مكون، أو حلوى...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Categories Horizontal List
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: const Text('كل الأقسام 🍽️'),
                    selected: _selectedCategory == null,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = null;
                      });
                    },
                    selectedColor: AppTheme.primary,
                    labelStyle: TextStyle(
                      color: _selectedCategory == null ? Colors.white : AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    checkmarkColor: Colors.white,
                  ),
                ),
                ...RecipeCategory.values.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      label: Text('${cat.emoji} ${cat.label}'),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = selected ? cat : null;
                        });
                      },
                      selectedColor: AppTheme.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      checkmarkColor: Colors.white,
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // Cost Tier Sub-Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text(
                  'المستوى: ',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                const SizedBox(width: 4),
                ChoiceChip(
                  label: const Text('الكل', style: TextStyle(fontSize: 11)),
                  selected: _selectedCostTier == null,
                  onSelected: (val) => setState(() => _selectedCostTier = null),
                ),
                const SizedBox(width: 6),
                ...CostTier.values.map((tier) {
                  final isSel = _selectedCostTier == tier;
                  return Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: ChoiceChip(
                      label: Text(
                        '${tier.icon} ${tier.label.split(' ').first}',
                        style: const TextStyle(fontSize: 11),
                      ),
                      selected: isSel,
                      onSelected: (val) => setState(() => _selectedCostTier = val ? tier : null),
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Recipe List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off_rounded, size: 64, color: Colors.grey),
                        const SizedBox(height: 12),
                        const Text(
                          'لم يتم العثور على أكلات مطابقة',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'جربي البحث بكلمات أخرى أو غيري القسم المختار',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final recipe = filtered[index];
                      return RecipeCard(
                        recipe: recipe,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RecipeDetailScreen(recipe: recipe),
                            ),
                          ).then((_) => _loadRecipes());
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
