import 'package:flutter/material.dart';
import 'screens/onboarding_screen.dart';
import 'styles.dart';

void main() {
  runApp(PsychInsightPro());
}

class PsychInsightPro extends StatelessWidget {
  const PsychInsightPro({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PsychInsightPro',
      theme: AppStyles.lightTheme,
      darkTheme: AppStyles.darkTheme,
      themeMode: ThemeMode.system,
      home: OnboardingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
