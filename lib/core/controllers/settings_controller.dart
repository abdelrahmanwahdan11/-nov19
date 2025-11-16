import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends ChangeNotifier {
  SettingsController(this._prefs) {
    final languageCode = _prefs.getString(_languageKey) ?? 'ar';
    _locale = Locale(languageCode);
    _reduceAnimations = _prefs.getBool(_reduceKey) ?? false;
    _digestEnabled = _prefs.getBool(_digestKey) ?? true;
  }

  final SharedPreferences _prefs;
  static const _languageKey = 'language';
  static const _reduceKey = 'reduceAnimations';
  static const _digestKey = 'digestEnabled';

  late Locale _locale;
  late bool _reduceAnimations;
  late bool _digestEnabled;

  Locale get locale => _locale;
  bool get reduceAnimations => _reduceAnimations;
  bool get digestEnabled => _digestEnabled;

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

  Future<void> toggleDigest(bool value) async {
    _digestEnabled = value;
    await _prefs.setBool(_digestKey, value);
    notifyListeners();
  }

  Future<void> clearAll() async {
    await _prefs.clear();
    _digestEnabled = true;
    notifyListeners();
  }
}
