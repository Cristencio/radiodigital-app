import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/radio_provider.dart';
import 'stations_screen.dart';
import 'player_screen.dart';
import 'library_screen.dart';
import 'podcast_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const StationsScreen(),
      const PlayerScreen(),
      const LibraryScreen(),
    ];
  }

  void navigateToPlayer() {
    setState(() {
      _currentIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RadioProvider>(context);
    final isDark = provider.isDarkMode;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0A0A0C) : const Color(0xFFFBF9F9),
      body: Column(
        children: [
          _buildHeader(provider, isDark),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(provider, isDark),
    );
  }

  Widget _buildHeader(RadioProvider provider, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: (isDark ? const Color(0xFF1F1F24) : const Color(0xFFF5F3F3))
            .withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF2C2C32) : const Color(0xFFE9E8E7),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PodcastScreen()),
              );
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
          Text(
            "Rádio Digital",
            style: TextStyle(
              fontFamily: 'Newsreader',
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1B1C1C),
            ),
          ),
          GestureDetector(
            onTap: () => provider.toggleTheme(),
            child: Icon(
              provider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: isDark
                  ? Colors.white
                  : const Color.fromARGB(255, 150, 71, 240),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(RadioProvider provider, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: (isDark ? const Color(0xFF1F1F24) : const Color(0xFFF5F3F3))
            .withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF2C2C32) : const Color(0xFFE9E8E7),
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.radio, "Estações", 0, isDark),
              _navItem(Icons.play_circle, "Reprodutor", 1, isDark),
              _navItem(Icons.favorite, "Biblioteca", 2, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index, bool isDark) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.translationValues(0, isSelected ? -4 : 0, 0),
            child: Icon(
              icon,
              color: isSelected
                  ? const Color.fromARGB(255, 203, 163, 248)
                  : (isDark
                      ? const Color(0xFF71717A)
                      : const Color(0xFFA8A29E)),
              size: 26,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isSelected
                  ? const Color(0xFFF8A3A3)
                  : (isDark
                      ? const Color(0xFF71717A)
                      : const Color(0xFFA8A29E)),
            ),
            child: Text(label),
          ),
        ],
      ),
    );
  }
}
