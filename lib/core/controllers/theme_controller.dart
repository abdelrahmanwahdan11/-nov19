import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  ThemeController(this._prefs) {
    _themeMode = ThemeMode.values[_prefs.getInt(_themeKey) ?? 0];
    final storedHex = _prefs.getInt(_primaryKey);
    _primaryColor = storedHex != null ? Color(storedHex) : const Color(0xFFB4DC3A);
  }

  final SharedPreferences _prefs;
  static const _themeKey = 'themeMode';
  static const _primaryKey = 'primaryColor';

  late ThemeMode _themeMode;
  late Color _primaryColor;

  ThemeMode get themeMode => _themeMode;
  Color get primaryColor => _primaryColor;

  Future<void> updateThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setInt(_themeKey, mode.index);
    notifyListeners();
  }

  Future<void> updatePrimaryColor(Color color) async {
    _primaryColor = color;
    await _prefs.setInt(_primaryKey, color.value);
    notifyListeners();
  }
}
