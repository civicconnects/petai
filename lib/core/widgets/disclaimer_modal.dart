import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DisclaimerModal extends StatelessWidget {
  final VoidCallback onAccept;

  const DisclaimerModal({super.key, required this.onAccept});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent dismissing by back button
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 10,
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.amber,
                size: 60,
              ),
              const SizedBox(height: 20),
              Text(
                'Important Safety Notice',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'This app uses Artificial Intelligence to provide veterinary triage advice. It is NOT a replacement for professional veterinary care.\n\nAlways consult a veterinarian for accurate diagnosis and treatment. In emergencies, go to an animal hospital immediately.',
                style: GoogleFonts.openSans(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'I Understand & Accept',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
