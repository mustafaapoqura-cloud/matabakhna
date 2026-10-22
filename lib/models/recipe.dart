enum CostTier {
  budget('اقتصادي (على قد الإيد)', '🟢'),
  medium('متوسط (معقول)', '🟡'),
  deluxe('مميز (عزومات وتدليع)', '🟣');

  final String label;
  final String icon;
  const CostTier(this.label, this.icon);
}

enum RecipeCategory {
  popular('أكل شعبي', '🥙'),
  egyptian('أكل مصري أصيل', '🍲'),
  western('أكل غربي وسريع', '🍔'),
  desserts('حلويات', '🍰'),
  budgetFriendly('أكلات اقتصادية', '🪙'),
  healthy('دايت وصحي', '🥗');

  final String label;
  final String emoji;
  const RecipeCategory(this.label, this.emoji);
}

class RecipeIngredient {
  final String name;
  final String amount;
  final String? notes;

  const RecipeIngredient({
    required this.name,
    required this.amount,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'amount': amount,
        'notes': notes,
      };

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) =>
      RecipeIngredient(
        name: json['name'] as String,
        amount: json['amount'] as String,
        notes: json['notes'] as String?,
      );
}

class Recipe {
  final String id;
  final String name;
  final RecipeCategory category;
  final String imageUrl;
  final String description;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final int servings;
  final double estimatedCost; // بالجنيه المصري
  final CostTier costTier;
  final List<RecipeIngredient> ingredients;
  final List<String> steps;
  final List<String> tips;
  final int calories;
  final bool isUserAdded;
  final bool isFeatured;

  const Recipe({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.description,
    required this.prepTimeMinutes,
    required this.cookTimeMinutes,
    required this.servings,
    required this.estimatedCost,
    required this.costTier,
    required this.ingredients,
    required this.steps,
    this.tips = const [],
    this.calories = 450,
    this.isUserAdded = false,
    this.isFeatured = false,
  });

  int get totalTimeMinutes => prepTimeMinutes + cookTimeMinutes;

  double get costPerServing =>
      servings > 0 ? (estimatedCost / servings) : estimatedCost;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category.name,
        'imageUrl': imageUrl,
        'description': description,
        'prepTimeMinutes': prepTimeMinutes,
        'cookTimeMinutes': cookTimeMinutes,
        'servings': servings,
        'estimatedCost': estimatedCost,
        'costTier': costTier.name,
        'ingredients': ingredients.map((i) => i.toJson()).toList(),
        'steps': steps,
        'tips': tips,
        'calories': calories,
        'isUserAdded': isUserAdded,
        'isFeatured': isFeatured,
      };

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
        id: json['id'] as String,
        name: json['name'] as String,
        category: RecipeCategory.values.firstWhere(
          (c) => c.name.toLowerCase() == (json['category'] as String?)?.toLowerCase(),
          orElse: () => RecipeCategory.egyptian,
        ),
        imageUrl: json['imageUrl'] as String,
        description: json['description'] as String,
        prepTimeMinutes: json['prepTimeMinutes'] as int? ?? 20,
        cookTimeMinutes: json['cookTimeMinutes'] as int? ?? 30,
        servings: json['servings'] as int? ?? 4,
        estimatedCost: (json['estimatedCost'] as num?)?.toDouble() ?? 100.0,
        costTier: CostTier.values.firstWhere(
          (t) => t.name == json['costTier'],
          orElse: () => CostTier.medium,
        ),
        ingredients: (json['ingredients'] as List<dynamic>?)
                ?.map((i) => RecipeIngredient.fromJson(i as Map<String, dynamic>))
                .toList() ??
            [],
        steps: (json['steps'] as List<dynamic>?)
                ?.map((s) => s.toString())
                .toList() ??
            [],
        tips: (json['tips'] as List<dynamic>?)
                ?.map((s) => s.toString())
                .toList() ??
            [],
        calories: json['calories'] as int? ?? 450,
        isUserAdded: json['isUserAdded'] as bool? ?? false,
        isFeatured: json['isFeatured'] == true || json['isFeatured'] == 1 || json['isFeatured'] == '1',
      );
}
