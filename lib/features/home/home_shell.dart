import 'package:flutter/material.dart';

import '../../core/controllers/app_scope.dart';
import '../../core/widgets/floating_nav_bar.dart';
import '../collections/collections_screen.dart';
import '../gallery/gallery_screen.dart';
import 'home_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeScreen(),
      const CollectionsScreen(),
      const GalleryScreen(),
    ];
    final reduceMotion = AppScope.of(context).settingsController.reduceAnimations;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedSwitcher(
        duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 350),
        child: pages[_index],
      ),
      extendBody: true,
      bottomNavigationBar: FloatingNavBar(
        currentIndex: _index,
        reduceMotion: reduceMotion,
        onTap: (value) {
          setState(() => _index = value);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed('/collection_create'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
