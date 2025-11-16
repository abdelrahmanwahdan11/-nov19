import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._prefs) {
    _isLoggedIn = _prefs.getBool(_loginKey) ?? false;
    _isGuest = _prefs.getBool(_guestKey) ?? false;
  }

  final SharedPreferences _prefs;
  static const _loginKey = 'isLoggedIn';
  static const _guestKey = 'isGuest';

  late bool _isLoggedIn;
  late bool _isGuest;

  bool get isLoggedIn => _isLoggedIn;
  bool get isGuest => _isGuest;

  Future<void> login(String email) async {
    _isLoggedIn = true;
    _isGuest = false;
    await _prefs.setBool(_loginKey, true);
    await _prefs.setBool(_guestKey, false);
    notifyListeners();
  }

  Future<void> continueAsGuest() async {
    _isGuest = true;
    _isLoggedIn = false;
    await _prefs.setBool(_guestKey, true);
    await _prefs.setBool(_loginKey, false);
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _isGuest = false;
    await _prefs.setBool(_loginKey, false);
    await _prefs.setBool(_guestKey, false);
    notifyListeners();
  }
}
