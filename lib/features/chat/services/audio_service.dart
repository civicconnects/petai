import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

final audioServiceProvider = Provider((ref) => AudioService());

class AudioService {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeechInitialized = false;

  Future<void> init() async {
    // Request microphone permission
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      // Handle permission denied
      return;
    }

    _isSpeechInitialized = await _speechToText.initialize();
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> startListening({required Function(String) onResult}) async {
    if (!_isSpeechInitialized) {
      await init();
    }
    
    if (_isSpeechInitialized) {
      await _speechToText.listen(onResult: (result) {
        onResult(result.recognizedWords);
      });
    }
  }

  Future<void> stopListening() async {
    await _speechToText.stop();
  }

  Future<void> speak(String text) async {
    await _flutterTts.speak(text);
  }

  Future<void> stopSpeaking() async {
    await _flutterTts.stop();
  }

  bool get isListening => _speechToText.isListening;
}
