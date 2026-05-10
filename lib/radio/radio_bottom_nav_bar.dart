import 'package:flutter/material.dart';

class RadioBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const RadioBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3F3).withValues(alpha: 0.95),
        border: const Border(top: BorderSide(color: Color(0xFFE9E8E7))),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.radio, "Estações", 0),
              _navItem(Icons.play_circle, "Reprodutor", 1),
              _navItem(Icons.favorite, "Biblioteca", 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color:
                isSelected ? const Color(0xFFF8A3A3) : const Color(0xFFA8A29E),
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color:
                  isSelected
                      ? const Color(0xFFF8A3A3)
                      : const Color(0xFFA8A29E),
            ),
          ),
        ],
      ),
    );
  }
}
