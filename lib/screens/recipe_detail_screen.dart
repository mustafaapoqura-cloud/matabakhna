import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';
import 'cooking_mode_screen.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late bool isFav;
  final Set<int> _checkedIngredients = {};

  @override
  void initState() {
    super.initState();
    isFav = StorageService.isFavorite(widget.recipe.id);
  }

  void _toggleFav() async {
    await StorageService.toggleFavorite(widget.recipe.id);
    setState(() {
      isFav = !isFav;
    });
  }

  void _addToShoppingList() async {
    await StorageService.addIngredientsToShopping(
      widget.recipe.ingredients,
      widget.recipe.name,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'تمت إضافة مقادير (${widget.recipe.name}) لقائمة مشترياتك!',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white.withAlpha(220),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.white.withAlpha(220),
                  child: IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: isFav ? Colors.red : AppTheme.textPrimary,
                    ),
                    onPressed: _toggleFav,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.recipe.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppTheme.primary.withAlpha(30),
                      child: const Icon(
                        Icons.restaurant_menu_rounded,
                        size: 80,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withAlpha(80),
                          Colors.transparent,
                          Colors.black.withAlpha(160),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    left: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${widget.recipe.category.emoji} ${widget.recipe.category.label}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.recipe.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meta Stats Row
                  _buildQuickStatsCard(),
                  const SizedBox(height: 18),

                  // Description
                  Text(
                    widget.recipe.description,
                    style: TextStyle(
                      fontSize: 14.5,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Ingredients Header with Add to Shopping List button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withAlpha(25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.egg_alt_rounded, color: AppTheme.primary, size: 20),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'المقادير والمكونات',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: _addToShoppingList,
                        icon: const Icon(Icons.playlist_add_rounded, size: 18),
                        label: const Text(
                          'لقائمة الطلبات',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Ingredients List
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.borderLight),
                    ),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: widget.recipe.ingredients.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1, indent: 16, endIndent: 16, color: AppTheme.borderLight),
                      itemBuilder: (context, index) {
                        final ing = widget.recipe.ingredients[index];
                        final isChecked = _checkedIngredients.contains(index);
                        return CheckboxListTile(
                          value: isChecked,
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                _checkedIngredients.add(index);
                              } else {
                                _checkedIngredients.remove(index);
                              }
                            });
                          },
                          activeColor: AppTheme.primary,
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Text(
                            ing.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14.5,
                              decoration: isChecked ? TextDecoration.lineThrough : null,
                              color: isChecked ? Colors.grey : AppTheme.textPrimary,
                            ),
                          ),
                          secondary: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withAlpha(20),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              ing.amount,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryDark,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Steps Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.secondary.withAlpha(40),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.format_list_numbered_rounded, color: AppTheme.secondary, size: 20),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'طريقة التحضير بالخطوات',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Steps List
                  ListView.builder(
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: widget.recipe.steps.length,
                    itemBuilder: (context, index) {
                      final stepText = widget.recipe.steps[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.borderLight),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: AppTheme.primary,
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                stepText,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textPrimary,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  // Tips / Secrets Box
                  if (widget.recipe.tips.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF9DB),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFFEC99)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Text('💡', style: TextStyle(fontSize: 18)),
                              SizedBox(width: 8),
                              Text(
                                'تكات وأسرار ست البيت الشاطرة',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Color(0xFFD9480F),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...widget.recipe.tips.map(
                            (tip) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Expanded(
                                    child: Text(
                                      tip,
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        height: 1.4,
                                        color: Color(0xFF495057),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 100), // Spacing for floating button
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CookingModeScreen(recipe: widget.recipe),
                ),
              );
            },
            icon: const Icon(Icons.timer_outlined, size: 22),
            label: const Text(
              'ابدأي الطبخ الآن (وضع المطبخ + مؤقت)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStatsCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatCol(
            Icons.monetization_on_rounded,
            'التكلفة',
            '~${widget.recipe.estimatedCost.toInt()} ج',
            AppTheme.primary,
          ),
          _buildVerticalDivider(),
          _buildStatCol(
            Icons.schedule_rounded,
            'التحضير والطبخ',
            '${widget.recipe.totalTimeMinutes} دقيقة',
            Colors.blue.shade700,
          ),
          _buildVerticalDivider(),
          _buildStatCol(
            Icons.people_alt_rounded,
            'تكفي',
            '${widget.recipe.servings} أفراد',
            Colors.teal.shade700,
          ),
          _buildVerticalDivider(),
          _buildStatCol(
            Icons.local_fire_department_rounded,
            'السعرات',
            '${widget.recipe.calories} سعرة',
            Colors.orange.shade800,
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 35,
      width: 1,
      color: AppTheme.borderLight,
    );
  }

  Widget _buildStatCol(IconData icon, String label, String val, Color color) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 2),
        Text(
          val,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
