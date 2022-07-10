import 'package:flutter/material.dart';

class Themes {
  static Color fallbackColor = Colors.green;

  static ThemeData baseTheme = ThemeData(
    useMaterial3: true,
    typography: Typography.material2021(),
  );

  static ThemeData darkTheme(ColorScheme? dynamicTheme) {
    ColorScheme colorScheme = dynamicTheme ?? ColorScheme.fromSeed(
      seedColor: fallbackColor,
      brightness: Brightness.dark
    );
    return baseTheme.copyWith(
      colorScheme: colorScheme,
      switchTheme: _switchTheme(colorScheme),
      sliderTheme: _sliderTheme(colorScheme),
    );
  }

  static ThemeData lightTheme(ColorScheme? dynamicTheme) {
    ColorScheme colorScheme = dynamicTheme ?? ColorScheme.fromSeed(
      seedColor: fallbackColor,
      brightness: Brightness.light
    );
    return baseTheme.copyWith(
      colorScheme: colorScheme,
      switchTheme: _switchTheme(colorScheme),
      sliderTheme: _sliderTheme(colorScheme),
    );
  }

  static _switchTheme(ColorScheme colorScheme) {
    return SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if(states.contains(MaterialState.selected)) {
          return colorScheme.primary;
        }
        return colorScheme.outline;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if(states.contains(MaterialState.selected)) {
          return colorScheme.primaryContainer;
        }
        return colorScheme.surfaceVariant;
      }),
    );
  }

  static _sliderTheme(ColorScheme colorScheme) {
    return SliderThemeData(
      valueIndicatorColor: colorScheme.inverseSurface,
      valueIndicatorTextStyle: TextStyle(
        color: colorScheme.onInverseSurface,
        height: 1.5,
        fontSize: 16,
      )
    );
  }
}