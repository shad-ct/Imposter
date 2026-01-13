import 'package:flutter/material.dart';

class AppTheme {
  // Shadcn Dark Theme color palette
  static const Color background = Color(0xFF000000);
  static const Color foreground = Color(0xFFFAFAFA);
  static const Color card = Color(0xFF0A0A0A);
  static const Color cardForeground = Color(0xFFFAFAFA);
  static const Color popover = Color(0xFF0A0A0A);
  static const Color popoverForeground = Color(0xFFFAFAFA);
  static const Color muted = Color(0xFF737373);
  static const Color mutedForeground = Color(0xFFA3A3A3);
  static const Color accent = Color(0xFFFAFAFA);
  static const Color accentForeground = Color(0xFF000000);
  static const Color destructive = Color(0xFFEF4444);
  static const Color destructiveForeground = Color(0xFFFAFAFA);
  static const Color border = Color(0xFF262626);
  static const Color input = Color(0xFF262626);
  static const Color ring = Color(0xFFA3A3A3);
  static const Color primary = Color(0xFFFAFAFA);
  static const Color primaryForeground = Color(0xFF000000);
  static const Color secondary = Color(0xFF262626);
  static const Color secondaryForeground = Color(0xFFFAFAFA);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        tertiary: accent,
        surface: card,
        onSurface: cardForeground,
        error: destructive,
        onPrimary: primaryForeground,
        onSecondary: secondaryForeground,
      ),
      
      // AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: foreground,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: foreground),
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(
            color: border,
            width: 1,
          ),
        ),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: primaryForeground,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: foreground,
          side: const BorderSide(color: border, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: foreground,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: input,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: ring, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: destructive, width: 2),
        ),
        labelStyle: const TextStyle(color: mutedForeground),
        hintStyle: TextStyle(color: muted.withOpacity(0.6)),
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: secondary,
        selectedColor: primary,
        disabledColor: secondary.withOpacity(0.5),
        labelStyle: const TextStyle(color: foreground),
        secondaryLabelStyle: const TextStyle(color: primaryForeground),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        side: const BorderSide(color: border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Icon theme
      iconTheme: const IconThemeData(
        color: foreground,
        size: 24,
      ),

      // Floating action button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: primaryForeground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: card,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(
            color: border,
            width: 1,
          ),
        ),
        titleTextStyle: const TextStyle(
          color: foreground,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: const TextStyle(
          color: foreground,
          fontSize: 14,
        ),
      ),

      // Slider theme
      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: border,
        thumbColor: primary,
        overlayColor: primary.withOpacity(0.2),
        valueIndicatorColor: primary,
        valueIndicatorTextStyle: const TextStyle(
          color: primaryForeground,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primary;
          }
          return muted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primary.withOpacity(0.5);
          }
          return border;
        }),
      ),

      // List tile theme
      listTileTheme: ListTileThemeData(
        tileColor: card,
        selectedTileColor: primary.withOpacity(0.1),
        iconColor: foreground,
        textColor: foreground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
        space: 20,
      ),

      // Text theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: foreground,
          fontSize: 57,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.02,
        ),
        displayMedium: TextStyle(
          color: foreground,
          fontSize: 45,
          fontWeight: FontWeight.w700,
        ),
        displaySmall: TextStyle(
          color: foreground,
          fontSize: 36,
          fontWeight: FontWeight.w700,
        ),
        headlineLarge: TextStyle(
          color: foreground,
          fontSize: 32,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: TextStyle(
          color: foreground,
          fontSize: 28,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: foreground,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: foreground,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: foreground,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: TextStyle(
          color: foreground,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: foreground,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: foreground,
          fontSize: 14,
        ),
        bodySmall: TextStyle(
          color: mutedForeground,
          fontSize: 12,
        ),
        labelLarge: TextStyle(
          color: foreground,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
