import 'package:flutter/material.dart';
import 'radio/radio_splash_screen.dart';
import 'podcast/podcast_screen.dart';
import 'radio/radio_digital_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rádio Digital',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8E4B4C)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFBF9F9),
        fontFamily: 'Manrope',
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const RadioSplashScreen(),
        '/podcast': (context) => const PodcastScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/radio') {
          return MaterialPageRoute(
            builder: (context) => const RadioDigitalScreen(),
          );
        }
        return null;
      },
    );
  }
}
