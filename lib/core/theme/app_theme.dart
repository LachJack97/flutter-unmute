import 'package:flutter/material.dart';

// Define generic dark theme colors
const Color darkThemeBackground = Color(0xFF36393F); // Main background
const Color darkThemeSurface = Color(0xFF2F3136); // Slightly lighter surfaces
const Color darkThemeAlmostBlack = Color(0xFF202225); // Even darker areas
const Color darkThemePrimary = Colors.orange; // Primary accent color
const Color darkThemeTextPrimary = Colors.white;
const Color darkThemeTextSecondary = Color(0xFFB9BBBE); // Secondary text/icons
const Color accentGreen = Color(0xFF43B581); // Accent color for positive actions/indicators
const Color accentRed = Color(0xFFF04747); // Accent color for errors/warnings

class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.orange,
    scaffoldBackgroundColor: const Color(0xFFF5F5F7),
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.orange,
      brightness: Brightness.light,
      background: const Color(0xFFF5F5F7), // Main background
      primary: Colors.orange, // Main accent color
      onPrimary: Colors.white, // Text on accent color
      surface: Colors.white, // Card backgrounds, dialogs
      onSurface: const Color(0xFF1C1C1E), // Main text color
      surfaceContainer: Colors.white, // Explicitly for cards/containers
      onSurfaceVariant:
          const Color(0xFF3C3C43).withOpacity(0.6), // Secondary text
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF5F5F7),
      elevation: 0,
      iconTheme: IconThemeData(color: Color(0xFF1C1C1E)),
      titleTextStyle: TextStyle(
        color: Color(0xFF1C1C1E),
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: const CardThemeData(
      color: Colors.white,
      elevation: 1,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF1C1C1E)),
      bodyMedium: TextStyle(color: Color(0xFF1C1C1E)),
      titleLarge: TextStyle(color: Color(0xFF1C1C1E), fontWeight: FontWeight.bold),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      hintStyle: TextStyle(
        color: const Color(0xFF3C3C43).withOpacity(0.6),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkThemeBackground,
    primaryColor: darkThemePrimary,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: darkThemePrimary,
      onPrimary: darkThemeTextPrimary,
      secondary: darkThemePrimary, // Can be same as primary or a different accent
      onSecondary: darkThemeTextPrimary,
      error: accentRed,
      onError: darkThemeTextPrimary,
      surface: darkThemeBackground, // Used for Cards, Dialogs, BottomSheets
      onSurface: darkThemeTextPrimary,
      surfaceContainerHighest: darkThemeAlmostBlack, // For elements like chat input background
      // Fill in other required colors, possibly deriving from the main ones
      surfaceDim: Color(0xFF1E1F22), // Darker shade for dimmed surfaces
      surfaceBright: Color(0xFF3A3E42), // Lighter shade for bright surfaces
      surfaceContainerLowest: Color(0xFF1A1B1E),
      surfaceContainerLow: Color(0xFF202225),
      surfaceContainer: Color(0xFF25282C),
      surfaceContainerHigh: Color(0xFF2F3136),
      onSurfaceVariant: darkThemeTextSecondary,
      outline: Color(0xFF4F545C),
      outlineVariant: Color(0xFF3A3D42),
      shadow: Colors.black,
      scrim: Colors.black54,
      inverseSurface: darkThemeTextPrimary,
      onInverseSurface: darkThemeBackground,
      inversePrimary: darkThemeBackground,
      primaryFixed: darkThemePrimary,
      onPrimaryFixed: darkThemeTextPrimary,
      primaryFixedDim: darkThemePrimary,
      onPrimaryFixedVariant: darkThemeTextPrimary,
      secondaryFixed: darkThemePrimary,
      onSecondaryFixed: darkThemeTextPrimary,
      secondaryFixedDim:darkThemePrimary,
      onSecondaryFixedVariant: darkThemeTextPrimary,
      tertiary: accentGreen, // Example for a tertiary color
      onTertiary: darkThemeTextPrimary,
      tertiaryFixed: accentGreen,
      onTertiaryFixed: darkThemeTextPrimary,
      tertiaryFixedDim: Color(0xFF399D70),
      onTertiaryFixedVariant: darkThemeTextPrimary,
      surfaceTint: darkThemePrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkThemeSurface, // App bars with a slightly lighter dark grey
      elevation: 0,
      iconTheme: IconThemeData(color: darkThemeTextSecondary),
      titleTextStyle: TextStyle(
        color: darkThemeTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
    ),
    cardTheme: CardThemeData(
      color: darkThemeBackground, // Uniform charcoal
      elevation: 1.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkThemePrimary,
        foregroundColor: darkThemeTextPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: darkThemePrimary,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkThemeAlmostBlack, // Darker input fields
      hintStyle: const TextStyle(color: darkThemeTextSecondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: darkThemePrimary, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Color(0xFF40444B)), // Subtle border
      ),
      labelStyle: const TextStyle(color: darkThemeTextSecondary),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: darkThemeTextPrimary),
      bodyMedium: TextStyle(color: darkThemeTextPrimary),
      titleMedium: TextStyle(color: darkThemeTextPrimary),
      headlineSmall: TextStyle(color: darkThemeTextPrimary),
      // Define other text styles as needed
    ).apply(
      bodyColor: darkThemeTextPrimary,
      displayColor: darkThemeTextPrimary,
    ),
    iconTheme: const IconThemeData(
      color: darkThemeTextSecondary,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: darkThemeSurface,
      textStyle: const TextStyle(color: darkThemeTextPrimary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: darkThemeBackground, // Uniform charcoal
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      titleTextStyle: const TextStyle(color: darkThemeTextPrimary, fontSize: 18, fontWeight: FontWeight.bold),
      contentTextStyle: const TextStyle(color: darkThemeTextSecondary, fontSize: 16),
    ),
    // You can continue to customize other components like BottomNavigationBar,
    // TabBarTheme, etc.
  );
}
