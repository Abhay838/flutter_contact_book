import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ── Brand Colors ─────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF1A73E8); // Google Blue
  static const Color primaryDark = Color(0xFF1557B0);
  static const Color primaryLight = Color(0xFFD2E3FC);
  static const Color accent = Color(0xFF34A853); // Google Green
  static const Color danger = Color(0xFFEA4335); // Google Red
  static const Color warning = Color(0xFFFBBC04); // Google Yellow
  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF8F9FA);
  static const Color onSurface = Color(0xFF202124);
  static const Color textSecondary = Color(0xFF5F6368);
  static const Color divider = Color(0xFFE8EAED);
  static const Color cardShadow = Color(0x1A000000);

  static const List<Color> avatarColors = [
    Color(0xFF1A73E8),
    Color(0xFF34A853),
    Color(0xFFEA4335),
    Color(0xFFFBBC04),
    Color(0xFF9C27B0),
    Color(0xFFFF5722),
    Color(0xFF00BCD4),
    Color(0xFF607D8B),
    Color(0xFFE91E63),
    Color(0xFF3F51B5),
  ];

  static Color avatarColorFor(String name) {
    if (name.isEmpty) return primary;
    final idx = name.codeUnitAt(0) % avatarColors.length;
    return avatarColors[idx];
  }

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      primary: primary,
      secondary: accent,
      error: danger,
      surface: surface,
      background: background,
    ),
    scaffoldBackgroundColor: background,
    fontFamily: 'Roboto',

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: surface,
      foregroundColor: onSurface,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: cardShadow,
      titleTextStyle: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: onSurface,
        letterSpacing: 0.15,
      ),
      iconTheme: IconThemeData(color: onSurface),
    ),

    // Bottom Navigation
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surface,
      indicatorColor: primaryLight,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: primary,
          );
        }
        return const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textSecondary,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: primary, size: 24);
        }
        return const IconThemeData(color: textSecondary, size: 24);
      }),
      elevation: 3,
      shadowColor: cardShadow,
    ),

    // Floating Action Button
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),

    // Input Decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF1F3F4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: danger, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: danger, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(color: textSecondary, fontSize: 15),
      labelStyle: const TextStyle(color: textSecondary, fontSize: 15),
      prefixIconColor: textSecondary,
    ),

    // Card
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: divider, width: 1),
      ),
    ),

    // List Tile
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      minVerticalPadding: 8,
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: divider,
      thickness: 1,
      space: 0,
    ),

    // Elevated Button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),

    // Text Button
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),

    // Chip
    chipTheme: ChipThemeData(
      backgroundColor: primaryLight,
      labelStyle: const TextStyle(color: primary, fontWeight: FontWeight.w500),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );
}
