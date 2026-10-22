import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  final showOnboarding = !StorageService.hasSeenOnboarding();
  runApp(MatebakhnaApp(showOnboarding: showOnboarding));
}

class MatebakhnaApp extends StatelessWidget {
  final bool showOnboarding;
  const MatebakhnaApp({super.key, this.showOnboarding = true});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'طبختنا - ميزانية ووصفات أكل',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: const Locale('ar', 'EG'),
      supportedLocales: const [
        Locale('ar', 'EG'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: showOnboarding ? const OnboardingScreen() : const HomeScreen(),
    );
  }
}
