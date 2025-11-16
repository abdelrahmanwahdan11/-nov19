import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({super.key, required this.currentIndex, required this.onTap, this.reduceMotion = false});

  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).primaryColor;
    final icons = const [IconlyLight.home, IconlyLight.folder, IconlyLight.image];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(3, (index) {
          final active = currentIndex == index;
          return GestureDetector(
            onTap: () => onTap(index),
            child: AnimatedContainer(
              duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 250),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: active ? color.withOpacity(0.15) : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icons[index],
                color: active ? color : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                size: active ? 28 : 24,
              ),
            ),
          );
        }),
      ),
    );
  }
}
