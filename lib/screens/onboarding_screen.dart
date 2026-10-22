import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingSlideData> _slides = const [
    OnboardingSlideData(
      badge: '🍲 مرحباً بكِ في طبختنا',
      title: 'دليلكِ الذكي لوصفات الأكل والمطبخ البيتي',
      description:
          'كل ما تحتاجينه لإعداد أشهى الأطباق التراثية والمصرية والشعبية والغربية والحلويات، بمقادير مجربة ومكونات متوفرة في كل بيت.',
      heroEmoji: '🍲',
      heroSecondaryEmoji: '👨‍🍳',
      features: [
        OnboardingFeature(
          icon: '📖',
          title: 'وصفات مشروحة خطوة بخطوة',
          subtitle: 'طريقة تحضير واضحة تضمن نجاح أكلتك من أول مرة',
        ),
        OnboardingFeature(
          icon: '⏱️',
          title: 'الوقت والمقادير بدقة',
          subtitle: 'معرفة وقت التحضير والتسوية وعدد الأفراد لكل وجبة',
        ),
      ],
    ),
    OnboardingSlideData(
      badge: '💡 حل سؤال: هنطبخ إيه النهاردة؟',
      title: 'أكلة اليوم المقترحة وعلى قد ميزانيتك',
      description:
          'مش هتحتاري في أكل النهاردة! اقتراحات يومية متجددة لوجبات الغداء مع تصنيف دقيق للوجبات الموفرة لتنظيم ميزانية بيتك بكل شطارة.',
      heroEmoji: '⭐',
      heroSecondaryEmoji: '🪙',
      features: [
        OnboardingFeature(
          icon: '🌟',
          title: 'أكلة اليوم المقترحة',
          subtitle: 'اقتراح مميز جاهز يوفّر عليكِ حيرة التفكير يومياً',
        ),
        OnboardingFeature(
          icon: '🪙',
          title: 'أكلات اقتصادية على قد الإيد',
          subtitle: 'أطباق شهية ومغذية بتكلفة مناسبة لميزانية البيت',
        ),
      ],
    ),
  ];

  Future<void> _finishOnboarding() async {
    await StorageService.setSeenOnboarding();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Skip Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          'assets/images/logo.jpg',
                          width: 34,
                          height: 34,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Text('🔥', style: TextStyle(fontSize: 24)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'طبختنا',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _finishOnboarding,
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.textSecondary,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    ),
                    child: const Text(
                      'تخطي',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            // Page View with Slides
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 12),
                        // Hero Illustration Box
                        Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 170,
                                height: 170,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      AppTheme.primary.withAlpha(45),
                                      AppTheme.secondary.withAlpha(20),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                width: 130,
                                height: 130,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(color: AppTheme.primary.withAlpha(50), width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primary.withAlpha(30),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  slide.heroEmoji,
                                  style: const TextStyle(fontSize: 64),
                                ),
                              ),
                              Positioned(
                                bottom: 10,
                                right: 18,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppTheme.borderLight),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withAlpha(15),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    slide.heroSecondaryEmoji,
                                    style: const TextStyle(fontSize: 22),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Badge Tag
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withAlpha(20),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.primary.withAlpha(50)),
                          ),
                          child: Text(
                            slide.badge,
                            style: const TextStyle(
                              color: AppTheme.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Slide Title
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textPrimary,
                            height: 1.35,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Slide Description
                        Text(
                          slide.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            height: 1.6,
                          ),
                        ),

                        const SizedBox(height: 22),

                        // Feature Highlight Cards
                        ...slide.features.map(
                          (f) => Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.borderLight),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(6),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppTheme.background,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(f.icon, style: const TextStyle(fontSize: 22)),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        f.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        f.subtitle,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Navigation Area: Indicators and Primary Button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(12),
                    blurRadius: 12,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Dot Indicators
                  Row(
                    children: List.generate(_slides.length, (i) {
                      final isActive = _currentPage == i;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(left: 6),
                        width: isActive ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive ? AppTheme.primary : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),

                  const Spacer(),

                  // Primary Next/Start Button
                  ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: AppTheme.primary.withAlpha(100),
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _currentPage == _slides.length - 1 ? 'ابدأي الطبخ الآن 🚀' : 'التالي »',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
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
    );
  }
}

class OnboardingSlideData {
  final String badge;
  final String title;
  final String description;
  final String heroEmoji;
  final String heroSecondaryEmoji;
  final List<OnboardingFeature> features;

  const OnboardingSlideData({
    required this.badge,
    required this.title,
    required this.description,
    required this.heroEmoji,
    required this.heroSecondaryEmoji,
    required this.features,
  });
}

class OnboardingFeature {
  final String icon;
  final String title;
  final String subtitle;

  const OnboardingFeature({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}
