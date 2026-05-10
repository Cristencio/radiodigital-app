import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/radio_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/main_screen.dart';
import 'screens/podcast_screen.dart';

void main() {
  runApp(const RadioDigitalApp());
}

class RadioDigitalApp extends StatelessWidget {
  const RadioDigitalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RadioProvider(),
      child: MaterialApp(
        title: 'Rádio Digital',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Manrope',
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 97, 109, 161),
            brightness: Brightness.light,
            primary: const Color.fromARGB(255, 106, 133, 223),
            primaryContainer: const Color.fromARGB(255, 109, 118, 243),
            surface: const Color(0xFFFBF9F9),
          ),
          scaffoldBackgroundColor: const Color(0xFFFBF9F9),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFF5F3F3),
            elevation: 0,
            centerTitle: true,
            iconTheme: IconThemeData(color: Color(0xFF1B1C1C)),
          ),
        ),
        darkTheme: ThemeData(
          fontFamily: 'Manrope',
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 150, 144, 236),
            brightness: Brightness.dark,
            primary: const Color.fromARGB(255, 113, 107, 199),
            primaryContainer: const Color.fromARGB(255, 107, 116, 199),
            surface: const Color(0xFF0A0A0C),
          ),
          scaffoldBackgroundColor: const Color(0xFF0A0A0C),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1F1F24),
            elevation: 0,
            centerTitle: true,
          ),
        ),
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
        routes: {
          '/home': (context) => const MainScreen(),
          '/podcast': (context) => const PodcastScreen(),
        },
      ),
    );
  }
}
