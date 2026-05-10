import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:just_audio/just_audio.dart';

class RadioAudioService {
  static final RadioAudioService _instance = RadioAudioService._internal();
  factory RadioAudioService() => _instance;
  RadioAudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  AudioPlayer get player => _player;

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  String? _currentUrl;
  String? get currentUrl => _currentUrl;

  void setVolume(double volume) {
    _player.setVolume(volume);
  }

  Future<void> play(String url) async {
    try {
      if (_currentUrl != url) {
        _currentUrl = url;
        await _player.setUrl(url);
      }
      await _player.play();
      _isPlaying = true;
    } catch (e) {
      if (kDebugMode) {
        print("Erro ao reproduzir: $e");
      }
      rethrow;
    }
  }

  Future<void> pause() async {
    await _player.pause();
    _isPlaying = false;
  }

  Future<void> stop() async {
    await _player.stop();
    _isPlaying = false;
  }

  void dispose() {
    _player.dispose();
  }

  Future<void> init() async {
    // Inicialização adicional se necessária
    _player.setVolume(0.7);
  }
}