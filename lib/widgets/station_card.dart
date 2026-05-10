import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/station_model.dart';
import '../providers/radio_provider.dart';

class StationCard extends StatelessWidget {
  final Station station;
  final VoidCallback onPlay;

  const StationCard({
    super.key,
    required this.station,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RadioProvider>(context);
    final isDark = provider.isDarkMode;
    final isFavorite = provider.isFavorite(station);
    final isCurrentAndPlaying =
        provider.currentStation?.id == station.id && provider.isPlaying;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF18181B) : Colors.white,
        borderRadius: BorderRadius.circular(12), // Reduzido de 16 para 12
        border: Border.all(
          color: isDark ? const Color(0xFF2C2C32) : const Color(0xFFD8C1C0),
          width: 0.8, // Borda mais fina
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12), // Reduzido de 16 para 12
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Linha: Nome + Categoria + Coração
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          // Nome da estação
                          Flexible(
                            child: Text(
                              station.nome,
                              style: TextStyle(
                                fontSize: 15, // Reduzido de 18 para 15
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1B1C1C),
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Categoria como badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3), // Reduzido
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8A3A3)
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              station.categoria,
                              style: const TextStyle(
                                color: Color(0xFF8E4B4C),
                                fontSize: 9, // Reduzido de 11 para 9
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Coração favorito
                    GestureDetector(
                      onTap: () => provider.toggleFavorite(station),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? const Color(0xFF8E4B4C) : null,
                        size: 18, // Reduzido de 22 para 18
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6), // Reduzido de 8 para 6
                // Região e Digital
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 12, // Reduzido de 14 para 12
                      color: isDark
                          ? const Color(0xFF71717A)
                          : const Color(0xFF5F5E5E),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      station.regiao,
                      style: TextStyle(
                        fontSize: 10, // Reduzido de 12 para 10
                        color: isDark
                            ? const Color(0xFF71717A)
                            : const Color(0xFF5F5E5E),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.wifi,
                      size: 12, // Reduzido de 14 para 12
                      color: isDark
                          ? const Color(0xFF71717A)
                          : const Color(0xFF5F5E5E),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      "Digital",
                      style: TextStyle(
                        fontSize: 10, // Reduzido de 12 para 10
                        color: isDark
                            ? const Color(0xFF71717A)
                            : const Color(0xFF5F5E5E),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8), // Reduzido de 10 para 8
                // Descrição
                Text(
                  station.desc,
                  style: TextStyle(
                    fontSize: 12, // Reduzido de 14 para 12
                    color: isDark
                        ? const Color(0xFFA1A1AA)
                        : const Color(0xFF1B1C1C),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.fromLTRB(12, 0, 12, 12), // Padding reduzido
            child: isCurrentAndPlaying
                ? Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8), // Reduzido de 10 para 8
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _WaveAnimation(),
                        SizedBox(width: 6),
                        Text(
                          "Tocando...",
                          style: TextStyle(
                            color: Color(0xFF22C55E),
                            fontSize: 11, // Reduzido de 13 para 11
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ElevatedButton(
                    onPressed: station.urlStream == "#" ? null : onPlay,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8E4B4C),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: const Size(
                          double.infinity, 32), // Reduzido de 38 para 32
                      padding: const EdgeInsets.symmetric(vertical: 0),
                      textStyle: const TextStyle(fontSize: 12), // Adicionado
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_arrow,
                            size: 14), // Reduzido de 16 para 14
                        SizedBox(width: 4),
                        Text("Ouvir agora", style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _WaveAnimation extends StatelessWidget {
  const _WaveAnimation();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Container(
          margin:
              const EdgeInsets.symmetric(horizontal: 1), // Reduzido de 2 para 1
          width: 2.5, // Reduzido de 3 para 2.5
          height: 8 + (index * 1.5), // Reduzido de 10 + (index * 2)
          decoration: BoxDecoration(
            color: const Color(0xFF22C55E),
            borderRadius: BorderRadius.circular(1.5),
          ),
        );
      }),
    );
  }
}
