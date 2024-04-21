import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeProvider with ChangeNotifier {

  ThemeData _currentTheme = lightMode;

  ThemeData get themeData => _currentTheme;

  set themeData(ThemeData theme) {
    _currentTheme = theme;
    notifyListeners();
  }
  
  void toggleTheme() {
    if (_currentTheme == lightMode) {
      _currentTheme = darkMode;
    } else {
      _currentTheme = lightMode;
    }
    notifyListeners();
  }

  void setSystemTheme(BuildContext context, {listen = true}){
    final Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    _currentTheme = systemBrightness == Brightness.light ? lightMode : darkMode;
    if (listen) {
      notifyListeners();
    }
  }
}

ThemeData lightMode = customThemeFromScheme(lightColorScheme);
ThemeData darkMode = customThemeFromScheme(darkColorScheme);

ColorScheme lightColorScheme = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(255, 0, 108, 202),
  brightness: Brightness.light,
  );

ColorScheme darkColorScheme = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(255, 0, 108, 202),
  brightness: Brightness.dark,
  );

ThemeData customThemeFromScheme(ColorScheme colorScheme) {
  ThemeData customTheme = ThemeData.from(
    colorScheme: colorScheme,
    useMaterial3: true,
    textTheme: GoogleFonts.outfitTextTheme()
  );
  customTheme = customTheme.copyWith(
    appBarTheme: const AppBarTheme(
      centerTitle: true,
    ),
  );
  return customTheme;
}
