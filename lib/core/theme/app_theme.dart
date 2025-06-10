import 'package:flutter/material.dart';

class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    // Define other properties like text themes, button themes, etc.
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primarySwatch: Colors.teal,
    // Define other properties for the dark theme.
  );
}
