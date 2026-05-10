import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/radio_provider.dart';
import '../models/station_model.dart';
import 'main_screen.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RadioProvider>(context);
    final isDark = provider.isDarkMode;
    final favorites = provider.favoriteStations;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Biblioteca",
            style: TextStyle(
              fontFamily: 'Newsreader',
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1B1C1C),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "${favorites.length} estações favoritas",
            style: TextStyle(
              color: isDark ? const Color(0xFFA1A1AA) : const Color(0xFF5F5E5E),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: favorites.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 64,
                          color: isDark
                              ? const Color(0xFF2C2C32)
                              : const Color(0xFFD8C1C0),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Nenhuma estação favorita",
                          style: TextStyle(
                            color: isDark
                                ? const Color(0xFFA1A1AA)
                                : const Color(0xFF5F5E5E),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Toque no ícone de coração nas estações",
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? const Color(0xFF71717A)
                                : const Color(0xFFA8A29E),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: favorites.length,
                    itemBuilder: (context, index) {
                      return _buildStationTile(
                          favorites[index], provider, context);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStationTile(
      Station station, RadioProvider provider, BuildContext context) {
    final isDark = provider.isDarkMode;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF18181B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2C2C32) : const Color(0xFFD8C1C0),
        ),
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
                color:
                    isDark ? const Color(0xFF1F1F24) : const Color(0xFFE9E8E7),
                child: Icon(
                  Icons.radio,
                  size: 30,
                  color: isDark
                      ? const Color(0xFF71717A)
                      : const Color(0xFFA8A29E),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: 56,
                height: 56,
                color:
                    isDark ? const Color(0xFF1F1F24) : const Color(0xFFE9E8E7),
                child: Icon(
                  Icons.radio,
                  size: 30,
                  color: isDark
                      ? const Color(0xFF71717A)
                      : const Color(0xFFA8A29E),
                ),
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
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${station.regiao} · ${station.categoria}",
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? const Color(0xFF71717A)
                        : const Color(0xFF5F5E5E),
                  ),
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
              await provider.setCurrentStation(station);
              await provider.playCurrentStation();
              if (context.mounted) {
                final mainScreen =
                    context.findAncestorStateOfType<MainScreenState>();
                mainScreen?.navigateToPlayer();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8E4B4C),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              minimumSize: const Size(80, 36),
            ),
            child: const Text("Ouvir"),
          ),
        ],
      ),
    );
  }
}
