import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'radio_provider.dart';
import 'station_model.dart';
import 'radio_digital_screen.dart';

class StationsScreen extends StatefulWidget {
  const StationsScreen({super.key});

  @override
  State<StationsScreen> createState() => _StationsScreenState();
}

class _StationsScreenState extends State<StationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = "todas";

  final List<String> _categories = [
    "todas",
    "Notícias",
    "Música",
    "Comunitária",
    "Religiosa",
    "Gospel",
    "Desporto",
  ];

  @override
  void initState() {
    super.initState();
    // Iniciar verificação em massa após carregar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<RadioProvider>(context, listen: false);
      provider.checkAllStationsConcurrently();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getCategoryDisplay(String category) {
    final map = {
      "todas": "Todas as categorias",
      "Notícias": "Notícias",
      "Música": "Música",
      "Comunitária": "Comunitária",
      "Religiosa": "Religiosa",
      "Gospel": "Gospel",
      "Desporto": "Desporto",
    };
    return map[category] ?? category;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F9),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Todas as rádios",
                    style: TextStyle(
                      fontFamily: 'Newsreader',
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Explore estações de todo o país",
                    style: TextStyle(color: Color(0xFF5F5E5E), fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  _buildSearchBar(),
                  const SizedBox(height: 24),
                  Consumer<RadioProvider>(
                    builder: (context, provider, _) {
                      List<Station> filtered =
                          provider.stations.where((station) {
                        bool matchCategory = _selectedCategory == "todas" ||
                            station.categoria == _selectedCategory;
                        bool matchSearch = _searchController.text.isEmpty ||
                            station.nome.toLowerCase().contains(
                                _searchController.text.toLowerCase()) ||
                            station.desc
                                .toLowerCase()
                                .contains(_searchController.text.toLowerCase());
                        return matchCategory && matchSearch;
                      }).toList();

                      if (filtered.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 48),
                          child: Center(
                            child: Text(
                              "Nenhuma estação encontrada",
                              style: TextStyle(color: Color(0xFF5F5E5E)),
                            ),
                          ),
                        );
                      }

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1,
                          childAspectRatio: 1.4,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final station = filtered[index];
                          return _buildStationCard(station, provider);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3F3).withValues(alpha: 0.9),
        border: const Border(bottom: BorderSide(color: Color(0xFFE9E8E7))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 80),
          const Text(
            "Rádio Digital",
            style: TextStyle(
              fontFamily: 'Newsreader',
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1B1C1C),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/podcast');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.podcasts, color: Color(0xFF75FB4C), size: 18),
                  SizedBox(width: 6),
                  Text(
                    "Podcast",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: "Pesquisar nome ou descrição...",
              prefixIcon: const Icon(Icons.search, color: Color(0xFFA8A29E)),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(40),
                borderSide: const BorderSide(color: Color(0xFFD8C1C0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(40),
                borderSide: const BorderSide(color: Color(0xFFD8C1C0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(40),
                borderSide:
                    const BorderSide(color: Color(0xFFF8A3A3), width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFD8C1C0)),
            borderRadius: BorderRadius.circular(40),
            color: Colors.white,
          ),
          child: DropdownButton<String>(
            value: _selectedCategory,
            underline: const SizedBox(),
            icon: const Icon(Icons.arrow_drop_down),
            items: _categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(_getCategoryDisplay(category)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value!;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStationCard(Station station, RadioProvider provider) {
    final isChecking = provider.isCheckingStream(station.id);
    final status = provider.streamStatus[station.id];

    Color getStatusColor() {
      if (isChecking) return const Color(0xFFEAB308);
      if (status == true) return const Color(0xFF22C55E);
      if (status == false) return const Color(0xFFEF4444);
      return const Color(0xFF9CA3AF);
    }

    String getStatusText() {
      if (isChecking) return "A testar...";
      if (status == true) return "Online";
      if (status == false) return "Offline";
      return "Desconhecido";
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD8C1C0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        station.nome,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: getStatusColor().withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: getStatusColor(),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                getStatusText(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: getStatusColor(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(
                            provider.isFavorite(station)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: provider.isFavorite(station)
                                ? const Color(0xFF8E4B4C)
                                : null,
                            size: 22,
                          ),
                          onPressed: () => provider.toggleFavorite(station),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8A3A3).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Text(
                    station.categoria,
                    style: const TextStyle(
                      color: Color(0xFF8E4B4C),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  station.desc,
                  style:
                      const TextStyle(fontSize: 14, color: Color(0xFF1B1C1C)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        size: 14, color: Color(0xFF5F5E5E)),
                    const SizedBox(width: 4),
                    Text(station.regiao,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF5F5E5E))),
                    const SizedBox(width: 16),
                    const Icon(Icons.wifi, size: 14, color: Color(0xFF5F5E5E)),
                    const SizedBox(width: 4),
                    const Text("Digital",
                        style:
                            TextStyle(fontSize: 12, color: Color(0xFF5F5E5E))),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () async {
                // Verificar status antes de tocar
                bool? isOnline = await provider.checkStreamStatus(station,
                    forceRefresh: true);
                if (isOnline == false) {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text("Estação offline no momento. Tente mais tarde."),
                      backgroundColor: Color(0xFFEF4444),
                    ),
                  );
                  return;
                }

                provider.setCurrentStation(station);
                if (!provider.isPlaying) {
                  provider.togglePlayPause();
                }
                final radioScreenState = radioDigitalScreenKey.currentState;
                if (radioScreenState != null) {
                  radioScreenState.navigateToPlayer();
                }
              },
              icon: const Icon(Icons.play_arrow, size: 18),
              label: const Text("Ouvir agora"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8E4B4C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40)),
                minimumSize: const Size(double.infinity, 38),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
