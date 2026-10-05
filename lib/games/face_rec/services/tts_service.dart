import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Text-to-Speech (TTS) Service configured for English with Indian accent ("en-IN").
class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal();

  FlutterTts? _flutterTts;
  bool _initialized = false;
  bool enabled = true;

  Future<void> init() async {
    if (_initialized && _flutterTts != null) return;
    try {
      _flutterTts = FlutterTts();
      _initialized = true;

      // Configure volume, speech rate, and pitch for elderly accessibility
      await _flutterTts?.setVolume(1.0);
      await _flutterTts?.setSpeechRate(0.45);
      await _flutterTts?.setPitch(1.0);

      // On iOS, force audio output through speaker even if physical silent switch is enabled
      if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.iOS)) {
        await _flutterTts?.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [
            IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
            IosTextToSpeechAudioCategoryOptions.mixWithOthers,
          ],
        );
      }

      // Configure Android TTS completion wait
      if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.android)) {
        await _flutterTts?.awaitSpeakCompletion(true);
      }

      await _configureLanguage();
    } catch (e) {
      if (kDebugMode) {
        print("TTS Service init warning: $e");
      }
      _initialized = true;
    }
  }

  /// Configures speech engine for Indian English accent ("en-IN") with fallback
  Future<void> _configureLanguage() async {
    if (_flutterTts == null) return;
    try {
      final isAvailable = await _flutterTts?.isLanguageAvailable("en-IN");
      if (isAvailable == true) {
        await _flutterTts?.setLanguage("en-IN");
        return;
      }
    } catch (_) {}

    try {
      await _flutterTts?.setLanguage("en_IN");
      return;
    } catch (_) {}

    try {
      await _flutterTts?.setLanguage("en-IND");
      return;
    } catch (_) {}

    // Fallback to standard English if en-IN is unavailable on host device
    try {
      await _flutterTts?.setLanguage("en-US");
    } catch (_) {}
  }

  /// Speaks the given English text aloud using Indian English accent
  Future<void> speak(String text) async {
    if (!enabled || text.trim().isEmpty) return;
    try {
      if (_flutterTts == null || !_initialized) {
        await init();
      }
      if (_flutterTts != null) {
        await _flutterTts?.stop();
        await _flutterTts?.setVolume(1.0);
        await _configureLanguage();

        final result = await _flutterTts?.speak(text);
        if (kDebugMode) {
          print("TTS speak result: $result for English text: $text");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("TTS Speak error: $e");
      }
    }
  }

  Future<void> stop() async {
    try {
      if (_flutterTts != null) {
        await _flutterTts?.stop();
      }
    } catch (e) {
      // Ignored
    }
  }
}
