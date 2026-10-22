import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe.dart';
import '../models/budget_plan.dart';
import '../models/shopping_item.dart';
import '../data/recipe_data.dart';

class StorageService {
  static const String _keyFavorites = 'matebakhna_favorites';
  static const String _keyCustomRecipes = 'matebakhna_custom_recipes';
  static const String _keyRemoteCache = 'matebakhna_remote_recipes';
  static const String _keyShoppingList = 'matebakhna_shopping_list';
  static const String _keyBudgetPlan = 'matebakhna_budget_plan';
  static const String _keyWeeklyPlan = 'matebakhna_weekly_plan';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // --- المفضلة Favorites ---
  static const String _keySeenOnboarding = 'matebakhna_seen_onboarding';

  static bool hasSeenOnboarding() {
    return _prefs?.getBool(_keySeenOnboarding) ?? false;
  }

  static Future<void> setSeenOnboarding() async {
    await _prefs?.setBool(_keySeenOnboarding, true);
  }

  static Set<String> getFavoriteIds() {
    final list = _prefs?.getStringList(_keyFavorites) ?? [];
    return list.toSet();
  }

  static Future<void> toggleFavorite(String recipeId) async {
    final favs = getFavoriteIds();
    if (favs.contains(recipeId)) {
      favs.remove(recipeId);
    } else {
      favs.add(recipeId);
    }
    await _prefs?.setStringList(_keyFavorites, favs.toList());
  }

  static bool isFavorite(String recipeId) {
    return getFavoriteIds().contains(recipeId);
  }

  // --- وصفات المستخدم Custom Recipes ---
  static List<Recipe> getCustomRecipes() {
    final raw = _prefs?.getString(_keyCustomRecipes);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(raw);
      return list.map((item) => Recipe.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveCustomRecipe(Recipe recipe) async {
    final list = getCustomRecipes();
    final index = list.indexWhere((r) => r.id == recipe.id);
    if (index >= 0) {
      list[index] = recipe;
    } else {
      list.insert(0, recipe);
    }
    final raw = jsonEncode(list.map((r) => r.toJson()).toList());
    await _prefs?.setString(_keyCustomRecipes, raw);
  }

  static Future<void> deleteCustomRecipe(String recipeId) async {
    final list = getCustomRecipes();
    list.removeWhere((r) => r.id == recipeId);
    final raw = jsonEncode(list.map((r) => r.toJson()).toList());
    await _prefs?.setString(_keyCustomRecipes, raw);
  }

  static Future<void> cacheRemoteRecipes(List<Recipe> recipes) async {
    final raw = jsonEncode(recipes.map((r) => r.toJson()).toList());
    await _prefs?.setString(_keyRemoteCache, raw);
  }

  static List<Recipe> getRemoteCachedRecipes() {
    final raw = _prefs?.getString(_keyRemoteCache);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(raw);
      return list.map((item) => Recipe.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  // --- كل الوصفات مدمجة All Recipes ---
  static List<Recipe> getAllRecipes() {
    final custom = getCustomRecipes();
    final remote = getRemoteCachedRecipes();

    // Prioritize real data from backend/custom recipes, avoid fake initial mock data
    if (remote.isNotEmpty || custom.isNotEmpty) {
      final Map<String, Recipe> map = {};
      for (var r in remote) {
        map[r.id] = r;
      }
      for (var r in custom) {
        map[r.id] = r;
      }
      return map.values.toList();
    }

    return [];
  }

  static Recipe? getRecipeById(String id) {
    final all = getAllRecipes();
    try {
      return all.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  // --- قائمة المشتريات Shopping List ---
  static List<ShoppingItem> getShoppingList() {
    final raw = _prefs?.getString(_keyShoppingList);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(raw);
      return list
          .map((item) => ShoppingItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveShoppingList(List<ShoppingItem> items) async {
    final raw = jsonEncode(items.map((i) => i.toJson()).toList());
    await _prefs?.setString(_keyShoppingList, raw);
  }

  static Future<void> addIngredientsToShopping(
      List<RecipeIngredient> ingredients, String recipeName) async {
    final current = getShoppingList();
    for (final ing in ingredients) {
      current.add(ShoppingItem(
        id: '${DateTime.now().millisecondsSinceEpoch}_${ing.name.hashCode}',
        title: ing.name,
        quantity: ing.amount,
        category: recipeName,
        isBought: false,
      ));
    }
    await saveShoppingList(current);
  }

  // --- الميزانية Budget Plan ---
  static BudgetPlan getBudgetPlan() {
    final raw = _prefs?.getString(_keyBudgetPlan);
    if (raw == null || raw.isEmpty) {
      return const BudgetPlan(
        period: BudgetPeriod.daily,
        totalBudget: 150.0,
        familyMembers: 4,
      );
    }
    try {
      return BudgetPlan.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const BudgetPlan(
        period: BudgetPeriod.daily,
        totalBudget: 150.0,
        familyMembers: 4,
      );
    }
  }

  static Future<void> saveBudgetPlan(BudgetPlan plan) async {
    final raw = jsonEncode(plan.toJson());
    await _prefs?.setString(_keyBudgetPlan, raw);
  }

  // --- جدول الأسبوع Weekly Plan ---
  static Map<String, String> getWeeklyPlan() {
    final raw = _prefs?.getString(_keyWeeklyPlan);
    if (raw == null || raw.isEmpty) return {};
    try {
      final Map<String, dynamic> decoded = jsonDecode(raw);
      return decoded.map((k, v) => MapEntry(k, v.toString()));
    } catch (_) {
      return {};
    }
  }

  static Future<void> setWeeklyMeal(String dayKey, String? recipeId) async {
    final current = getWeeklyPlan();
    if (recipeId == null) {
      current.remove(dayKey);
    } else {
      current[dayKey] = recipeId;
    }
    await _prefs?.setString(_keyWeeklyPlan, jsonEncode(current));
  }
}
