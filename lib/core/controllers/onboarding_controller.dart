import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingController extends ChangeNotifier {
  OnboardingController(this._prefs) {
    _completed = _prefs.getBool(_completeKey) ?? false;
  }

  final SharedPreferences _prefs;
  static const _completeKey = 'onboardingComplete';

  bool _completed = false;
  bool get completed => _completed;

  final PageController pageController = PageController();
  int _index = 0;
  int get index => _index;

  Timer? _timer;

  void startAutoSlide() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!pageController.hasClients) return;
      final nextPage = (pageController.page?.round() ?? 0) + 1;
      final target = nextPage % 3;
      pageController.animateToPage(
        target,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  void updateIndex(int value) {
    _index = value;
    notifyListeners();
  }

  Future<void> complete() async {
    _completed = true;
    await _prefs.setBool(_completeKey, true);
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    pageController.dispose();
    super.dispose();
  }
}
