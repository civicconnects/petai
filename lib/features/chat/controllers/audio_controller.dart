import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';

// --- State Definition ---
enum AudioState {
  initial,
  listening,
  processing,
  speaking,
  error,
}

class AudioStateModel {
  final AudioState status;
  final String text;
  final String? errorMessage;

  AudioStateModel({
    this.status = AudioState.initial,
    this.text = '',
    this.errorMessage,
  });

  AudioStateModel copyWith({
    AudioState? status,
    String? text,
    String? errorMessage,
  }) {
    return AudioStateModel(
      status: status ?? this.status,
      text: text ?? this.text,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// --- Controller Definition ---
final audioControllerProvider = StateNotifierProvider<AudioController, AudioStateModel>((ref) {
  return AudioController();
});

class AudioController extends StateNotifier<AudioStateModel> {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  AudioController() : super(AudioStateModel()) {
    _init();
  }

  Future<void> _init() async {
    try {
      // Initialize TTS
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.awaitSpeakCompletion(true); // Wait for speech to finish

      _flutterTts.setCompletionHandler(() {
        // Auto-reset to listening or initial when done speaking
        // For now, let's go to initial. 
        // In a "Continuous Mode", we might go back to listening here.
        state = state.copyWith(status: AudioState.initial);
      });
      
    } catch (e) {
      print("Audio Init Error: $e");
    }
  }

  Future<void> startListening() async {
    // 1. Permission Check
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
      if (!status.isGranted) {
        state = state.copyWith(
          status: AudioState.error, 
          errorMessage: 'Microphone permission denied'
        );
        return;
      }
    }

    // 2. Initialize STT (Re-init each time can allow for "fresh" session behavior)
    if (!_isInitialized) {
      _isInitialized = await _speechToText.initialize(
        onError: (val) => state = state.copyWith(
          status: AudioState.error, 
          errorMessage: val.errorMsg
        ),
      );
    }

    if (_isInitialized) {
      state = state.copyWith(status: AudioState.listening, text: '');
      
      await _speechToText.listen(
        onResult: (result) {
          state = state.copyWith(text: result.recognizedWords);
          
          if (result.finalResult) {
            // Stop listening automatically on final result
            stopListening(); 
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 5),
        cancelOnError: true,
      );
    } else {
      state = state.copyWith(
        status: AudioState.error, 
        errorMessage: 'Speech recognition not available'
      );
    }
  }

  Future<void> stopListening() async {
    await _speechToText.stop();
    // Transition to processing state if we have text
    if (state.text.isNotEmpty) {
      state = state.copyWith(status: AudioState.processing);
    } else {
      state = state.copyWith(status: AudioState.initial);
    }
  }

  Future<void> speak(String text) async {
    state = state.copyWith(status: AudioState.speaking);
    await _flutterTts.speak(text);
    // Completion handler set in _init will handle state reset
  }

  void reset() {
    state = AudioStateModel(status: AudioState.initial);
  }
}
