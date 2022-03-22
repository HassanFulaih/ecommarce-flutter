import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  String _themeText = 'l';

  ThemeMode get themeMode =>
      _themeText == 'd' ? ThemeMode.dark : ThemeMode.light;

  void changeMode(String newTheme) async {
    _themeText = newTheme;
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('themeText', _themeText);
  }

  getThemeMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _themeText = prefs.getString('themeText') ?? 'd';
    //print(themeText);
    notifyListeners();
  }
}
