import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends ChangeNotifier {
  SettingsController(this._prefs) {
    final languageCode = _prefs.getString(_languageKey) ?? 'ar';
    _locale = Locale(languageCode);
    _reduceAnimations = _prefs.getBool(_reduceKey) ?? false;
  }

  final SharedPreferences _prefs;
  static const _languageKey = 'language';
  static const _reduceKey = 'reduceAnimations';

  late Locale _locale;
  late bool _reduceAnimations;

  Locale get locale => _locale;
  bool get reduceAnimations => _reduceAnimations;

  Future<void> updateLocale(Locale locale) async {
    _locale = locale;
    await _prefs.setString(_languageKey, locale.languageCode);
    notifyListeners();
  }

  Future<void> toggleReduceAnimations(bool value) async {
    _reduceAnimations = value;
    await _prefs.setBool(_reduceKey, value);
    notifyListeners();
  }

  Future<void> clearAll() async {
    await _prefs.clear();
    notifyListeners();
  }
}
