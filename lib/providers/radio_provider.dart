import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/station_model.dart';
import '../services/radio_audio_service.dart';
import '../data/stations_data.dart';

class RadioProvider extends ChangeNotifier {
  final RadioAudioService _audioService = RadioAudioService();

  List<Station> _stations = [];
  List<Station> get stations => _stations;

  Station? _currentStation;
  Station? get currentStation => _currentStation;

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  double _volume = 0.7;
  double get volume => _volume;

  int _listenSeconds = 0;
  int get listenSeconds => _listenSeconds;
  Timer? _listenTimer;

  Set<int> _favoriteIds = {};
  Set<int> get favoriteIds => _favoriteIds;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _selectedCategory = 'todas';
  String get selectedCategory => _selectedCategory;

  final Map<int, bool?> _streamStatus = {};
  Map<int, bool?> get streamStatus => _streamStatus;

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  RadioProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    _stations = StationsData.getStations();
    _audioService.addListener(_onAudioStateChanged);
    await _audioService.init();
    await _loadPreferences();
    notifyListeners();
  }

  void _onAudioStateChanged() {
    _isPlaying = _audioService.isPlaying;
    if (!_isPlaying) {
      _stopListenTimer();
    }
    notifyListeners();
  }

  bool get isBuffering => _audioService.isBuffering;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  List<Station> get filteredStations {
    return _stations.where((station) {
      bool matchCategory = _selectedCategory == 'todas' ||
          station.categoria == _selectedCategory;
      bool matchSearch = _searchQuery.isEmpty ||
          station.nome.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          station.desc.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchCategory && matchSearch;
    }).toList();
  }

  List<Station> get favoriteStations {
    return _stations.where((s) => _favoriteIds.contains(s.id)).toList();
  }

  Future<void> setCurrentStation(Station station) async {
    if (_currentStation?.id == station.id) return;

    _currentStation = station;
    _resetListenTimer();
    await _saveLastStation();
    notifyListeners();
  }

  Future<void> playCurrentStation() async {
    if (_currentStation == null) return;

    if (_isPlaying) {
      await _audioService.pause();
      _stopListenTimer();
    } else {
      String streamUrl = _currentStation!.urlStream;
      if (streamUrl == "#" || streamUrl.isEmpty) {
        debugPrint('Stream indisponível para ${_currentStation!.nome}');
        return;
      }

      try {
        await _audioService.play(streamUrl);
        _startListenTimer();
      } catch (e) {
        debugPrint("Erro ao iniciar stream: $e");
      }
    }
  }

  void togglePlayPause() async {
    if (_currentStation == null) return;

    if (_isPlaying) {
      await _audioService.pause();
      _stopListenTimer();
    } else {
      await playCurrentStation();
    }
  }

  void setVolume(double value) {
    _volume = value.clamp(0.0, 1.0);
    _audioService.setVolume(_volume);
    _saveVolume();
    notifyListeners();
  }

  void playPrevious() {
    if (_stations.isEmpty || _currentStation == null) return;
    int currentIndex = _stations.indexWhere((s) => s.id == _currentStation!.id);
    int prevIndex = currentIndex - 1;
    if (prevIndex < 0) prevIndex = _stations.length - 1;
    _playNewStation(_stations[prevIndex]);
  }

  void playNext() {
    if (_stations.isEmpty || _currentStation == null) return;
    int currentIndex = _stations.indexWhere((s) => s.id == _currentStation!.id);
    int nextIndex = (currentIndex + 1) % _stations.length;
    _playNewStation(_stations[nextIndex]);
  }

  Future<void> _playNewStation(Station station) async {
    bool wasPlaying = _isPlaying;
    await setCurrentStation(station);
    if (wasPlaying) {
      await playCurrentStation();
    }
  }

  void _startListenTimer() {
    _stopListenTimer();
    _listenTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _listenSeconds++;
      notifyListeners();
    });
  }

  void _stopListenTimer() {
    _listenTimer?.cancel();
    _listenTimer = null;
  }

  void _resetListenTimer() {
    _stopListenTimer();
    _listenSeconds = 0;
    if (_isPlaying) {
      _startListenTimer();
    }
    notifyListeners();
  }

  void toggleFavorite(Station station) {
    if (_favoriteIds.contains(station.id)) {
      _favoriteIds.remove(station.id);
    } else {
      _favoriteIds.add(station.id);
    }
    _saveFavorites();
    notifyListeners();
  }

  bool isFavorite(Station station) => _favoriteIds.contains(station.id);

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveTheme();
    notifyListeners();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    final favoritesList = prefs.getStringList('favorites');
    if (favoritesList != null) {
      _favoriteIds = favoritesList.map(int.parse).toSet();
    }

    _volume = prefs.getDouble('volume') ?? 0.7;
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;

    _audioService.setVolume(_volume);

    final lastStationId = prefs.getInt('lastStationId');
    if (lastStationId != null) {
      _currentStation = _stations.firstWhere(
        (s) => s.id == lastStationId,
        orElse: () => _stations.first,
      );
    } else {
      _currentStation = _stations.first;
    }

    debugPrint(
        '✅ Preferências carregadas: ${favoriteStations.length} favoritos');
  }

  Future<void> _saveLastStation() async {
    final prefs = await SharedPreferences.getInstance();
    if (_currentStation != null) {
      await prefs.setInt('lastStationId', _currentStation!.id);
    }
  }

  Future<void> _saveVolume() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('volume', _volume);
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favs = _favoriteIds.map((id) => id.toString()).toList();
    await prefs.setStringList('favorites', favs);
  }

  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  void resetListenSeconds() {
    _listenSeconds = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _stopListenTimer();
    _audioService.dispose();
    super.dispose();
  }
}
