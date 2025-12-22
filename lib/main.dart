import 'package:flutter/material.dart';
import 'features/onboarding/screens/onboarding_screen.dart';

void main() {
  runApp(const PetAiApp());
}

class PetAiApp extends StatelessWidget {
  const PetAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pet AI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const OnboardingScreen(),
    );
  }
}
