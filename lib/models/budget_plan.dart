enum BudgetPeriod {
  daily('ميزانية يومية', 'اليوم', 1),
  weekly('ميزانية أسبوعية', 'الأسبوع', 7),
  monthly('ميزانية شهرية', 'الشهر', 30);

  final String title;
  final String shortName;
  final int days;
  const BudgetPeriod(this.title, this.shortName, this.days);
}

class BudgetPlan {
  final BudgetPeriod period;
  final double totalBudget;
  final int familyMembers;

  const BudgetPlan({
    required this.period,
    required this.totalBudget,
    this.familyMembers = 4,
  });

  /// ميزانية اليوم الواحد
  double get dailyBudget => totalBudget / period.days;

  /// ميزانية الفرد في اليوم
  double get perPersonDailyBudget =>
      familyMembers > 0 ? (dailyBudget / familyMembers) : dailyBudget;

  Map<String, dynamic> toJson() => {
        'period': period.name,
        'totalBudget': totalBudget,
        'familyMembers': familyMembers,
      };

  factory BudgetPlan.fromJson(Map<String, dynamic> json) => BudgetPlan(
        period: BudgetPeriod.values.firstWhere(
          (p) => p.name == json['period'],
          orElse: () => BudgetPeriod.daily,
        ),
        totalBudget: (json['totalBudget'] as num?)?.toDouble() ?? 150.0,
        familyMembers: json['familyMembers'] as int? ?? 4,
      );
}
