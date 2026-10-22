import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:matebakhna/screens/widget/app_bar.dart';
import '../models/recipe.dart';
import '../models/budget_plan.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/recipe_card.dart';
import '../widgets/budget_summary_card.dart';
import 'budget_planner_screen.dart';
import 'recipes_screen.dart';
import 'recipe_detail_screen.dart';
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
      _updateDishOfTheDay();
    });

    // Sync with PHP backend in background
    ApiService.fetchRecipes().then((latest) {
      if (mounted) {
        setState(() {
          _allRecipes = latest;
          _updateDishOfTheDay();
        });
      }
    });
  }

  void _updateDishOfTheDay() {
    try {
      _dishOfTheDay = _allRecipes.firstWhere((r) => r.isFeatured);
    } catch (_) {
      _dishOfTheDay = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildHomeDashboard(),
      const BudgetPlannerScreen(),
      RecipesScreen(key: ValueKey('recipes_screen_$_currentIndex')),
      const MealPlannerScreen(),
    ];

    return Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,

appBar: _currentIndex == 0
    ? CustomAppBar.homeAppBar(
        onSurpriseMe: _showSurpriseMe,
      )
    : null,      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
     
        
   
bottomNavigationBar: ClipRRect(
  borderRadius: const BorderRadius.only(
    topLeft: Radius.circular(35),
    topRight: Radius.circular(35),
  ),
  child: BackdropFilter(
    filter: ImageFilter.blur(
      sigmaX: 18,
      sigmaY: 18,
    ),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(35),
          topRight: Radius.circular(35),
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.45),
          width: 1.2,
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.35),
            Colors.white.withValues(alpha: 0.12),
          ],
        ),
      ),
      padding: EdgeInsets.only(
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navIcon(Icons.home, 'الرئيسية', 0),
          _navIcon(
            Icons.account_balance_wallet_outlined,
            'الميزانية',
            1,
          ),
          _navIcon(Icons.restaurant_menu, 'الأكلات', 2),
          _navIcon(
            Icons.calendar_month_outlined,
            'جدول الأسبوع',
            3,
          ),
         
        ],
      ),
    ),
  ),
),
);
  }
Widget _navIcon(IconData icon, String label, int index) {
  final selected = _currentIndex == index;

  return GestureDetector(
    onTap: () {
      setState(() {
        _currentIndex = index;
      });

      if (index == 0) {
        _refreshData();
      }
    },
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.fastLinearToSlowEaseIn,
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.only(bottom: selected ? 15 : 0),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: selected ? Colors.white : Colors.transparent,
            width: 4,
          ),
          right: BorderSide(
            color: selected ? Colors.white : Colors.transparent,
            width: 4,
          ),
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.6),
                  blurRadius: 8,
                  offset: const Offset(0, 6),
                ),
              ]
            : [],
        
        borderRadius: BorderRadius.circular(35),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: selected ? Colors.white : Colors.grey.shade600,
            size: selected ? 26 : 24,
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: selected ? Colors.white : AppTheme.primary,
              fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ],
      ),
    ),
  );
}


  Widget _buildHomeDashboard() {
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
                    child: const Text( 'عرض الكل »'),
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

              // Dynamic Category Sections: Each category with recipes is shown!
              ...RecipeCategory.values.where((cat) {
                return _allRecipes.any((r) => r.category == cat);
              }).map((category) {
                final categoryRecipes = _allRecipes.where((r) => r.category == category).toList();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text(category.emoji, style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  category == RecipeCategory.budgetFriendly 
                                    ? 'أكلات اقتصادية على قد الإيد' 
                                    : category.label,
                                  style: const TextStyle(
                                    fontSize: 18,
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
                                builder: (context) => RecipesScreen(
                                  initialCategory: category,
                                ),
                              ),
                            );
                          },
                          child: const Text('المزيد »'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 220,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categoryRecipes.length,
                        itemBuilder: (context, index) {
                          final recipe = categoryRecipes[index];
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
                  ],
                );
              }),

              const SizedBox(height: 24),
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
  if (_allRecipes.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('أضيفي وصفات الأول!')),
    );
    return;
  }

  final random = Random();
  var r = _allRecipes[random.nextInt(_allRecipes.length)];

  showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Row(
              children: [
                Text('🎲', style: TextStyle(fontSize: 24)),
                SizedBox(width: 8),
                Expanded(child: Text('حليتي مشكلة الغداء!')),
              ],
            ),
         content: SizedBox(
  width: MediaQuery.of(context).size.width * 0.7,
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          r.imageUrl,
          height: 130,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            height: 130,
            width: double.infinity,
            color: AppTheme.primary.withAlpha(20),
            alignment: Alignment.center,
            child: const Icon(
              Icons.restaurant,
              color: AppTheme.primary,
              size: 40,
            ),
          ),
        ),
      ),
      const SizedBox(height: 12),
      Text(
        r.name,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 4),
      Text(
        'التكلفة: حوالي ${r.estimatedCost.toInt()} ج'
        ' • الوقت: ${r.totalTimeMinutes} دقيقة',
        style: const TextStyle(
          color: AppTheme.primary,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        textAlign: TextAlign.center,
      ),
    ],
  ),
),


  actions: [
              TextButton(
                onPressed: () {
                  if (_allRecipes.length < 2) return;

                  final previousRecipe = r;
                  do {
                    r = _allRecipes[random.nextInt(_allRecipes.length)];
                  } while (identical(r, previousRecipe));

                  setDialogState(() {});
                },
                child: const Text('اقتراح آخر'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RecipeDetailScreen(recipe: r),
                    ),
                  );
                },
                child: const Text('عرض الوصفة'),
              ),
            ],
          );
        },
      );
    },
  );
}

}
