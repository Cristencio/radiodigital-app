import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/radio_provider.dart';
import '../models/station_model.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  BuildContext? get context => null;

  String formatTime(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$mins:$secs";
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;

    return Consumer<RadioProvider>(
      builder: (context, provider, _) {
        final station = provider.currentStation;

        if (station == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.radio,
                  size: 64,
                  color: provider.isDarkMode
                      ? const Color(0xFF2C2C32)
                      : const Color(0xFFD8C1C0),
                ),
                const SizedBox(height: 16),
                Text(
                  "Nenhuma estação selecionada",
                  style: TextStyle(
                    color: provider.isDarkMode
                        ? const Color(0xFFA1A1AA)
                        : const Color(0xFF5F5E5E),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Selecione uma estação na aba Estações",
                  style: TextStyle(
                    fontSize: 12,
                    color: provider.isDarkMode
                        ? const Color(0xFF71717A)
                        : const Color(0xFFA8A29E),
                  ),
                ),
              ],
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: isSmallScreen ? 8 : 16,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildStationImage(station, provider, isSmallScreen),
                          SizedBox(height: isSmallScreen ? 12 : 20),
                          _buildStationName(station, provider, isSmallScreen),
                          const SizedBox(height: 4),
                          _buildStationInfo(station, provider),
                          SizedBox(height: isSmallScreen ? 16 : 24),
                          _buildLiveIndicator(provider),
                          SizedBox(height: isSmallScreen ? 16 : 24),
                          _buildProgressBar(provider, isSmallScreen),
                          SizedBox(height: isSmallScreen ? 12 : 16),
                          _buildVolumeControl(provider, isSmallScreen),
                          SizedBox(height: isSmallScreen ? 20 : 32),
                          _buildPlaybackControls(provider, isSmallScreen),
                          SizedBox(height: isSmallScreen ? 12 : 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStationImage(
      Station station, RadioProvider provider, bool isSmallScreen) {
    final isDark = provider.isDarkMode;
    final imageSize = isSmallScreen ? 130.0 : 180.0;

    return GestureDetector(
      onTap: () => _showImageDialog(station.imagem, context!),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: imageSize,
            height: imageSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFF8A3A3).withValues(alpha: 0.3),
                width: isSmallScreen ? 3 : 5,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.black : const Color(0xFF8E4B4C))
                      .withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),
          if (provider.isBuffering)
            Container(
              width: imageSize,
              height: imageSize,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black54,
              ),
              child: Center(
                child: SizedBox(
                  width: isSmallScreen ? 30 : 40,
                  height: isSmallScreen ? 30 : 40,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                ),
              ),
            ),
          ClipOval(
            child: CachedNetworkImage(
              width: imageSize,
              height: imageSize,
              imageUrl: station.imagem,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color:
                    isDark ? const Color(0xFF1F1F24) : const Color(0xFFE9E8E7),
                child: Icon(
                  Icons.radio,
                  size: isSmallScreen ? 35 : 50,
                  color: isDark
                      ? const Color(0xFF71717A)
                      : const Color(0xFFA8A29E),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color:
                    isDark ? const Color(0xFF1F1F24) : const Color(0xFFE9E8E7),
                child: Icon(
                  Icons.radio,
                  size: isSmallScreen ? 35 : 50,
                  color: isDark
                      ? const Color(0xFF71717A)
                      : const Color(0xFFA8A29E),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImageDialog(String imageUrl, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildStationName(
      Station station, RadioProvider provider, bool isSmallScreen) {
    return Text(
      station.nome,
      style: TextStyle(
        fontFamily: 'Newsreader',
        fontSize: isSmallScreen ? 20 : 26,
        fontWeight: FontWeight.w600,
        color: provider.isDarkMode ? Colors.white : const Color(0xFF1B1C1C),
      ),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildStationInfo(Station station, RadioProvider provider) {
    return Text(
      "${station.regiao} · ${station.categoria}",
      style: TextStyle(
        color: provider.isDarkMode
            ? const Color(0xFFA1A1AA)
            : const Color(0xFF5F5E5E),
        fontSize: 14,
      ),
    );
  }

  Widget _buildLiveIndicator(RadioProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: provider.isDarkMode
            ? const Color(0xFF1F1F24)
            : const Color(0xFFF5F3F3),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: provider.isDarkMode
              ? const Color(0xFF2C2C32)
              : const Color(0xFFE4E2E2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: provider.isPlaying
                  ? const Color(0xFF22C55E)
                  : const Color(0xFFF8A3A3),
              shape: BoxShape.circle,
              boxShadow: provider.isPlaying
                  ? [const BoxShadow(color: Color(0xFF22C55E), blurRadius: 4)]
                  : null,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            provider.isPlaying ? "AO VIVO" : "PAUSADO",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color:
                  provider.isDarkMode ? Colors.white : const Color(0xFF1B1C1C),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(RadioProvider provider, bool isSmallScreen) {
    final progressWidth = provider.isPlaying ? 0.99 : 0.0;

    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 6,
          decoration: BoxDecoration(
            color: provider.isDarkMode
                ? const Color(0xFF2C2C32)
                : const Color(0xFFE9E8E7),
            borderRadius: BorderRadius.circular(10),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progressWidth,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF8A3A3), Color(0xFF8E4B4C)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              formatTime(provider.listenSeconds),
              style: TextStyle(
                fontSize: isSmallScreen ? 10 : 11,
                color: provider.isDarkMode
                    ? const Color(0xFF71717A)
                    : const Color(0xFF5F5E5E),
              ),
            ),
            Text(
              "AO VIVO",
              style: TextStyle(
                fontSize: isSmallScreen ? 10 : 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFF8A3A3),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVolumeControl(RadioProvider provider, bool isSmallScreen) {
    return SizedBox(
      width: isSmallScreen ? 180 : 200,
      child: Row(
        children: [
          Icon(
            Icons.volume_up,
            size: isSmallScreen ? 18 : 20,
            color: provider.isDarkMode
                ? const Color(0xFF71717A)
                : const Color(0xFF5F5E5E),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Slider(
              value: provider.volume,
              onChanged: (value) => provider.setVolume(value),
              activeColor: const Color(0xFFF8A3A3),
              inactiveColor: provider.isDarkMode
                  ? const Color(0xFF2C2C32)
                  : const Color(0xFFD8C1C0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaybackControls(RadioProvider provider, bool isSmallScreen) {
    final buttonSize = isSmallScreen ? 40.0 : 48.0;
    final iconSize = isSmallScreen ? 24.0 : 28.0;
    final playPauseSize = isSmallScreen ? 65.0 : 80.0;
    final playPauseIconSize = isSmallScreen ? 32.0 : 40.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildControlButton(
          icon: Icons.skip_previous,
          onPressed: provider.playPrevious,
          sizeContainer: buttonSize,
          iconSize: iconSize,
        ),
        SizedBox(width: isSmallScreen ? 16 : 24),
        _buildPlayPauseButton(
            provider, playPauseSize, playPauseIconSize, isSmallScreen),
        SizedBox(width: isSmallScreen ? 16 : 24),
        _buildControlButton(
          icon: Icons.skip_next,
          onPressed: provider.playNext,
          sizeContainer: buttonSize,
          iconSize: iconSize,
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required double sizeContainer,
    required double iconSize,
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
          size: iconSize,
          color: const Color(0xFF8E4B4C),
        ),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildPlayPauseButton(RadioProvider provider, double size,
      double iconSize, bool isSmallScreen) {
    return GestureDetector(
      onTap: provider.togglePlayPause,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
              color: const Color(0xFFF8A3A3), width: isSmallScreen ? 3 : 4),
          color: const Color(0xFF1B1C1C),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: provider.isBuffering
            ? Center(
                child: SizedBox(
                  width: iconSize - 10,
                  height: iconSize - 10,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              )
            : Icon(
                provider.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: iconSize,
              ),
      ),
    );
  }
}
