import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'station_model.dart';
import 'radio_audio_service.dart';

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

  bool _isFirstLaunch = false;
  bool get isFirstLaunch => _isFirstLaunch;

  // Status de conectividade das streams
  final Map<int, bool?> _streamStatus = {};
  Map<int, bool?> get streamStatus => _streamStatus;
  final Map<int, bool> _isChecking = {};

  RadioProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    _stations = _getStationsData();
    await _audioService.init();
    await _checkFirstLaunch();
    await _loadFavorites();
    await _loadLastStation();
    await _loadVolume();
    await _loadStreamStatusCache();
    notifyListeners();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final bool hasLaunchedBefore =
        prefs.getBool('has_launched_before') ?? false;

    if (!hasLaunchedBefore) {
      _isFirstLaunch = true;
      await prefs.setBool('has_launched_before', true);
      debugPrint("🎉 Primeira vez que o app é aberto!");
      _currentStation = _stations.first;
      debugPrint("📻 Estação padrão definida: ${_currentStation!.nome}");
    } else {
      _isFirstLaunch = false;
      debugPrint("👋 App já foi aberto antes");
    }
  }

  void setCurrentStation(Station station) {
    if (_currentStation?.id == station.id) return;
    _currentStation = station;
    _resetListenTimer();
    _saveLastStation();
    notifyListeners();
  }

  void togglePlayPause() async {
    if (_currentStation == null) return;

    if (_isPlaying) {
      await _audioService.pause();
      _stopListenTimer();
    } else {
      String streamUrl = _currentStation!.urlStream;
      if (streamUrl == "#" || streamUrl.isEmpty) {
        debugPrint("Stream indisponível para: ${_currentStation!.nome}");
        _showStreamUnavailableMessage();
        return;
      }

      // Verificar status antes de tentar tocar
      bool? isOnline =
          await checkStreamStatus(_currentStation!, forceRefresh: true);
      if (isOnline != true) {
        _showStreamOfflineMessage();
        return;
      }

      try {
        await _audioService.play(streamUrl);
        _startListenTimer();
      } catch (e) {
        debugPrint("Erro ao iniciar stream: $e");
        _showStreamErrorMessage();
      }
    }
    _isPlaying = _audioService.isPlaying;
    notifyListeners();
  }

  void _showStreamUnavailableMessage() {
    // Será mostrado via snackbar ou dialog na UI
    debugPrint("Stream indisponível");
  }

  void _showStreamOfflineMessage() {
    debugPrint("Estação offline");
  }

  void _showStreamErrorMessage() {
    debugPrint("Erro ao conectar");
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
    int prevIndex = (currentIndex - 1) % _stations.length;
    setCurrentStation(_stations[prevIndex]);
    if (_isPlaying) {
      _audioService.stop().then((_) {
        togglePlayPause();
      });
    }
  }

  void playNext() {
    if (_stations.isEmpty || _currentStation == null) return;
    int currentIndex = _stations.indexWhere((s) => s.id == _currentStation!.id);
    int nextIndex = (currentIndex + 1) % _stations.length;
    setCurrentStation(_stations[nextIndex]);
    if (_isPlaying) {
      _audioService.stop().then((_) {
        togglePlayPause();
      });
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

  List<Station> get favoriteStations {
    return _stations.where((s) => _favoriteIds.contains(s.id)).toList();
  }

  // ==================== VERIFICAÇÃO DE STREAM ====================

  Future<bool?> checkStreamStatus(Station station,
      {bool forceRefresh = false}) async {
    if (station.urlStream == "#" || station.urlStream.isEmpty) {
      _streamStatus[station.id] = false;
      return false;
    }

    if (!forceRefresh &&
        _streamStatus.containsKey(station.id) &&
        _streamStatus[station.id] != null) {
      return _streamStatus[station.id];
    }

    if (_isChecking[station.id] == true) {
      return _streamStatus[station.id];
    }

    _isChecking[station.id] = true;
    notifyListeners();

    bool? isOnline = await _testStreamUrl(station.urlStream);

    _streamStatus[station.id] = isOnline;
    _isChecking[station.id] = false;
    await _saveStreamStatusCache();
    notifyListeners();

    return isOnline;
  }

  Future<bool> _testStreamUrl(String url) async {
    // Implementação simples de teste de conectividade
    // Em produção, use um head request ou similar
    try {
      final Uri uri = Uri.parse(url);
      if (uri.scheme == "https" || uri.scheme == "http") {
        // Retorna true para URLs válidas por enquanto
        // Para teste real, use http.head
        return true;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  bool isCheckingStream(int stationId) {
    return _isChecking[stationId] == true;
  }

  Future<void> checkAllStationsConcurrently({int concurrency = 5}) async {
    final stationsToCheck = _stations
        .where((s) => s.urlStream != "#" && s.urlStream.isNotEmpty)
        .toList();

    for (int i = 0; i < stationsToCheck.length; i += concurrency) {
      final batch = stationsToCheck.skip(i).take(concurrency);
      await Future.wait(batch
          .map((station) => checkStreamStatus(station, forceRefresh: true)));
    }
  }

  Future<void> _saveStreamStatusCache() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, bool> cache = {};
    _streamStatus.forEach((id, status) {
      if (status != null) {
        cache[id.toString()] = status;
      }
    });
    await prefs.setString('stream_status_cache', cache.toString());
  }

  Future<void> _loadStreamStatusCache() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cacheStr = prefs.getString('stream_status_cache');
    if (cacheStr != null && cacheStr.isNotEmpty) {
      // Parse do cache - implementação simplificada
      debugPrint("📡 Cache de status carregado");
    }
  }

  // ==================== MÉTODOS PARA SALVAR ESTADO ====================

  Future<void> _saveLastStation() async {
    final prefs = await SharedPreferences.getInstance();
    if (_currentStation != null) {
      await prefs.setInt('last_station_id', _currentStation!.id);
      debugPrint("💾 Última estação salva: ${_currentStation!.nome}");
    }
  }

  Future<void> _loadLastStation() async {
    final prefs = await SharedPreferences.getInstance();
    final int? lastStationId = prefs.getInt('last_station_id');

    if (lastStationId != null) {
      final station = _stations.firstWhere(
        (s) => s.id == lastStationId,
        orElse: () => _stations.first,
      );
      _currentStation = station;
      debugPrint("📻 Última estação carregada: ${station.nome}");
    } else {
      _currentStation = _stations.first;
      debugPrint("📻 Estação padrão carregada: ${_stations.first.nome}");
    }
  }

  Future<void> _saveVolume() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('volume', _volume);
  }

  Future<void> _loadVolume() async {
    final prefs = await SharedPreferences.getInstance();
    final double? savedVolume = prefs.getDouble('volume');
    if (savedVolume != null) {
      _volume = savedVolume;
      _audioService.setVolume(_volume);
      debugPrint("🔊 Volume carregado: $_volume");
    }
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? favs = prefs.getStringList('radio_favorites');
    if (favs != null) {
      _favoriteIds = favs.map(int.parse).toSet();
      debugPrint("❤️ Favoritos carregados: ${_favoriteIds.length} estações");
    }
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favs = _favoriteIds.map((id) => id.toString()).toList();
    await prefs.setStringList('radio_favorites', favs);
  }

  Future<void> restoreLastSession() async {
    await _checkFirstLaunch();
    await _loadLastStation();
    await _loadVolume();
    debugPrint("✅ Sessão restaurada: ${_currentStation?.nome ?? 'nenhuma'}");
    notifyListeners();
  }

  void resetListenSeconds() {
    _listenSeconds = 0;
    notifyListeners();
  }

  void forceUpdate() {
    notifyListeners();
  }

  @override
  void dispose() {
    _stopListenTimer();
    _audioService.dispose();
    super.dispose();
  }

  static List<Station> _getStationsData() {
    return [
      // ==================== NACIONAL / PRINCIPAIS ====================
      Station(
        id: 0,
        nome: "Radio Mocambique",
        categoria: "Notícias",
        desc: "Empresa pública de radiodifusão",
        regiao: "Nacional",
        imagem: "https://placehold.co/400/8e4b4c/white?text=RM",
        urlStream: "https://stream.zeno.fm/tskpv4vscv8uv",
      ),
      Station(
        id: 1,
        nome: "Radio Mocambique (alt)",
        categoria: "Notícias",
        desc: "Empresa pública de radiodifusão",
        regiao: "Nacional",
        imagem: "https://placehold.co/400/8e4b4c/white?text=RM2",
        urlStream: "https://node.stream-africa.com:8443/AntenaNacional",
      ),
      Station(
        id: 2,
        nome: "RM Desporto",
        categoria: "Desporto",
        desc: "Canal de desporto - A Rádio dos Campeões",
        regiao: "Nacional",
        imagem: "https://placehold.co/400/2c6e2c/white?text=RMD",
        urlStream: "https://node.stream-africa.com:8443/RMDesporto",
      ),
      Station(
        id: 3,
        nome: "99 FM",
        categoria: "Música",
        desc: "Connecting - Rádio generalista",
        regiao: "Nacional",
        imagem: "https://placehold.co/400/FF8C00/white?text=99FM",
        urlStream: "https://streaming2.99fm.co.mz/stream",
      ),
      Station(
        id: 4,
        nome: "Rádio Miramar",
        categoria: "Rock",
        desc: "Em boa companhia - Rádio privada",
        regiao: "Nacional",
        imagem: "https://placehold.co/400/4682B4/white?text=Miramar",
        urlStream: "https://nl.digitalrm.pt:8150/stream",
      ),
      Station(
        id: 5,
        nome: "Rádio Miramar (alt)",
        categoria: "Rock",
        desc: "Em boa companhia",
        regiao: "Nacional",
        imagem: "https://placehold.co/400/4682B4/white?text=Miramar2",
        urlStream: "https://nl.digitalrm.pt:8066/stream",
      ),
      Station(
        id: 6,
        nome: "Super FM",
        categoria: "Pop",
        desc: "Música elevada ao infinito",
        regiao: "Nacional",
        imagem: "https://placehold.co/400/8B4513/white?text=Super",
        urlStream: "http://41.223.153.14:8000/",
      ),
      Station(
        id: 7,
        nome: "Radio Moçambique Gospel",
        categoria: "Gospel",
        desc: "Fé, esperança e louvor",
        regiao: "Nacional",
        imagem: "https://placehold.co/400/556B2F/white?text=RMGospel",
        urlStream: "https://stream.zeno.fm/12q9fqsxbg8uv",
      ),
      Station(
        id: 8,
        nome: "LM Radio",
        categoria: "Easy-Listening",
        desc: "Happy Listening - Estação histórica",
        regiao: "Nacional",
        imagem: "https://placehold.co/400/1a237e/white?text=LM",
        urlStream: "#",
      ),

      // ==================== SUL ====================
      Station(
        id: 9,
        nome: "Emissão Provincial Maputo",
        categoria: "Comunitária",
        desc: "Hoje e sempre projetando Moçambique",
        regiao: "Sul",
        imagem: "https://placehold.co/400/004d40/white?text=Maputo",
        urlStream: "https://node.stream-africa.com:8443/MaputoFM",
      ),
      Station(
        id: 10,
        nome: "Emissão Provincial Maputo (alt)",
        categoria: "Comunitária",
        desc: "Hoje e sempre projetando Moçambique",
        regiao: "Sul",
        imagem: "https://placehold.co/400/004d40/white?text=Maputo2",
        urlStream: "http://node.stream-africa.com:8000/MaputoFM",
      ),
      Station(
        id: 11,
        nome: "Rádio Cidade",
        categoria: "Música",
        desc: "Mais Radio Do Rovuma a Maputo",
        regiao: "Sul",
        imagem: "https://placehold.co/400/e65100/white?text=Cidade",
        urlStream: "https://node.stream-africa.com:8443/RadioCidadeMaputo",
      ),
      Station(
        id: 12,
        nome: "Maputo Corridor Radio",
        categoria: "Notícias",
        desc: "Your News and Music Station - English Service",
        regiao: "Sul",
        imagem: "https://placehold.co/400/0d47a1/white?text=Corridor",
        urlStream: "https://node.stream-africa.com:8443/MaputoCorridor",
      ),
      Station(
        id: 13,
        nome: "Emissora Provincial de Gaza",
        categoria: "Comunitária",
        desc: "Do Rovuma a Maputo",
        regiao: "Sul",
        imagem: "https://placehold.co/400/00695c/white?text=Gaza",
        urlStream: "https://node.stream-africa.com:8443/Gaza",
      ),
      Station(
        id: 14,
        nome: "Emissão Provincial Inhambane",
        categoria: "Comunitária",
        desc: "Hoje e sempre projetando Moçambique",
        regiao: "Sul",
        imagem: "https://placehold.co/400/00796b/white?text=Inhambane",
        urlStream: "https://node.stream-africa.com:8443/InhambaneFM",
      ),
      Station(
        id: 15,
        nome: "Rádio Índico",
        categoria: "World",
        desc: "Cada vez mais ouvida",
        regiao: "Sul",
        imagem: "https://placehold.co/400/4a148c/white?text=Indico",
        urlStream: "http://uk16freenew.listen2myradio.com:8125/",
      ),
      Station(
        id: 16,
        nome: "Rádio Maria Moçambique",
        categoria: "Religiosa",
        desc: "Uma voz cristã em sua casa",
        regiao: "Sul",
        imagem: "https://placehold.co/400/3e2723/white?text=Maria",
        urlStream: "http://dreamsiteradiocp2.com:8088/",
      ),
      Station(
        id: 17,
        nome: "Rádio Maria Moçambique (ssl)",
        categoria: "Religiosa",
        desc: "Uma voz cristã em sua casa",
        regiao: "Sul",
        imagem: "https://placehold.co/400/3e2723/white?text=Maria2",
        urlStream:
            "https://dreamsiteradiocp2.com/proxy/rmmozambique2?mp=/stream",
      ),
      Station(
        id: 18,
        nome: "Rádio Maria Moçambique (alt)",
        categoria: "Religiosa",
        desc: "Uma voz cristã em sua casa",
        regiao: "Sul",
        imagem: "https://placehold.co/400/3e2723/white?text=Maria3",
        urlStream: "http://dreamsiteradiocp6.com:8046/",
      ),
      Station(
        id: 19,
        nome: "Radio Capital 90.7 FM",
        categoria: "Religiosa",
        desc: "Emissora cristã",
        regiao: "Sul",
        imagem: "https://placehold.co/400/bf360c/white?text=Capital",
        urlStream: "https://stream.zeno.fm/hr0guxs2tlguv",
      ),
      Station(
        id: 20,
        nome: "KFM 88.3MHZ Mocambique",
        categoria: "Religiosa",
        desc: "Rádio religiosa",
        regiao: "Sul",
        imagem: "https://placehold.co/400/558b2f/white?text=KFM",
        urlStream: "https://stream.zeno.fm/4fcgv64r1uhvv",
      ),
      Station(
        id: 21,
        nome: "Rádio Alfa Ómega",
        categoria: "Religiosa",
        desc: "Sinônimo de Esperança",
        regiao: "Sul",
        imagem: "https://placehold.co/400/827717/white?text=Alfa",
        urlStream: "#",
      ),
      Station(
        id: 22,
        nome: "Rádio S FM",
        categoria: "Pop",
        desc: "SFM - Ouve o som que te toca",
        regiao: "Sul",
        imagem: "https://placehold.co/400/c62828/white?text=SFM",
        urlStream: "#",
      ),
      Station(
        id: 23,
        nome: "Hero Radio",
        categoria: "Gospel",
        desc: "Rádio gospel",
        regiao: "Sul",
        imagem: "https://placehold.co/400/2e7d32/white?text=Hero",
        urlStream: "https://a2.asurahosting.com:6790/mozambique.mp3",
      ),
      Station(
        id: 24,
        nome: "Favor Radio",
        categoria: "Gospel",
        desc: "Rádio gospel oficial",
        regiao: "Sul",
        imagem: "https://placehold.co/400/1b5e20/white?text=Favor",
        urlStream: "#",
      ),
      Station(
        id: 25,
        nome: "Rádio Planeta Rap Lu So",
        categoria: "Rap/Hip-Hop",
        desc: "Rap e Hip-Hop",
        regiao: "Sul",
        imagem: "https://placehold.co/400/311b92/white?text=Rap",
        urlStream: "#",
      ),
      Station(
        id: 50,
        nome: "ICS - Rádio Comunitária de Xai-Xai 107.1Mhz FM",
        categoria: "Comunitária",
        desc: "Comunicar para o desenvolvimento das comunidades",
        regiao: "Sul",
        imagem: "https://placehold.co/400/004d40/white?text=XaiXai",
        urlStream: "https://stream.zeno.fm/x7ht0dkxpgtvv",
      ),

      // ==================== CENTRO ====================
      Station(
        id: 26,
        nome: "Cidade FM",
        categoria: "Música",
        desc: "Mais Rádio - Beira",
        regiao: "Centro",
        imagem: "https://placehold.co/400/e65100/white?text=CidadeFM",
        urlStream: "https://node.stream-africa.com:8443/RadioCidadeBeira",
      ),
      Station(
        id: 27,
        nome: "Rádio Sofala FM",
        categoria: "Comunitária",
        desc: "Hoje e sempre projetando Moçambique",
        regiao: "Centro",
        imagem: "https://placehold.co/400/00695c/white?text=Sofala",
        urlStream: "https://node.stream-africa.com:8443/Sofala",
      ),
      Station(
        id: 28,
        nome: "RM - Emissão Provincial de Sofala",
        categoria: "Notícias",
        desc: "Emissão provincial",
        regiao: "Centro",
        imagem: "https://placehold.co/400/8e4b4c/white?text=RMSofala",
        urlStream: "http://node.stream-africa.com:8000/Sofala",
      ),
      Station(
        id: 29,
        nome: "Emissor Provincial de Manica",
        categoria: "Comunitária",
        desc: "Hoje e sempre projetando Moçambique",
        regiao: "Centro",
        imagem: "https://placehold.co/400/00796b/white?text=Manica",
        urlStream: "https://node.stream-africa.com:8443/ManicaFM",
      ),
      Station(
        id: 30,
        nome: "Emissão Provincial Tete",
        categoria: "Comunitária",
        desc: "Hoje e Sempre",
        regiao: "Centro",
        imagem: "https://placehold.co/400/00838f/white?text=Tete",
        urlStream: "https://node.stream-africa.com:8443/TeteFM",
      ),
      Station(
        id: 31,
        nome: "Emissão Provincial Zambézia",
        categoria: "Comunitária",
        desc: "Hoje e sempre projetando Moçambique",
        regiao: "Centro",
        imagem: "https://placehold.co/400/0097a7/white?text=Zambezia",
        urlStream: "https://node.stream-africa.com:8443/ZambeziaFM",
      ),
      Station(
        id: 32,
        nome: "Quelimane FM",
        categoria: "Comunitária",
        desc: "Quelimane Frequências Modeladas",
        regiao: "Centro",
        imagem: "https://placehold.co/400/00796b/white?text=Quelimane",
        urlStream: "#",
      ),
      Station(
        id: 33,
        nome: "Chuabo FM",
        categoria: "Comunitária",
        desc: "Liberdade Independência",
        regiao: "Centro",
        imagem: "https://placehold.co/400/00838f/white?text=Chuabo",
        urlStream: "#",
      ),
      Station(
        id: 34,
        nome: "Rádio Mega FM",
        categoria: "Música",
        desc: "A rádio das grandes emoções",
        regiao: "Centro",
        imagem: "https://placehold.co/400/FF8C00/white?text=Mega",
        urlStream: "https://stream.zeno.fm/71nw1dw9ioyuv",
      ),
      Station(
        id: 35,
        nome: "Rádio Pax",
        categoria: "Religiosa",
        desc: "Emissora Católica da Beira - Promovendo a Paz",
        regiao: "Centro",
        imagem: "https://placehold.co/400/3e2723/white?text=Pax",
        urlStream: "#",
      ),

      // ==================== NORTE ====================
      Station(
        id: 36,
        nome: "Emissão Provincial Nampula",
        categoria: "Comunitária",
        desc: "Do Rovuma a Maputo",
        regiao: "Norte",
        imagem: "https://placehold.co/400/00695c/white?text=Nampula",
        urlStream: "https://node.stream-africa.com:8443/Nampula",
      ),
      Station(
        id: 37,
        nome: "Emissão Provincial Niassa",
        categoria: "Comunitária",
        desc: "Hoje e sempre projetando Moçambique",
        regiao: "Norte",
        imagem: "https://placehold.co/400/00796b/white?text=Niassa",
        urlStream: "https://node.stream-africa.com:8443/NiassaFM",
      ),
      Station(
        id: 38,
        nome: "Emissão Provincial Cabo Delgado",
        categoria: "Comunitária",
        desc: "Hoje e sempre projetando Moçambique",
        regiao: "Norte",
        imagem: "https://placehold.co/400/00838f/white?text=CaboDelgado",
        urlStream: "https://node.stream-africa.com:8443/CaboDelgadoFM",
      ),
      Station(
        id: 39,
        nome: "Rádio Sem Fronteiras",
        categoria: "Religiosa",
        desc: "Emissora católica da Diocese de Pemba",
        regiao: "Norte",
        imagem: "https://placehold.co/400/3e2723/white?text=SemFronteiras",
        urlStream: "https://ssl.stmxp.net:8030/",
      ),
      Station(
        id: 40,
        nome: "Zumbo FM",
        categoria: "Música",
        desc: "O Ouvinte em Primeiro Lugar",
        regiao: "Norte",
        imagem: "https://placehold.co/400/FF8C00/white?text=Zumbo",
        urlStream: "#",
      ),
      Station(
        id: 41,
        nome: "Rádio Encontro",
        categoria: "Religiosa",
        desc: "Emissora Católica de Nampula",
        regiao: "Norte",
        imagem: "https://placehold.co/400/3e2723/white?text=Encontro",
        urlStream: "#",
      ),
      Station(
        id: 42,
        nome: "Radio FOT Lichinga 95.9mhz",
        categoria: "Religiosa",
        desc: "Radio Fot FM, o nosso futuro já chegou",
        regiao: "Norte",
        imagem: "https://placehold.co/400/558b2f/white?text=FOT",
        urlStream: "https://stream.zeno.fm/vk1yf5a8z98uv",
      ),
      Station(
        id: 43,
        nome: "Radio Vida Nampula 88.8 FM",
        categoria: "Gospel",
        desc: "Emissora Evangélica de Nampula",
        regiao: "Norte",
        imagem: "https://placehold.co/400/2e7d32/white?text=Vida",
        urlStream: "https://stream.zeno.fm/xx59uigxs32vv",
      ),
      Station(
        id: 44,
        nome: "Rádio Watana",
        categoria: "Religiosa",
        desc: "A Rádio Católica da Diocese da Nacala",
        regiao: "Norte",
        imagem: "https://placehold.co/400/3e2723/white?text=Watana",
        urlStream: "#",
      ),
      Station(
        id: 45,
        nome: "Rádio Wimbe - Feba Moçambique",
        categoria: "Religiosa",
        desc: "Rádio religiosa - Pemba",
        regiao: "Norte",
        imagem: "https://placehold.co/400/1b5e20/white?text=Wimbe",
        urlStream: "https://xstreamer.galcom.org:8443/RadioWimbeOgg",
      ),
      Station(
        id: 46,
        nome: "Rádio Wimbe (MP3)",
        categoria: "Religiosa",
        desc: "Rádio religiosa - Pemba",
        regiao: "Norte",
        imagem: "https://placehold.co/400/1b5e20/white?text=Wimbe2",
        urlStream: "http://xstreamer.galcom.org:8000/RadioWimbe",
      ),
      Station(
        id: 47,
        nome: "Rádio Comunitária de Monapo",
        categoria: "Comunitária",
        desc: "Comunicando e informando a comunidade",
        regiao: "Norte",
        imagem: "https://placehold.co/400/004d40/white?text=Monapo",
        urlStream: "#",
      ),
      Station(
        id: 48,
        nome: "site moz FM",
        categoria: "Música",
        desc: "Musica para todos em grande estilo",
        regiao: "Norte",
        imagem: "https://placehold.co/400/e65100/white?text=MozFM",
        urlStream: "https://stream.zeno.fm/5qywky45rxhvv",
      ),
      Station(
        id: 49,
        nome: "site moz FM (alt)",
        categoria: "Música",
        desc: "Musica para todos em grande estilo",
        regiao: "Norte",
        imagem: "https://placehold.co/400/e65100/white?text=MozFM2",
        urlStream: "https://stream.zeno.fm/8t2hhg8rhy8uv",
      ),

      // ==================== DIVERSAS / ZENO FM ====================
      Station(
        id: 51,
        nome: "Radio Notas De Prata",
        categoria: "Variedades",
        desc: "Além da imaginação",
        regiao: "Moçambique",
        imagem: "https://placehold.co/400/607d8b/white?text=Notas",
        urlStream: "https://stream.zeno.fm/dzppe218g18uv",
      ),
      Station(
        id: 52,
        nome: "Noticias do Norte Radio",
        categoria: "Notícias",
        desc: "Informação do norte",
        regiao: "Norte",
        imagem: "https://placehold.co/400/455a64/white?text=NoticiasNorte",
        urlStream: "https://stream.zeno.fm/f6ss7utfzrhvv",
      ),
      Station(
        id: 53,
        nome: "Tars FM",
        categoria: "Rock",
        desc: "Rede Tars",
        regiao: "Moçambique",
        imagem: "https://placehold.co/400/37474f/white?text=Tars",
        urlStream: "https://stm.roxcast.com.br:7030/",
      ),
      Station(
        id: 54,
        nome: "Tribo FM",
        categoria: "Música",
        desc: "Rádio online de Nampula",
        regiao: "Norte",
        imagem: "https://placehold.co/400/FF8C00/white?text=Tribo",
        urlStream: "#",
      ),
      Station(
        id: 55,
        nome: "Zeno FM - AFRO Radio",
        categoria: "Música",
        desc: "Música e muito mais",
        regiao: "Moçambique",
        imagem: "https://placehold.co/400/4a148c/white?text=Afro",
        urlStream: "https://stream.zeno.fm/3p12umu90s8uv",
      ),
      Station(
        id: 56,
        nome: "Zeno FM - B5 Radio MZ",
        categoria: "R&B",
        desc: "No Borders In Music",
        regiao: "Moçambique",
        imagem: "https://placehold.co/400/6a1b9a/white?text=B5",
        urlStream: "https://stream.zeno.fm/wu2zvliloxtuv",
      ),
      Station(
        id: 57,
        nome: "Zeno FM - Belarte FM",
        categoria: "Música",
        desc: "Web rádio",
        regiao: "Moçambique",
        imagem: "https://placehold.co/400/7b1fa2/white?text=Belarte",
        urlStream: "https://stream.zeno.fm/uwpccsaf9yzuv",
      ),
      Station(
        id: 58,
        nome: "Zeno FM - DK Record",
        categoria: "Música",
        desc: "Web rádio",
        regiao: "Moçambique",
        imagem: "https://placehold.co/400/9c27b0/white?text=DK",
        urlStream: "https://stream.zeno.fm/sg7vsmvwzp8uv",
      ),
      Station(
        id: 59,
        nome: "Zeno FM - Grandes Clássicos",
        categoria: "Música",
        desc: "Clássicos nacionais",
        regiao: "Moçambique",
        imagem: "https://placehold.co/400/ab47bc/white?text=Classicos",
        urlStream: "https://stream.zeno.fm/bm29ouxe0hrtv",
      ),
      Station(
        id: 60,
        nome: "Zeno FM - Iembe Rádio Cristã",
        categoria: "Gospel",
        desc: "Igreja Evangélica na Beira",
        regiao: "Centro",
        imagem: "https://placehold.co/400/2e7d32/white?text=Iembe",
        urlStream: "https://stream.zeno.fm/8jaq9bzwi6quv",
      ),
      Station(
        id: 61,
        nome: "Zeno FM - Infor Radio",
        categoria: "Notícias",
        desc: "News, Music and Entertainment",
        regiao: "Moçambique",
        imagem: "https://placehold.co/400/455a64/white?text=Infor",
        urlStream: "https://stream.zeno.fm/t54yw7vc0rhvv",
      ),
      Station(
        id: 62,
        nome: "Zeno FM - kampua FM",
        categoria: "Variedades",
        desc: "Variedades",
        regiao: "Maputo",
        imagem: "https://placehold.co/400/607d8b/white?text=kampua",
        urlStream: "#",
      ),
      Station(
        id: 63,
        nome: "Zeno FM - MAC Rádio Fusão FM 91.6",
        categoria: "Música",
        desc: "Web rádio",
        regiao: "Moçambique",
        imagem: "https://placehold.co/400/FF8C00/white?text=MAC",
        urlStream: "#",
      ),
      Station(
        id: 64,
        nome: "Zeno FM - Mmradio Entrevistas",
        categoria: "Entrevistas",
        desc: "Entrevistas e música",
        regiao: "Moçambique",
        imagem: "https://placehold.co/400/795548/white?text=Mmradio",
        urlStream: "https://stream.zeno.fm/tk497a3sgxhvv",
      ),
      Station(
        id: 65,
        nome: "Zeno FM - Rádio Banda RJ",
        categoria: "Generalista",
        desc: "Une Moçambique e África lusófona",
        regiao: "Moçambique",
        imagem: "https://placehold.co/400/8d6e63/white?text=BandaRJ",
        urlStream: "https://stream.zeno.fm/wgo68netouhvv",
      ),
      Station(
        id: 66,
        nome: "Zeno FM - Rádio Cabeça do Velho",
        categoria: "Música",
        desc: "Música moçambicana e do mundo",
        regiao: "Moçambique",
        imagem: "https://placehold.co/400/a1887f/white?text=CabecaVelho",
        urlStream: "https://stream.zeno.fm/3me12q256nhvv",
      ),
      Station(
        id: 67,
        nome: "Zeno FM - Radio Capoeira",
        categoria: "Desporto",
        desc: "Esportes",
        regiao: "Moçambique",
        imagem: "https://placehold.co/400/2c6e2c/white?text=Capoeira",
        urlStream: "https://stream.zeno.fm/tkppachyeolvv",
      ),
      Station(
        id: 68,
        nome: "Zeno FM - Radio CF 91.2",
        categoria: "Música",
        desc: "A sua rádio mais ouvida",
        regiao: "Moçambique",
        imagem: "https://placehold.co/400/FF8C00/white?text=CF",
        urlStream: "https://stream.zeno.fm/68gh568f5nhvv",
      ),
      Station(
        id: 69,
        nome: "Zeno FM - Radio Chissano",
        categoria: "Música",
        desc: "Web rádio",
        regiao: "Moçambique",
        imagem: "https://placehold.co/400/bf360c/white?text=Chissano",
        urlStream: "https://stream.zeno.fm/8oxxfsxzpftvv",
      ),
      Station(
        id: 70,
        nome: "Zeno FM - Radio Clube de Jovens",
        categoria: "Juvenil",
        desc: "Conectando Jovens",
        regiao: "Moçambique",
        imagem: "https://placehold.co/400/0277bd/white?text=Jovens",
        urlStream: "https://stream.zeno.fm/t67546r8038uv",
      ),
      Station(
        id: 71,
        nome: "Zeno FM - Radio Despertar MZ",
        categoria: "Música",
        desc: "Web rádio",
        regiao: "Moçambique",
        imagem: "https://placehold.co/400/FF8C00/white?text=Despertar",
        urlStream: "https://stream.zeno.fm/167qkkygvnhvv",
      ),
      Station(
        id: 72,
        nome: "Zeno FM - Radio EGEA Web 24hrs",
        categoria: "Gospel",
        desc: "Rádio gospel - Heaven Full",
        regiao: "Maputo",
        imagem: "https://placehold.co/400/2e7d32/white?text=EGEA",
        urlStream: "https://stream.zeno.fm/gbktm9u0czzuv",
      ),
      Station(
        id: 73,
        nome: "Zeno FM - Radio FM Web-Namacurra",
        categoria: "Música",
        desc: "Web rádio",
        regiao: "Moçambique",
        imagem: "https://placehold.co/400/FF8C00/white?text=Namacurra",
        urlStream: "https://stream.zeno.fm/jh2htf8itpotv",
      ),
      Station(
        id: 74,
        nome: "Zeno FM - RÁDIO Imacs Chókwe",
        categoria: "Música",
        desc: "Sempre na Linha da Frente",
        regiao: "Moçambique",
        imagem: "https://placehold.co/400/FF8C00/white?text=Imacs",
        urlStream: "https://stream.zeno.fm/qgfxqcnsyzxtv",
      ),
      Station(
        id: 75,
        nome: "Zeno FM - Rádio Martins",
        categoria: "Música",
        desc: "Todas Novidades",
        regiao: "Moçambique",
        imagem: "https://placehold.co/400/FF8C00/white?text=Martins",
        urlStream: "https://stream.zeno.fm/bbbpxwnpj70tv",
      ),
      Station(
        id: 76,
        nome: "Zeno FM - Radio Terra",
        categoria: "Música",
        desc: "Web rádio",
        regiao: "Moçambique",
        imagem: "https://placehold.co/400/FF8C00/white?text=Terra",
        urlStream: "https://stream.zeno.fm/vinnpmoaqopvv",
      ),
      Station(
        id: 77,
        nome: "Zeno FM - Radio Vida",
        categoria: "Gospel",
        desc: "Rádio Evangélica de Nampula",
        regiao: "Norte",
        imagem: "https://placehold.co/400/2e7d32/white?text=VidaZen",
        urlStream: "https://stream.zeno.fm/raqujgb9xrbvv",
      ),
      Station(
        id: 78,
        nome: "Zeno FM - radiobranquinhocosta",
        categoria: "Música",
        desc: "Web rádio",
        regiao: "Moçambique",
        imagem: "https://placehold.co/400/FF8C00/white?text=Branquinho",
        urlStream: "https://stream.zeno.fm/a3gbe3ewqjftv",
      ),
      Station(
        id: 79,
        nome: "Zeno FM - Superior FM",
        categoria: "Educacional",
        desc: "Informação, Educação e Entretenimento",
        regiao: "Moçambique",
        imagem: "https://placehold.co/400/1565c0/white?text=Superior",
        urlStream: "https://stream.zeno.fm/9v34uaukdq8uv",
      ),
      Station(
        id: 80,
        nome: "Zeno FM - Viva Rádio",
        categoria: "Educacional",
        desc: "Rádio educacional",
        regiao: "Moçambique",
        imagem: "https://placehold.co/400/1976d2/white?text=Viva",
        urlStream: "https://stream.zeno.fm/hv7y8teaaf9uv",
      ),
      Station(
        id: 81,
        nome: "Conexão 360",
        categoria: "Notícias",
        desc: "Promoção de acontecimentos do país",
        regiao: "Moçambique",
        imagem: "https://placehold.co/400/455a64/white?text=Conexao",
        urlStream: "https://stream.zeno.fm/d1nhbf70tchvv",
      ),
      Station(
        id: 82,
        nome: "Rádio FIM",
        categoria: "Notícias",
        desc: "Web rádio",
        regiao: "Moçambique",
        imagem: "https://placehold.co/400/546e7a/white?text=FIM",
        urlStream: "https://stream.zeno.fm/stxdzvs44c9uv",
      ),
      Station(
        id: 83,
        nome: "Radio Academica",
        categoria: "Educacional",
        desc: "Rádio académica do Isctac",
        regiao: "Moçambique",
        imagem: "https://placehold.co/400/1a237e/white?text=Academica",
        urlStream: "#",
      ),
      Station(
        id: 84,
        nome: "Radio Rtmc",
        categoria: "Educacional",
        desc: "Rádio educativa e cultural",
        regiao: "Moçambique",
        imagem: "https://placehold.co/400/283593/white?text=RTMC",
        urlStream: "https://acmc.ice.infomaniak.ch/acmc-32.mp3",
      ),
      Station(
        id: 85,
        nome: "Radio 5",
        categoria: "Música",
        desc: "Stream Africa",
        regiao: "Moçambique",
        imagem: "https://placehold.co/400/FF8C00/white?text=Radio5",
        urlStream: "#",
      ),
      Station(
        id: 86,
        nome: "LM Radio Mozambique",
        categoria: "Easy-Listening",
        desc: "LM Radio local",
        regiao: "Moçambique",
        imagem: "https://placehold.co/400/1a237e/white?text=LMlocal",
        urlStream: "#",
      ),
      Station(
        id: 87,
        nome: "Radio Mocambique 97.9",
        categoria: "Notícias",
        desc: "Canal RM",
        regiao: "Nacional",
        imagem: "https://placehold.co/400/8e4b4c/white?text=RM979",
        urlStream: "https://stream.streamgenial.stream/0tcgy4vscv8uv",
      ),
    ];
  }
}
