import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  Future<void> loadLanguage() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? lang = preferences.getString('lang');

    if (lang != null) {
      _locale = Locale(lang);
      notifyListeners();
    }
  }

  Future<void> changeLanguage(String value) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString('lang', value);

    _locale = Locale(value);
    notifyListeners();
  }
}
