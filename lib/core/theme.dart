import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color bg = Color(0xFFFFFFFF);
  static const Color panel = Color(0xFFF6F3F4);
  static const Color card = Color(0xFFFFFFFF);
  static const Color line = Color(0xFFE8E2E3);
  static const Color hair = Color(0xFFE8E2E3);

  static const Color pink = Color(0xFF2B2B2B);
  static const Color pinkDeep = Color(0xFFFFFFFF);
  static const Color mauve = Color(0xFFC9A2B0);
  static const Color copper = Color(0xFFD2793F);

  static const Color ink = Color(0xFF2B2B2B);
  static const Color ink2 = Color(0xFF5C5658);
  static const Color muted = Color(0xFF8C8386);
  static const Color mutedDark = Color(0xFFB6AFB0);

  static const Color searchFill = Color(0xFFF2EEEF);
  static const Color searchSep = Color(0xFFE7E2E3);
  static const Color searchPlaceholder = Color(0xFF9C9496);

  static const Color pagerOff = Color(0xFFE3DEDF);
  static const Color pagerOn = Color(0xFFC4682F);
  static const Color whatsapp = Color(0xFF25D366);
  static const Color amber = Color(0xFFF5A623);
  static const Color stockWarn = Color(0xFFE0A34D);
  static const Color verifiedBlue = Color(0xFF6FB4F0);
  static const Color kpiHighlight = Color(0xFFE6F2FE);
  static const Color kpiHighlightBorder = Color(0xFFBFDDFA);
  static const Color imageBg = Color(0xFFFFFFFF);
  static const Color red = Color(0xFFE0473E);
  static const Color redPress = Color(0xFFC53D35);
  static const Color redTint = Color(0xFFFBEAE8);

  static const Color categoryBand = Color(0xFFEAEAEA);

  static const Color categorySeparator = bg;

  static const double categorySeparatorHeight = 12;

  static const Color searchFillNeutral = Color(0xFFF6F6F4);
  static const Color searchGrey = Color(0xFFA8A6A7);

  static const Color shopPageBg = Color(0xFFFFFFFB);
  static const Color shopTitle = Color(0xFF0E0E0C);

  static const double radiusCard = 20;
  static const double radiusSmall = 12;
  static const double radiusPill = 20;

  static TextStyle brand({double size = 22, Color color = ink}) {
    return TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: size,
        color: color,
        letterSpacing: 1.5);
  }

  static TextStyle system({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color color = ink,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: 'Helvetica Neue',
      fontFamilyFallback: const [
        '-apple-system',
        'SF Pro Display',
        'Arial',
        'sans-serif'
      ],
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle categoryLabel() {
    return const TextStyle(
        fontFamily: 'Hanken Grotesk',
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: ink);
  }

  static const TextStyle productBrand = TextStyle(
    fontFamily: 'Figtree',
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 16 / 13,
    letterSpacing: 0.26,
    color: ink,
  );

  static const TextStyle productName = TextStyle(
    fontFamily: 'Figtree',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 16 / 13,
    color: ink,
  );

  static ThemeData light() {
    final base = ThemeData.light().textTheme;
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Figtree',
      brightness: Brightness.light,
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.light(
        primary: ink,
        onPrimary: Colors.white,
        secondary: pink,
        onSecondary: pinkDeep,
        secondaryContainer: panel,
        onSecondaryContainer: ink,
        surface: panel,
        onSurface: ink,
        error: red,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: ink2,
          selectedBackgroundColor: ink,
          selectedForegroundColor: Colors.white,
          side: const BorderSide(color: line),
        ),
      ),
      textTheme: base.apply(bodyColor: ink, displayColor: ink),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: ink,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: bg,
        titleTextStyle: const TextStyle(
            color: ink, fontSize: 18, fontWeight: FontWeight.w700),
        iconTheme: const IconThemeData(color: ink),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusCard),
            side: const BorderSide(color: line)),
        clipBehavior: Clip.antiAlias,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: ink,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          side: const BorderSide(color: Color(0xFFD8D2D3)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: ink),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: panel,
        hintStyle: const TextStyle(color: muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: ink, width: 1.2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      ),
      dividerTheme: const DividerThemeData(color: line, thickness: 1, space: 1),
      chipTheme: ChipThemeData(
        backgroundColor: panel,
        selectedColor: line,
        labelStyle: const TextStyle(
            fontSize: 12.5, fontWeight: FontWeight.w500, color: ink),
        side: const BorderSide(color: line),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusPill)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: ink),
    );
  }
}

class AdminTheme {
  AdminTheme._();

  static const Color bg = Color(0xFF2B2B2B);
  static const Color panel = Color(0xFF252525);
  static const Color card = Color(0xFF2B2B2B);
  static const Color line = Color(0xFF3D3D3D);
  static const Color hair = Color(0xFF3D3D3D);
  static const Color pink = Color(0xFFF8C8DC);
  static const Color pinkDeep = Color(0xFF6E2444);
  static const Color mauve = Color(0xFFC9A2B0);
  static const Color copper = Color(0xFFD2793F);
  static const Color ink = Color(0xFFFFFFFF);
  static const Color ink2 = Color(0xFFDCD5D6);
  static const Color muted = Color(0xFF8C8386);
  static const Color mutedDark = Color(0xFF7E7477);
  static const Color searchFill = Color(0xFF383838);
  static const Color searchSep = Color(0xFF3A3335);
  static const Color searchPlaceholder = Color(0xFFA39C9E);
  static const Color pagerOff = Color(0xFFD6D0D1);
  static const Color pagerOn = Color(0xFFC4682F);
  static const Color whatsapp = Color(0xFF25D366);
  static const Color amber = Color(0xFFF5A623);
  static const Color stockWarn = Color(0xFFE0A34D);
  static const Color verifiedBlue = Color(0xFF6FB4F0);
  static const Color imageBg = Color(0xFFFFFFFF);
  static const Color red = Color(0xFFE0473E);
  static const Color redPress = Color(0xFFC53D35);
  static const Color redTint = Color(0xFF3A2523);

  static const double radiusCard = 20;
  static const double radiusSmall = 12;
  static const double radiusPill = 20;

  static TextStyle brand({double size = 22, Color color = ink}) {
    return TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: size,
        color: color,
        letterSpacing: 1.5);
  }

  static ThemeData dark() {
    final base = ThemeData.dark().textTheme;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(
        primary: ink,
        onPrimary: Colors.black,
        secondary: pink,
        onSecondary: pinkDeep,
        surface: panel,
        onSurface: ink,
        error: red,
      ),
      textTheme: base.apply(bodyColor: ink, displayColor: ink),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: ink,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: bg,
        titleTextStyle: const TextStyle(
            color: ink, fontSize: 18, fontWeight: FontWeight.w700),
        iconTheme: const IconThemeData(color: ink),
      ),
      cardTheme: CardThemeData(
        color: panel,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusCard),
            side: const BorderSide(color: line)),
        clipBehavior: Clip.antiAlias,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: ink,
          foregroundColor: Colors.black,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          side: const BorderSide(color: Color(0xFF4A4A4A)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: ink),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: panel,
        hintStyle: const TextStyle(color: muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: ink, width: 1.2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      ),
      dividerTheme: const DividerThemeData(color: line, thickness: 1, space: 1),
      chipTheme: ChipThemeData(
        backgroundColor: panel,
        selectedColor: line,
        labelStyle: const TextStyle(
            fontSize: 12.5, fontWeight: FontWeight.w500, color: ink),
        side: const BorderSide(color: line),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusPill)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: ink),
    );
  }
}
