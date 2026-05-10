import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'radio_provider.dart';
import 'stations_screen.dart';
import 'player_screen.dart';
import 'library_screen.dart';
import 'radio_bottom_nav_bar.dart';

final GlobalKey<RadioDigitalScreenState> radioDigitalScreenKey = GlobalKey();

class RadioDigitalScreen extends StatefulWidget {
  const RadioDigitalScreen({super.key});

  @override
  State<RadioDigitalScreen> createState() => RadioDigitalScreenState();
}

class RadioDigitalScreenState extends State<RadioDigitalScreen> {
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

  void changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void navigateToPlayer() {
    changeTab(1);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RadioProvider(),
      child: Scaffold(
        backgroundColor: const Color(0xFFFBF9F9),
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: RadioBottomNavBar(
          currentIndex: _currentIndex,
          onTap: changeTab,
        ),
      ),
    );
  }
}
