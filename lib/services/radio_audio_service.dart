import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';

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

  bool _isBuffering = false;
  bool get isBuffering => _isBuffering;

  final List<void Function()> _listeners = [];

  void addListener(void Function() listener) {
    _listeners.add(listener);
  }

  void removeListener(void Function() listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }

  Future<void> init() async {
    await _player.setVolume(0.7);

    _player.playbackEventStream.listen((event) {
      _isPlaying = _player.playing;
      _notifyListeners();
    });

    _player.playerStateStream.listen((state) {
      final isBufferingNow = state.processingState == ProcessingState.buffering;
      if (_isBuffering != isBufferingNow) {
        _isBuffering = isBufferingNow;
        _notifyListeners();
      }

      if (kDebugMode) {
        print(
            'Player state: ${state.processingState}, buffering: $_isBuffering');
      }
    });
  }

  Future<void> play(String url) async {
    try {
      if (_currentUrl != url) {
        _currentUrl = url;
        await _player.setUrl(url);
      }
      await _player.play();
      _isPlaying = true;
      _notifyListeners();
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
    _notifyListeners();
  }

  Future<void> stop() async {
    await _player.stop();
    _isPlaying = false;
    _notifyListeners();
  }

  void setVolume(double volume) {
    _player.setVolume(volume);
  }

  void dispose() {
    _player.dispose();
  }
}
