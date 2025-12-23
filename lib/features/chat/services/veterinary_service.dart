import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import '../../../core/services/ai_service.dart';
import '../models/triage_response.dart';

// Provider for AIService
final aiServiceProvider = Provider((ref) => AIService());

final veterinaryServiceProvider = Provider((ref) => VeterinaryService(ref));

class VeterinaryService {
  final Ref _ref;

  VeterinaryService(this._ref);

  Future<TriageResponse> analyzeSymptoms({
    required String symptoms,
    required Map<String, dynamic> petProfile,
    String? imagePath,
  }) async {
    
    // Detailed System Prompt
    final systemPrompt = '''
You are "PawPath AI", a highly advanced Veterinary Triage Assistant.
Your goal is to assess the severity of the situation and provide a triage recommendation (Red, Yellow, Green).

CONTEXT:
Patient ID: \${petProfile['idNumber'] ?? 'Unknown'}
Name: \${petProfile['name']}
Breed: \${petProfile['breed']}
Age: \${petProfile['age']}
Weight: \${petProfile['weight']} lbs
Chronic Conditions: \${petProfile['chronicConditions'] ?? 'None'}

VISION CAPABILITY:
 \${imagePath != null ? "An image has been provided. Analyze it carefully for visible signs of infection, swelling, trauma, or dermatological issues. Describe what you see before providing advice." : "No image provided."}

SAFETY PROTOCOL (CRITICAL):
- If the user mentions "unresponsive", "pale gums", "bloated stomach", "difficulty breathing", or "hit by car", ALERT IMMEDIATELY.
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

OUTPUT FORMAT (JSON ONLY):
Return ONLY a valid JSON object. Do not include markdown formatting.
{
  "triage_level": "Red", // or "Yellow", "Green"
  "is_emergency": true, // true if Red
  "user_advice": "Your detailed advice here...",
  "reasoning": "Brief clinical reasoning..."
}
''';

    // Construct User Query
    final userQuery = "Symptoms: \$symptoms";

    // Call Real AI Service
    final aiService = _ref.read(aiServiceProvider);
    final response = await aiService.sendMessage(
      userQuery,
      imagePath: imagePath,
      systemPrompt: systemPrompt,
    );

    try {
      // Clean response (remove markdown code blocks if any)
      final cleanJson = response.replaceAll('```json', '').replaceAll('```', '').trim();
      final Map<String, dynamic> jsonMap = jsonDecode(cleanJson);
      return TriageResponse.fromJson(jsonMap);
    } catch (e) {
      // Fallback if JSON parsing fails
      return TriageResponse(
        userAdvice: response,
        triageLevel: 'Yellow', // Default to caution
        isEmergency: false,
        reasoning: "Raw response (Parsing Failed): \$e"
      );
    }
  }
}
