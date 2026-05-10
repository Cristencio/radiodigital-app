import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'radio_provider.dart';
import 'station_model.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  String formatTime(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$mins:$secs";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F9),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Consumer<RadioProvider>(
              builder: (context, provider, _) {
                final station = provider.currentStation;

                if (station == null) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.radio, size: 64, color: Color(0xFFD8C1C0)),
                        SizedBox(height: 16),
                        Text(
                          "Nenhuma estação selecionada",
                          style: TextStyle(color: Color(0xFF5F5E5E)),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Selecione uma estação na aba Estações",
                          style:
                              TextStyle(fontSize: 12, color: Color(0xFF5F5E5E)),
                        ),
                      ],
                    ),
                  );
                }

                final isChecking = provider.isCheckingStream(station.id);
                final status = provider.streamStatus[station.id];

                Color getStatusColor() {
                  if (isChecking) return const Color(0xFFEAB308);
                  if (status == true) return const Color(0xFF22C55E);
                  if (status == false) return const Color(0xFFEF4444);
                  return const Color(0xFF9CA3AF);
                }

                String getStatusText() {
                  if (isChecking) return "VERIFICANDO...";
                  if (status == true) return "ONLINE";
                  if (status == false) return "OFFLINE";
                  return "DESCONHECIDO";
                }

                return Center(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(),
                          _buildStationImage(station),
                          const SizedBox(height: 12),
                          _buildStatusLabel(getStatusColor(), getStatusText(),
                              provider, station),
                          const SizedBox(height: 4),
                          _buildStationName(station),
                          const SizedBox(height: 4),
                          _buildStationInfo(station),
                          const SizedBox(height: 8),
                          _buildLiveIndicator(),
                          const SizedBox(height: 16),
                          _buildProgressBar(provider),
                          const SizedBox(height: 8),
                          _buildVolumeControl(provider),
                          const SizedBox(height: 16),
                          _buildPlaybackControls(provider),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStationImage(Station station) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 176,
          height: 176,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFF8A3A3).withValues(alpha: 0.3),
              width: 5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
              ),
            ],
          ),
        ),
        ClipOval(
          child: CachedNetworkImage(
            width: 176,
            height: 176,
            imageUrl: station.imagem,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: const Color(0xFFE9E8E7),
              child: const Icon(Icons.radio, size: 50),
            ),
            errorWidget: (context, url, error) => Container(
              color: const Color(0xFFE9E8E7),
              child: const Icon(Icons.radio, size: 50),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusLabel(
      Color color, String text, RadioProvider provider, Station station) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                text,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.sync, size: 18, color: Color(0xFF5F5E5E)),
          onPressed: () async {
            await provider.checkStreamStatus(station, forceRefresh: true);
            provider.forceUpdate();
          },
          constraints: const BoxConstraints(),
          padding: EdgeInsets.zero,
          tooltip: "Verificar stream",
        ),
      ],
    );
  }

  Widget _buildStationName(Station station) {
    return Text(
      station.nome,
      style: const TextStyle(
        fontFamily: 'Newsreader',
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildStationInfo(Station station) {
    return Text(
      "${station.regiao} · ${station.categoria}",
      style: const TextStyle(
        color: Color(0xFF5F5E5E),
        fontSize: 14,
      ),
    );
  }

  Widget _buildLiveIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3F3),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: const Color(0xFFE4E2E2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFFF8A3A3),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            "AO VIVO",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(RadioProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xFFE9E8E7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: provider.isPlaying ? 0.65 : 0,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8A3A3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatTime(provider.listenSeconds),
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF5F5E5E),
                ),
              ),
              const Text(
                "AO VIVO",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFF8A3A3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeControl(RadioProvider provider) {
    return SizedBox(
      width: 200,
      child: Row(
        children: [
          const Icon(
            Icons.volume_up,
            size: 20,
            color: Color(0xFF5F5E5E),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Slider(
              value: provider.volume,
              onChanged: (value) => provider.setVolume(value),
              activeColor: const Color(0xFFF8A3A3),
              inactiveColor: const Color(0xFFD8C1C0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaybackControls(RadioProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildControlButton(
          icon: Icons.skip_previous,
          size: 28,
          onPressed: provider.playPrevious,
          isCircular: true,
          sizeContainer: 48,
        ),
        const SizedBox(width: 24),
        _buildPlayPauseButton(provider),
        const SizedBox(width: 24),
        _buildControlButton(
          icon: Icons.skip_next,
          size: 28,
          onPressed: provider.playNext,
          isCircular: true,
          sizeContainer: 48,
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required double size,
    required VoidCallback onPressed,
    required bool isCircular,
    required double sizeContainer,
  }) {
    return Container(
      width: sizeContainer,
      height: sizeContainer,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFF8A3A3).withValues(alpha: 0.5),
        ),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          icon,
          size: size,
          color: const Color(0xFF8E4B4C),
        ),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildPlayPauseButton(RadioProvider provider) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFF8A3A3), width: 4),
        color: const Color(0xFF1B1C1C),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          provider.isPlaying ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
          size: 40,
        ),
        onPressed: provider.togglePlayPause,
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
          const Text(
            "Rádio Digital",
            style: TextStyle(
              fontFamily: 'Newsreader',
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1B1C1C),
            ),
          ),
          const SizedBox(width: 80),
        ],
      ),
    );
  }
}
