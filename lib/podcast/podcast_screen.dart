import 'package:flutter/material.dart';

class PodcastScreen extends StatelessWidget {
  const PodcastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F9),
      appBar: AppBar(
        title: const Text(
          'Podcast',
          style: TextStyle(
            fontFamily: 'Newsreader',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFFF5F3F3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.podcasts, size: 80, color: Color(0xFF8E4B4C)),
            SizedBox(height: 16),
            Text(
              "Em desenvolvimento",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1B1C1C),
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Em breve você terá podcasts exclusivos",
              style: TextStyle(fontSize: 14, color: Color(0xFF5F5E5E)),
            ),
          ],
        ),
      ),
    );
  }
}
