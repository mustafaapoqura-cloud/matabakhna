import 'package:flutter/material.dart';
import 'package:matebakhna/screens/widget/app_bar.dart';

import '../models/budget_plan.dart';
import '../models/recipe.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';

class BudgetPlannerScreen extends StatefulWidget {
  const BudgetPlannerScreen({super.key});

  @override
  State<BudgetPlannerScreen> createState() =>
      _BudgetPlannerScreenState();
}

class _BudgetPlannerScreenState extends State<BudgetPlannerScreen> {
  BudgetPeriod _selectedPeriod = BudgetPeriod.daily;
  late final TextEditingController _amountController;

  int _familyMembers = 4;
  List<Recipe> _allRecipes = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final plan = StorageService.getBudgetPlan();

    _selectedPeriod = plan.period;
    _familyMembers = plan.familyMembers.clamp(1, 15);

    _amountController = TextEditingController(
      text: plan.totalBudget.toStringAsFixed(
        plan.totalBudget % 1 == 0 ? 0 : 2,
      ),
    );

    _allRecipes = StorageService.getAllRecipes();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double get _currentAmount {
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    return amount.isFinite && amount > 0 ? amount : 0;
  }

  double get _dailyEquivalent =>
      _currentAmount / _selectedPeriod.days;

  double get _perPersonCost =>
      _dailyEquivalent / _familyMembers;

  List<double> get _presets {
    switch (_selectedPeriod) {
      case BudgetPeriod.daily:
        return [100, 150, 200, 300, 500];
      case BudgetPeriod.weekly:
        return [700, 1000, 1400, 2000, 3000];
      case BudgetPeriod.monthly:
        return [3000, 4500, 6000, 9000, 12000];
    }
  }

  List<Recipe> get _matchingRecipes {
    if (_dailyEquivalent <= 0) return [];

    final matches = _allRecipes.where((recipe) {
      return recipe.estimatedCost >= 0 &&
          recipe.estimatedCost <= _dailyEquivalent * 1.25;
    }).toList();

    // Closest to the daily budget first.
    matches.sort((a, b) {
      final differenceA =
          (_dailyEquivalent - a.estimatedCost).abs();
      final differenceB =
          (_dailyEquivalent - b.estimatedCost).abs();

      return differenceA.compareTo(differenceB);
    });

    return matches;
  }

  Future<void> _saveBudget() async {
    FocusScope.of(context).unfocus();

    if (_currentAmount <= 0) {
      _showMessage('من فضلك أدخلي ميزانية أكبر من صفر');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final plan = BudgetPlan(
        period: _selectedPeriod,
        totalBudget: _currentAmount,
        familyMembers: _familyMembers,
      );

      await StorageService.saveBudgetPlan(plan);

      if (!mounted) return;

      _showMessage(
        'تم حفظ الميزانية بنجاح ❤️',
        color: AppTheme.success,
      );
    } catch (_) {
      if (!mounted) return;
      _showMessage('حصلت مشكلة أثناء حفظ الميزانية، حاولي تاني');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showMessage(String message, {Color? color}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color ?? AppTheme.primaryDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  void _selectPeriod(BudgetPeriod period) {
    setState(() => _selectedPeriod = period);
  }

  void _selectPreset(double amount) {
    setState(() {
      _amountController.text = amount.toInt().toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final recipes = _matchingRecipes;

    return Scaffold(
      appBar: CustomAppBar.batbakhnaBar(
        context: context,
        title: 'ميزانية مطبخك',
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      AppTheme.primary,
                      AppTheme.primaryDark,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                   
                   
                    Row(
                      children: [
                         Icon(
                      Icons.savings_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                    SizedBox(width: 10),
                        Text(
'كلي حلو ووفري بذكاء يا ست الكل🤌🏻',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text(
                      'حددي ميزانيتك واكتشفي وصفات تناسب جيبك.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              _sectionTitle(
                Icons.calendar_month_rounded,
                'حددي الفترة',
              ),

              const SizedBox(height: 12),

              // Period selector
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Row(
                  children: BudgetPeriod.values.map((period) {
                    final selected = _selectedPeriod == period;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _selectPeriod(period),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 4,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppTheme.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(13),
                            boxShadow: selected
                                ? [
                                    BoxShadow(
                                      color: AppTheme.primary.withAlpha(45),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            period.shortName,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : AppTheme.textSecondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 24),

              // Budget input
              _sectionTitle(
                Icons.account_balance_wallet_rounded,
                'ميزانيتك كام؟',
              ),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppTheme.borderLight),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(8),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إجمالي ميزانية ${_selectedPeriod.shortName}',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: _amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.center,
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primary,
                      ),
                      decoration: InputDecoration(
                        hintText: '0',
                        suffixText: 'جنيه',
                        filled: true,
                        fillColor: AppTheme.primary.withAlpha(12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: AppTheme.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'اختيارات سريعة',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _presets.map((amount) {
                        final selected = _currentAmount == amount;

                        return ActionChip(
                          label: Text('${amount.toInt()} ج'),
                          onPressed: () => _selectPreset(amount),
                          backgroundColor: selected
                              ? AppTheme.primary.withAlpha(25)
                              : Colors.white,
                          side: BorderSide(
                            color: selected
                                ? AppTheme.primary
                                : AppTheme.borderLight,
                          ),
                          labelStyle: TextStyle(
                            color: selected
                                ? AppTheme.primary
                                : AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 22),
                    const Divider(),
                    const SizedBox(height: 12),

                    // Family members
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withAlpha(15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.groups_rounded,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'عدد أفراد الأسرة',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'من فرد واحد إلى 15 فردًا',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _memberButton(
                          icon: Icons.remove_rounded,
                          enabled: _familyMembers > 1,
                          onTap: () {
                            setState(() => _familyMembers--);
                          },
                        ),
                        SizedBox(
                          width: 38,
                          child: Text(
                            '$_familyMembers',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                        _memberButton(
                          icon: Icons.add_rounded,
                          enabled: _familyMembers < 15,
                          onTap: () {
                            setState(() => _familyMembers++);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Budget breakdown
              _sectionTitle(
                Icons.analytics_rounded,
                'ملخص ميزانيتك',
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _summaryCard(
                      icon: Icons.today_rounded,
                      title: 'ميزانيتك اليومية',
                      value: '${_dailyEquivalent.toStringAsFixed(0)} ج',
                      subtitle: 'للطبخ يوميًا',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _summaryCard(
                      icon: Icons.person_rounded,
                      title: 'نصيب الفرد',
                      value: '${_perPersonCost.toStringAsFixed(1)} ج',
                      subtitle: 'للفرد يوميًا',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveBudget,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_circle_rounded),
                  label: Text(
                    _isSaving ? 'جاري الحفظ...' : 'حفظ الميزانية',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppTheme.primary.withAlpha(120),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Recipe recommendations
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withAlpha(15),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.restaurant_menu_rounded,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'أكلات تناسب ميزانيتك',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withAlpha(18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${recipes.length}',
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              Text(
                'اقتراحات بناءً على ميزانيتك اليومية.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 14),

              if (_currentAmount <= 0)
                _emptyState(
                  icon: Icons.savings_outlined,
                  title: 'حددي ميزانيتك أولًا',
                  message: 'أدخلي مبلغًا صحيحًا علشان نقدر نقترح أكلات مناسبة.',
                )
              else if (recipes.isEmpty)
                _emptyState(
                  icon: Icons.soup_kitchen_outlined,
                  title: 'محتاجين ميزانية أكبر شوية؟',
                  message:
                      'مفيش وصفات ضمن المبلغ الحالي. جربي ميزانية مختلفة أو أضيفي وصفات بتكلفة محددة.',
                )
              else
                ...recipes.map(
                  (recipe) => RecipeCard(
                    recipe: recipe,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              RecipeDetailScreen(recipe: recipe),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primary, size: 21),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _memberButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return IconButton(
      onPressed: enabled ? onTap : null,
      visualDensity: VisualDensity.compact,
      style: IconButton.styleFrom(
        backgroundColor: enabled
            ? AppTheme.primary.withAlpha(18)
            : Colors.grey.shade100,
        foregroundColor: AppTheme.primary,
        disabledForegroundColor: Colors.grey.shade400,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      icon: Icon(icon, size: 20),
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppTheme.primary.withAlpha(13),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: AppTheme.primary.withAlpha(35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         
        
          Row(
            children: [
               Icon(icon, color: AppTheme.primary, size: 23),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppTheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.primary.withAlpha(15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 42,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              height: 1.6,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
