import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:io';

class AIService {
  // TODO: User must replace this with their own API Key
  static const String apiKey = 'AIzaSyD1sKXkXSxSCxngQF6wngVqxvnMCJZvtzk';
  
  late final GenerativeModel _model;
  
  AIService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash', 
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.4, // Low temperature for more clinical/deterministic responses
        maxOutputTokens: 500,
      ),
    );
  }

  Future<String> sendMessage(String text, {String? imagePath, required String systemPrompt}) async {
    try {
      final content = [
        Content.text(systemPrompt),
        Content.text(text),
      ];

      if (imagePath != null) {
        final imageFile = File(imagePath);
        if (await imageFile.exists()) {
          final imageBytes = await imageFile.readAsBytes();
          content.add(Content.data('image/jpeg', imageBytes));
        }
      }

      final response = await _model.generateContent(content);
      return response.text ?? "I'm having trouble analyzing that right now. Please try again.";
    } catch (e) {
      if (e.toString().contains('API_KEY_INVALID')) {
        return "Error: Invalid API Key. Please update the API Key in lib/core/services/ai_service.dart";
      }
      return "AI connection error: \${e.toString()}";
    }
  }
}
