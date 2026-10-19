import 'dart:math';
import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'recipe_detail_screen.dart';

class MealPlannerScreen extends StatefulWidget {
  const MealPlannerScreen({super.key});

  @override
  State<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> {
  final List<Map<String, String>> _days = const [
    {'key': 'sat', 'label': 'السبت'},
    {'key': 'sun', 'label': 'الأحد'},
    {'key': 'mon', 'label': 'الإثنين'},
    {'key': 'tue', 'label': 'الثلاثاء'},
    {'key': 'wed', 'label': 'الأربعاء'},
    {'key': 'thu', 'label': 'الخميس'},
    {'key': 'fri', 'label': 'الجمعة'},
  ];

  Map<String, String> _schedule = {};
  List<Recipe> _allRecipes = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _schedule = StorageService.getWeeklyPlan();
      _allRecipes = StorageService.getAllRecipes();
    });
  }

  void _autoSuggestWeeklyPlan() async {
    if (_allRecipes.isEmpty) return;
    final random = Random();
    final shuffled = List<Recipe>.from(_allRecipes)..shuffle(random);
    for (int i = 0; i < _days.length; i++) {
      final dayKey = _days[i]['key']!;
      final recipe = shuffled[i % shuffled.length];
      await StorageService.setWeeklyMeal(dayKey, recipe.id);
    }
    _loadData();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم إعداد جدول وجبات مقترح للأسبوع بالكامل! 🥗🍲'),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  void _chooseMealForDay(String dayKey, String dayLabel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'اختاري وجبة يوم $dayLabel',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: _allRecipes.length,
                      itemBuilder: (context, index) {
                        final recipe = _allRecipes[index];
                        return ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              recipe.imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => Container(
                                width: 50,
                                height: 50,
                                color: AppTheme.primary.withAlpha(20),
                                child: const Icon(Icons.restaurant, color: AppTheme.primary),
                              ),
                            ),
                          ),
                          title: Text(
                            recipe.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          subtitle: Text(
                            '${recipe.category.emoji} ${recipe.category.label} • حوالي ${recipe.estimatedCost.toInt()} ج',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                          onTap: () async {
                            await StorageService.setWeeklyMeal(dayKey, recipe.id);
                            _loadData();
                            if (context.mounted) Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalEstimatedWeekCost = 0;
    for (var day in _days) {
      final recipeId = _schedule[day['key']];
      if (recipeId != null) {
        final r = StorageService.getRecipeById(recipeId);
        if (r != null) totalEstimatedWeekCost += r.estimatedCost;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('جدول وجبات الأسبوع'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome, color: AppTheme.secondary),
            tooltip: 'اقتراح ذكي للأسبوع',
            onPressed: _autoSuggestWeeklyPlan,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Top Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withAlpha(20),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.calendar_month_rounded, color: AppTheme.primary, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ريحي بالك من سؤال "هنطبخ إيه؟"',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'تكلفة الأسبوع المقدرة: ${totalEstimatedWeekCost.toInt()} ج',
                          style: const TextStyle(fontSize: 13, color: AppTheme.primary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Days List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _days.length,
              itemBuilder: (context, index) {
                final day = _days[index];
                final dayKey = day['key']!;
                final dayLabel = day['label']!;
                final assignedRecipeId = _schedule[dayKey];
                final recipe = assignedRecipeId != null
                    ? StorageService.getRecipeById(assignedRecipeId)
                    : null;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderLight),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        dayLabel,
                        style: const TextStyle(
                          color: AppTheme.primaryDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    title: recipe != null
                        ? Text(
                            recipe.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : Text(
                            'لم يتم تحديد وجبة بعد',
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                          ),
                    subtitle: recipe != null
                        ? Text(
                            '~${recipe.estimatedCost.toInt()} ج • ${recipe.totalTimeMinutes} دقيقة',
                            style: const TextStyle(fontSize: 12, color: AppTheme.primary),
                          )
                        : const Text(
                            'اضغطي لاختيار أكلة لهذا اليوم',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (recipe != null)
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.grey, size: 20),
                            onPressed: () async {
                              await StorageService.setWeeklyMeal(dayKey, null);
                              _loadData();
                            },
                          ),
                        IconButton(
                          icon: Icon(
                            recipe != null ? Icons.edit : Icons.add_circle_rounded,
                            color: AppTheme.primary,
                          ),
                          onPressed: () => _chooseMealForDay(dayKey, dayLabel),
                        ),
                      ],
                    ),
                    onTap: () {
                      if (recipe != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecipeDetailScreen(recipe: recipe),
                          ),
                        );
                      } else {
                        _chooseMealForDay(dayKey, dayLabel);
                      }
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
