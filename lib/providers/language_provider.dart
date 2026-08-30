import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  SharedPreferences? _prefs;
  String _currentLanguage = 'en';

  String get currentLanguage => _currentLanguage;

  LanguageProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    _prefs = await SharedPreferences.getInstance();
    _currentLanguage = _prefs?.getString('language') ?? 'en';
    notifyListeners();
  }

  void setLanguage(String langCode) {
    _currentLanguage = langCode;
    _prefs?.setString('language', langCode);
    notifyListeners();
  }
}
