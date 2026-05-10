import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/radio_provider.dart';

class PodcastScreen extends StatelessWidget {
  const PodcastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RadioProvider>(context);
    final isDark = provider.isDarkMode;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0A0A0C) : const Color(0xFFFBF9F9),
      appBar: AppBar(
        backgroundColor:
            isDark ? const Color(0xFF1F1F24) : const Color(0xFFF5F3F3),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : const Color(0xFF1B1C1C),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Podcasts",
          style: TextStyle(
            fontFamily: 'Newsreader',
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "Explore os nossos programas exclusivos",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFA1A1AA),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          _buildPodcastCard(
            context,
            icon: Icons.mic,
            title: "Conversas na Rádio",
            description: "Entrevistas e debates sobre actualidade moçambicana.",
            episode: "Episódio 12 • 45 min",
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          _buildPodcastCard(
            context,
            icon: Icons.headphones,
            title: "Música & História",
            description: "A trilha sonora da nossa cultura, episódio especial.",
            episode: "Episódio 8 • 38 min",
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          _buildPodcastCard(
            context,
            icon: Icons.lens,
            title: "Notícias da Manhã",
            description: "Resumo diário com os principais acontecimentos.",
            episode: "Episódio 245 • 22 min",
            isDark: isDark,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.podcasts, size: 16, color: Color(0xFF75FB4C)),
              const SizedBox(width: 8),
              Text(
                "Novos episódios todas as semanas",
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? const Color(0xFF71717A)
                      : const Color(0xFFA8A29E),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPodcastCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required String episode,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF18181B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF2C2C32) : const Color(0xFFE9E8E7),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F1F24) : const Color(0xFFF5F3F3),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Icon(
              icon,
              size: 28,
              color: const Color(0xFF75FB4C),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: isDark ? Colors.white : const Color(0xFF1B1C1C),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? const Color(0xFFA1A1AA)
                        : const Color(0xFF5F5E5E),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      episode,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? const Color(0xFF71717A)
                            : const Color(0xFFA8A29E),
                      ),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text("Demo: reprodução de podcast em breve!"),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        // ignore: deprecated_member_use
                        backgroundColor:
                            // ignore: deprecated_member_use
                            const Color(0xFFF8A3A3).withOpacity(0.2),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_arrow,
                              size: 14, color: Color(0xFF8E4B4C)),
                          SizedBox(width: 4),
                          Text(
                            "Ouvir",
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF8E4B4C),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
