import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'radio_provider.dart';
import 'station_model.dart';
import 'radio_digital_screen.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F9),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Biblioteca",
              style: TextStyle(
                fontFamily: 'Newsreader',
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Consumer<RadioProvider>(
              builder: (context, provider, _) {
                return Text(
                  "${provider.favoriteStations.length} estações favoritas",
                  style:
                      const TextStyle(color: Color(0xFF5F5E5E), fontSize: 14),
                );
              },
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Consumer<RadioProvider>(
                builder: (context, provider, _) {
                  final favorites = provider.favoriteStations;

                  if (favorites.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.favorite_border,
                              size: 64, color: Color(0xFFD8C1C0)),
                          SizedBox(height: 12),
                          Text(
                            "Nenhuma estação favorita",
                            style: TextStyle(color: Color(0xFF5F5E5E)),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Toque no ícone de coração nas estações",
                            style: TextStyle(
                                fontSize: 12, color: Color(0xFF5F5E5E)),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: favorites.length,
                    itemBuilder: (context, index) {
                      final station = favorites[index];
                      return _buildStationTile(station, provider, context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStationTile(
      Station station, RadioProvider provider, BuildContext context) {
    final isChecking = provider.isCheckingStream(station.id);
    final status = provider.streamStatus[station.id];

    Color getStatusColor() {
      if (isChecking) return const Color(0xFFEAB308);
      if (status == true) return const Color(0xFF22C55E);
      if (status == false) return const Color(0xFFEF4444);
      return const Color(0xFF9CA3AF);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD8C1C0)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              width: 56,
              height: 56,
              imageUrl: station.imagem,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 56,
                height: 56,
                color: const Color(0xFFE9E8E7),
              ),
              errorWidget: (context, url, error) => Container(
                width: 56,
                height: 56,
                color: const Color(0xFFE9E8E7),
                child: const Icon(Icons.radio, size: 30),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  station.nome,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  "${station.regiao} · ${station.categoria}",
                  style:
                      const TextStyle(fontSize: 12, color: Color(0xFF5F5E5E)),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: getStatusColor(),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isChecking
                          ? "A testar..."
                          : (status == true
                              ? "Online"
                              : (status == false ? "Offline" : "Desconhecido")),
                      style: TextStyle(
                        fontSize: 10,
                        color: getStatusColor(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.favorite, color: Color(0xFF8E4B4C)),
            onPressed: () => provider.toggleFavorite(station),
          ),
          ElevatedButton(
            onPressed: () async {
              bool? isOnline =
                  await provider.checkStreamStatus(station, forceRefresh: true);
              if (isOnline == false) {
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Estação offline no momento."),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8E4B4C),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40)),
              minimumSize: const Size(80, 36),
            ),
            child: const Text("Ouvir"),
          ),
        ],
      ),
    );
  }
}
