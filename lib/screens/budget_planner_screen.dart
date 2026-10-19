import 'package:flutter/material.dart';
import '../models/budget_plan.dart';
import '../models/recipe.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';

class BudgetPlannerScreen extends StatefulWidget {
  const BudgetPlannerScreen({super.key});

  @override
  State<BudgetPlannerScreen> createState() => _BudgetPlannerScreenState();
}

class _BudgetPlannerScreenState extends State<BudgetPlannerScreen> {
  BudgetPeriod _selectedPeriod = BudgetPeriod.daily;
  late TextEditingController _amountController;
  int _familyMembers = 4;
  List<Recipe> _allRecipes = [];

  @override
  void initState() {
    super.initState();
    final currentPlan = StorageService.getBudgetPlan();
    _selectedPeriod = currentPlan.period;
    _familyMembers = currentPlan.familyMembers;
    _amountController =
        TextEditingController(text: currentPlan.totalBudget.toInt().toString());
    _loadRecipes();
  }

  void _loadRecipes() {
    setState(() {
      _allRecipes = StorageService.getAllRecipes();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double get _currentAmount {
    return double.tryParse(_amountController.text.trim()) ?? 150.0;
  }

  double get _dailyEquivalent {
    return _currentAmount / _selectedPeriod.days;
  }

  double get _perPersonCost {
    return _familyMembers > 0 ? (_dailyEquivalent / _familyMembers) : _dailyEquivalent;
  }

  void _saveBudget() async {
    final plan = BudgetPlan(
      period: _selectedPeriod,
      totalBudget: _currentAmount,
      familyMembers: _familyMembers,
    );
    await StorageService.saveBudgetPlan(plan);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('تم حفظ الميزانية وتحديث الاقتراحات!'),
          ],
        ),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  List<Recipe> _getMatchingRecipes() {
    final daily = _dailyEquivalent;
    // Suggest recipes that cost less than or close to the daily budget allowance (+20% leeway)
    final matches = _allRecipes.where((r) {
      return r.estimatedCost <= (daily * 1.25);
    }).toList();

    // Sort by closest fit to budget
    matches.sort((a, b) => b.estimatedCost.compareTo(a.estimatedCost));
    return matches;
  }

  @override
  Widget build(BuildContext context) {
    final matchingRecipes = _getMatchingRecipes();

    return Scaffold(
      appBar: AppBar(
        title: const Text('مخطط وميزانية الأكل'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Period Selector Tabs
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: BudgetPeriod.values.map((period) {
                    final isSelected = _selectedPeriod == period;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedPeriod = period;
                            // adjust sample amount for convenience if default
                            if (_amountController.text == '150' && period == BudgetPeriod.weekly) {
                              _amountController.text = '1000';
                            } else if (_amountController.text == '1000' && period == BudgetPeriod.monthly) {
                              _amountController.text = '4500';
                            } else if (_amountController.text == '4500' && period == BudgetPeriod.daily) {
                              _amountController.text = '150';
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(15),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          child: Text(
                            period.shortName,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 18),

              // Budget Input Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'كم ميزانيتك لـ ${_selectedPeriod.shortName}؟',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      onChanged: (val) => setState(() {}),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.monetization_on_rounded, color: AppTheme.primary),
                        suffixText: 'جنيه مصري',
                        suffixStyle: const TextStyle(fontWeight: FontWeight.bold),
                        hintText: 'مثلاً: 150',
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Quick Preset Chips
                    Wrap(
                      spacing: 8,
                      children: [50, 100, 200, 500, 1000].map((preset) {
                        return ActionChip(
                          label: Text('+$preset ج'),
                          onPressed: () {
                            final current = double.tryParse(_amountController.text) ?? 0;
                            setState(() {
                              _amountController.text = (current + preset).toInt().toString();
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: AppTheme.borderLight),
                    const SizedBox(height: 16),

                    // Family Members Stepper
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'عدد أفراد الأسرة',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              'لحساب نصيب كل فرد من الوجبة',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.borderLight),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, size: 18),
                                onPressed: _familyMembers > 1
                                    ? () => setState(() => _familyMembers--)
                                    : null,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  '$_familyMembers',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, size: 18),
                                onPressed: _familyMembers < 15
                                    ? () => setState(() => _familyMembers++)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Calculated Breakdown Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withAlpha(15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primary.withAlpha(40)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text(
                          'الميزانية اليومية للطبخ',
                          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_dailyEquivalent.toInt()} ج / يوم',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                    Container(height: 35, width: 1, color: AppTheme.primary.withAlpha(40)),
                    Column(
                      children: [
                        const Text(
                          'نصيب الفرد في الوجبة',
                          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_perPersonCost.toStringAsFixed(1)} ج',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Save Button
              ElevatedButton.icon(
                onPressed: _saveBudget,
                icon: const Icon(Icons.save_rounded, size: 20),
                label: const Text('حفظ واعتماد الميزانية'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),

              const SizedBox(height: 24),

              // Results Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text('🍲', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(
                        'أكلات مقترحة تناسب ميزانيتك (${matchingRecipes.length})',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (matchingRecipes.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderLight),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.sentiment_dissatisfied, size: 48, color: Colors.grey),
                      const SizedBox(height: 8),
                      const Text(
                        'لا توجد أكلات متطابقة مع هذه الميزانية حالياً',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'جربي رفع الميزانية قليلاً لاكتشاف المزيد من الأكلات الشهية',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: matchingRecipes.length,
                  itemBuilder: (context, index) {
                    final recipe = matchingRecipes[index];
                    return RecipeCard(
                      recipe: recipe,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecipeDetailScreen(recipe: recipe),
                          ),
                        );
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
