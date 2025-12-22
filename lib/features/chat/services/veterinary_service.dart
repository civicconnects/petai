import 'package:flutter_riverpod/flutter_riverpod.dart';

final veterinaryServiceProvider = Provider((ref) => VeterinaryService());

class VeterinaryService {
  // Mock API call for now, can be replaced with http call to OpenAI/Claude
  Future<String> analyzeSymptoms({
    required String symptoms,
    required Map<String, dynamic> petProfile,
    String? imagePath, // Support for vision
  }) async {
    // Simulate Network Delay
    await Future.delayed(const Duration(seconds: 2));

    // Refined System Prompt V2.0
    final systemPrompt = '''
You are "PawPath AI", a highly advanced Veterinary Triage Assistant.
Your goal is to assess the severity of the situation and provide a triage recommendation (Red, Yellow, Green).

CONTEXT:
Patient ID: ${petProfile['idNumber'] ?? 'Unknown'}
Name: ${petProfile['name']}
Breed: ${petProfile['breed']}
Age: ${petProfile['age']}
Weight: ${petProfile['weight']} lbs
Chronic Conditions: ${petProfile['chronicConditions'] ?? 'None'}

VISION CAPABILITY:
 ${imagePath != null ? "An image has been provided. Analyze it for visible signs of infection, swelling, trauma, or dermatological issues. Describe what you see before providing advice." : "No image provided."}

SAFETY PROTOCOL (CRITICAL):
- If the user mentions "unresponsive", "pale gums", "bloated stomach", "difficulty breathing", or "hit by car", STOP immediately.
- Instruct them to go to the Emergency Vet IMMEDIATELY.
- Do not provide home remedies for life-threatening conditions.

INSTRUCTIONS:
1. Analyze the symptoms + image (if any).
2. Determine Triage Level:
   - [RED] Immediate Emergency
   - [YELLOW] Semi-Urgent (See vet within 24h)
   - [GREEN] Non-Urgent (Monitor at home)
3. Provide a concise Action Plan.
4. Maintain a professional, clinical, yet empathetic tone.
''';

    // Mock Response Logic based on Keywords
    final lowerSymptoms = symptoms.toLowerCase();
    
    if (lowerSymptoms.contains('bloat') || lowerSymptoms.contains('stomach') || lowerSymptoms.contains('unresponsive')) {
      return "[RED ALERT] IMMEDIATE VETERINARY ACTION REQUIRED.\n\n"
          "The symptoms you described (possible Bloat/GDV) are life-threatening. "
          "Do not wait. Transport ${petProfile['name']} to the nearest Emergency Vet immediately.";
    }

    if (imagePath != null) {
      return "I have analyzed the image and your description.\n\n"
          "Observation: The image appears to show localized redness and possible swelling consistent with a minor abrasion or hot spot.\n\n"
          "Triage Level: [GREEN] Non-Urgent\n\n"
          "Assessment: This looks like a minor skin irritation. Keep the area clean and prevent ${petProfile['name']} from licking it. Monitor for worsening swelling or discharge.";
    }

    return "Based on the symptoms ($symptoms) for a ${petProfile['age']}yo ${petProfile['breed']}:\n\n"
        "Triage Level: [YELLOW] Semi-Urgent\n\n"
        "Assessment: This could indicate a mild gastrointestinal upset. \n"
        "Action Plan: Withhold food for 12 hours, keep water available. If vomiting continues, see your vet tomorrow.";
  }
}
