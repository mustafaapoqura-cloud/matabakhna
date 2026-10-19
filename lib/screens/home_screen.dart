import 'dart:math';
import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../models/budget_plan.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/recipe_card.dart';
import '../widgets/budget_summary_card.dart';
import 'budget_planner_screen.dart';
import 'recipes_screen.dart';
import 'recipe_detail_screen.dart';
import 'shopping_list_screen.dart';
import 'meal_planner_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late BudgetPlan _budgetPlan;
  List<Recipe> _allRecipes = [];
  Recipe? _dishOfTheDay;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _budgetPlan = StorageService.getBudgetPlan();
      _allRecipes = StorageService.getAllRecipes();
      if (_allRecipes.isNotEmpty) {
        // Deterministic daily dish based on day of year
        final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
        _dishOfTheDay = _allRecipes[dayOfYear % _allRecipes.length];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildHomeDashboard(),
      const BudgetPlannerScreen(),
      const RecipesScreen(),
      const ShoppingListScreen(),
      const MealPlannerScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            if (index == 0) _refreshData();
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: Colors.grey.shade500,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'الرئيسية',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_rounded),
              label: 'الميزانية',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu_rounded),
              label: 'الأكلات',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_basket_rounded),
              label: 'قائمة السوق',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_rounded),
              label: 'جدول الأسبوع',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeDashboard() {
    final budgetDishes = _allRecipes
        .where((r) => r.costTier == CostTier.budget || r.estimatedCost <= 80)
        .toList();

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async => _refreshData(),
        color: AppTheme.primary,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with App Logo and Slogan
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/images/logo.jpg',
                      width: 54,
                      height: 54,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        width: 54,
                        height: 54,
                        color: AppTheme.primary,
                        child: const Icon(Icons.restaurant, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'طبختنا 🍳',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          'دليلك الذكي لميزانية ومطبخ بيتك',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _showSurpriseMe();
                    },
                    icon: const Icon(Icons.casino_rounded, color: AppTheme.secondary, size: 28),
                    tooltip: 'اقترح لي أكلة عشوائية!',
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Budget Summary Card
              BudgetSummaryCard(
                plan: _budgetPlan,
                onTap: () {
                  setState(() {
                    _currentIndex = 1; // switch to budget planner
                  });
                },
              ),

              const SizedBox(height: 22),

              // Categories Quick Scroll
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'أقسام الأكل',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() => _currentIndex = 2);
                    },
                    child: const Text('عرض الكل'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 110,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: RecipeCategory.values.map((category) {
                    return _buildCategoryTile(category);
                  }).toList(),
                ),
              ),

              const SizedBox(height: 20),

              // Dish of the Day Banner
              if (_dishOfTheDay != null) ...[
                Row(
                  children: [
                    const Text('🌟', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    const Text(
                      'أكلة النهاردة المقترحة',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                RecipeCard(
                  recipe: _dishOfTheDay!,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailScreen(recipe: _dishOfTheDay!),
                      ),
                    ).then((_) => _refreshData());
                  },
                ),
              ],

              const SizedBox(height: 16),

              // Budget friendly dishes horizontal scroll
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Row(
                      children: [
                        Text('🪙', style: TextStyle(fontSize: 18)),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'أكلات اقتصادية على قد الإيد',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RecipesScreen(
                            initialCategory: RecipeCategory.budgetFriendly,
                          ),
                        ),
                      );
                    },
                    child: const Text('المزيد'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: budgetDishes.length,
                  itemBuilder: (context, index) {
                    final recipe = budgetDishes[index];
                    return RecipeCard(
                      recipe: recipe,
                      isCompact: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecipeDetailScreen(recipe: recipe),
                          ),
                        ).then((_) => _refreshData());
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Egyptian Authentic Cuisine
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Row(
                      children: [
                        Text('🍲', style: TextStyle(fontSize: 18)),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'أكل مصري أصيل',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RecipesScreen(
                            initialCategory: RecipeCategory.egyptian,
                          ),
                        ),
                      );
                    },
                    child: const Text('المزيد'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ..._allRecipes
                  .where((r) => r.category == RecipeCategory.egyptian)
                  .take(2)
                  .map((recipe) => RecipeCard(
                        recipe: recipe,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RecipeDetailScreen(recipe: recipe),
                            ),
                          ).then((_) => _refreshData());
                        },
                      )),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTile(RecipeCategory category) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipesScreen(initialCategory: category),
          ),
        );
      },
      child: Container(
        width: 84,
        margin: const EdgeInsets.only(left: 10),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(6),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              category.emoji,
              style: const TextStyle(fontSize: 26),
            ),
            const SizedBox(height: 6),
            Text(
              category.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showSurpriseMe() {
    if (_allRecipes.isEmpty) return;
    final r = _allRecipes[Random().nextInt(_allRecipes.length)];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('🎲', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text('حليتي مشكلة الغداء!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                r.imageUrl,
                height: 130,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  height: 130,
                  color: AppTheme.primary.withAlpha(20),
                  child: const Icon(Icons.restaurant, color: AppTheme.primary),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              r.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'التكلفة: حوالي ${r.estimatedCost.toInt()} ج • الوقت: ${r.totalTimeMinutes} دقيقة',
              style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('اقتراح آخر'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RecipeDetailScreen(recipe: r)),
              );
            },
            child: const Text('عرض الوصفة'),
          ),
        ],
      ),
    );
  }
}
