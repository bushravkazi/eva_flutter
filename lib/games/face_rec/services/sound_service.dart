import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  AudioPlayer? _player;
  bool _initialized = false;

  // Reliable MP3 victory sound URL
  static const String victoryMp3Url =
      'https://assets.mixkit.co/active_storage/sfx/2000/2000-preview.mp3';

  void init() {
    try {
      _player = AudioPlayer();
      _initialized = true;
    } catch (e) {
      if (kDebugMode) {
        print("AudioPlayer initialization warning: $e");
      }
      _initialized = false;
    }
  }

  /// Play victory MP3 sound after level completion
  Future<void> playVictorySound() async {
    try {
      if (_player == null) {
        _player = AudioPlayer();
        _initialized = true;
      }
      if (_initialized && _player != null) {
        await _player?.stop();
        await _player?.play(UrlSource(victoryMp3Url));
      }
    } catch (e) {
      if (kDebugMode) {
        print("Victory sound playback error: $e");
      }
    }
  }
}

