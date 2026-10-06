import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// AstroTalk-inspired: deep cosmic base + warm orange/gold accents.
class AppColors {
  static const void_ = Color(0xFF05050A);
  static const night = Color(0xFF0D0A14);
  static const surface = Color(0xFF161222);
  static const surfaceLift = Color(0xFF1F1A2E);
  static const ink = Color(0xFFF8F4EC);
  static const muted = Color(0xFF9A93A8);
  static const gold = Color(0xFFE8B84B);
  static const goldDeep = Color(0xFFC4922A);
  static const goldSoft = Color(0xFFF5E6B8);
  static const orange = Color(0xFFFF7A1A);
  static const orangeDeep = Color(0xFFE05A00);
  static const neon = Color(0xFF3D9EFF);
  static const neonDeep = Color(0xFF1A5C9E);
  static const purple = Color(0xFF5A3480);
  static const purpleDeep = Color(0xFF2A1540);
  static const line = Color(0xFF2E2840);
  static const danger = Color(0xFFE07070);
  static const success = Color(0xFF4ADE80);
  static const chatUser = Color(0xFF2A4A35);
  static const chatAi = Color(0xFF1F1A2E);

  static const mist = night;
  static const teal = gold;
  static const tealDeep = goldDeep;
  static const brass = goldSoft;
  static const skyTop = Color(0xFF05050A);
  static const skyMid = Color(0xFF1A0F2E);
  static const skyBottom = Color(0xFF0B0B14);
}

class AppGradients {
  static const gold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD56B), Color(0xFFFF7A1A)],
  );

  static const promo = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE05A00), Color(0xFF8B2E6B), Color(0xFF2A1540)],
  );

  static const header = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1A0F2E), Color(0xFF0D0A14), Color(0xFF0D0A14)],
  );
}

ThemeData buildTheme() {
  final text = GoogleFonts.soraTextTheme(ThemeData.dark().textTheme).apply(
    bodyColor: AppColors.ink,
    displayColor: AppColors.ink,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.night,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.orange,
      secondary: AppColors.gold,
      tertiary: AppColors.purple,
      surface: AppColors.surface,
      onPrimary: Colors.white,
      onSecondary: AppColors.void_,
      onSurface: AppColors.ink,
      outline: AppColors.line,
    ),
    textTheme: text,
    dividerColor: AppColors.line,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.night,
      foregroundColor: AppColors.ink,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.sora(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
      iconTheme: const IconThemeData(color: AppColors.goldSoft),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.orange.withValues(alpha: 0.2),
      height: 68,
      elevation: 0,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return GoogleFonts.sora(
          fontSize: 11,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? AppColors.orange : AppColors.muted,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(color: selected ? AppColors.orange : AppColors.muted, size: 24);
      }),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surfaceLift,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentTextStyle: const TextStyle(color: AppColors.ink),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titleTextStyle: const TextStyle(color: AppColors.ink, fontSize: 18, fontWeight: FontWeight.w600),
      contentTextStyle: const TextStyle(color: AppColors.muted, height: 1.4),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceLift,
      hintStyle: const TextStyle(color: AppColors.muted),
      labelStyle: const TextStyle(color: AppColors.muted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.orange, width: 1.5),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.orange,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.orange.withValues(alpha: 0.35),
        disabledForegroundColor: Colors.white.withValues(alpha: 0.6),
        minimumSize: const Size(0, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 15),
        elevation: 2,
        shadowColor: AppColors.orange.withValues(alpha: 0.4),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.orange,
        side: const BorderSide(color: AppColors.orange),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.orange),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.orange),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}

TextStyle brandStyle({double size = 42, Color color = AppColors.goldSoft}) {
  return GoogleFonts.cinzel(
    fontSize: size,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
    color: color,
    height: 1.05,
  );
}

/// Traditional kundli typography — Devanagari + serif labels (Astro AI style).
TextStyle kundliStyle({double size = 14, Color color = AppColors.goldSoft, FontWeight weight = FontWeight.w600}) {
  return GoogleFonts.tiroDevanagariSanskrit(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: 1.2,
  );
}

TextStyle kundliSignStyle({double size = 13, Color color = AppColors.gold}) {
  return GoogleFonts.notoSerifDevanagari(
    fontSize: size,
    fontWeight: FontWeight.w700,
    color: color,
    height: 1.15,
  );
}

TextStyle kundliPlanetStyle({double size = 11, Color color = AppColors.ink}) {
  return GoogleFonts.notoSerifDevanagari(
    fontSize: size,
    fontWeight: FontWeight.w600,
    color: color,
    height: 1.1,
  );
}

const kSignOrder = [
  'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
  'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces',
];

const kSignSanskrit = {
  'Aries': 'मेष',
  'Taurus': 'वृष',
  'Gemini': 'मिथुन',
  'Cancer': 'कर्क',
  'Leo': 'सिंह',
  'Virgo': 'कन्या',
  'Libra': 'तुला',
  'Scorpio': 'वृश्चिक',
  'Sagittarius': 'धनु',
  'Capricorn': 'मकर',
  'Aquarius': 'कुम्भ',
  'Pisces': 'मीन',
};

const kPlanetShort = {
  'Sun': 'सू',
  'Moon': 'च',
  'Mars': 'मं',
  'Mercury': 'बु',
  'Venus': 'शु',
  'Jupiter': 'गु',
  'Saturn': 'श',
  'Rahu': 'रा',
  'Ketu': 'के',
};

const kPlanetColors = {
  'Lagna': Color(0xFFFF7A1A),
  'Sun': Color(0xFFE8A020),
  'Moon': Color(0xFF475569),
  'Mars': Color(0xFFDC2626),
  'Mercury': Color(0xFF059669),
  'Venus': Color(0xFF16A34A),
  'Jupiter': Color(0xFF7C3AED),
  'Saturn': Color(0xFFDC2626),
  'Rahu': Color(0xFFDC2626),
  'Ketu': Color(0xFFDC2626),
};

TextStyle kundliChartStyle({double size = 13, Color color = const Color(0xFF1A1A1A), FontWeight weight = FontWeight.w600}) {
  return GoogleFonts.notoSansDevanagari(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: 1.15,
  );
}

String formatKundliDegree(double deg) {
  final d = deg.floor().clamp(0, 29);
  final m = ((deg - deg.floor()) * 60).floor().clamp(0, 59);
  return '${d.toString().padLeft(2, '0')}°${m.toString().padLeft(2, '0')}';
}

int signNumber(String sign) => signIndex(sign) + 1;

/// Navamsha (D9): each sign is divided into 9 parts of 3°20'.
/// The navamsha sign depends on the planet's absolute sidereal longitude.
String navamshaSign(String rashi, double degreeInSign) {
  final rashiIdx = signIndex(rashi);
  final pada = (degreeInSign / (30 / 9)).floor().clamp(0, 8);
  // Fire signs start from Aries, Earth from Cap, Air from Libra, Water from Cancer
  const startSign = [0, 9, 6, 3]; // Aries=0, Cap=9, Libra=6, Cancer=3
  final element = rashiIdx % 4; // 0=fire,1=earth,2=air,3=water
  final navIdx = (startSign[element] + pada) % 12;
  return kSignOrder[navIdx];
}

int navamshaHouse(String lagnaNavSign, String planetNavSign) {
  final lagnaIdx = signIndex(lagnaNavSign);
  final pIdx = signIndex(planetNavSign);
  return ((pIdx - lagnaIdx + 12) % 12) + 1;
}

String signSanskrit(String sign) => kSignSanskrit[sign] ?? sign;

int signIndex(String sign) {
  final i = kSignOrder.indexOf(sign);
  return i >= 0 ? i : 0;
}
