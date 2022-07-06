import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Themes {
  static Color fallbackColor = Colors.green;

  static ThemeData baseTheme = ThemeData(
    useMaterial3: true,
    textTheme: GoogleFonts.openSansTextTheme(),
  );

  static ThemeData darkTheme(ColorScheme? dynamicTheme) {
    return baseTheme.copyWith(
      colorScheme: dynamicTheme ?? ColorScheme.fromSeed(
          seedColor: fallbackColor,
          brightness: Brightness.dark
        )
    );
  }

  static ThemeData lightTheme(ColorScheme? dynamicTheme) {
    return baseTheme.copyWith(
      colorScheme: dynamicTheme ?? ColorScheme.fromSeed(
        seedColor: fallbackColor,
        brightness: Brightness.light
      ) 
    );
  }
}