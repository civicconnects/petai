import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'core/widgets/disclaimer_modal.dart';

void main() {
  runApp(const ProviderScope(child: PetAiApp()));
}

class PetAiApp extends StatefulWidget {
  const PetAiApp({super.key});

  @override
  State<PetAiApp> createState() => _PetAiAppState();
}

class _PetAiAppState extends State<PetAiApp> {
  bool _disclaimerAccepted = false;

  void _acceptDisclaimer() {
    setState(() {
      _disclaimerAccepted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PawPath AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A90E2), // Calming Blue
          secondary: const Color(0xFF50E3C2), // Calming Teal
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.openSansTextTheme(),
      ),
      home: _disclaimerAccepted
          ? const OnboardingScreen()
          : DisclaimerScreen(onAccept: _acceptDisclaimer),
    );
  }
}

class DisclaimerScreen extends StatelessWidget {
  final VoidCallback onAccept;

  const DisclaimerScreen({super.key, required this.onAccept});

  @override
  Widget build(BuildContext context) {
    // Show the modal immediately on a blank/scaffold background
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => DisclaimerModal(
          onAccept: () {
            Navigator.of(context).pop(); // Close dialog
            onAccept();
          },
        ),
      );
    });

    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
