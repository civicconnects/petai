import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyAlertModal extends StatelessWidget {
  final VoidCallback onClose;

  const EmergencyAlertModal({super.key, required this.onClose});

  Future<void> _callVet() async {
    const url = 'tel:911'; // Placeholder for MVP
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFFF3B30),
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.warning_amber_rounded,
                    size: 80, color: Colors.white),
                const SizedBox(height: 24),
                const Text(
                  'POTENTIAL EMERGENCY DETECTED',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Based on the symptoms described, your pet may be in a life-threatening condition. Do not wait.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _callVet,
                    icon: const Icon(Icons.local_hospital, color: Color(0xFFFF3B30)),
                    label: const Text('CALL NEAREST VET',
                        style: TextStyle(
                            color: Color(0xFFFF3B30),
                            fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: onClose,
                  child: const Text(
                    'I understand, close alert',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
