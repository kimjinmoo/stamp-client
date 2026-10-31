import 'package:flutter/material.dart';

/// DESIGN.md B2C Consumer Design System 컬러 토큰
class AppColors {
  AppColors._();

  // Brand & Accent Colors
  static const Color primary = Color(0xFFFF5A5F); // Zesty Coral
  static const Color primaryActive = Color(0xFFE04348); // Coral Pressed
  static const Color primarySoft = Color(0xFFFFF0F1); // Coral Tint
  static const Color secondary = Color(0xFF00D19A); // Fresh Mint
  static const Color secondarySoft = Color(0xFFE6FBF5); // Mint Tint
  static const Color accentPop = Color(0xFFFFB800); // Sunny Amber (랭킹 1위/별점)

  // Surface & Canvas
  static const Color canvas = Color(0xFFFFFFFF); // Pure White
  static const Color surfaceSoft = Color(0xFFF8FAFC); // Cool Alabaster
  static const Color surfaceStrong = Color(0xFFF1F5F9); // Slate Wash
  static const Color surfaceGlass = Color(0xD1FFFFFF); // Floating Glass (82% opacity)

  // Typography & Ink
  static const Color ink = Color(0xFF111827); // Deep Charcoal
  static const Color body = Color(0xFF334155); // Slate Body
  static const Color muted = Color(0xFF64748B); // Cool Muted
  static const Color mutedSoft = Color(0xFF94A3B8); // Placeholder
  static const Color onPrimary = Color(0xFFFFFFFF); // Pure White on Coral/Mint

  // Hairlines & Semantic
  static const Color hairline = Color(0xFFE2E8F0);
  static const Color hairlineSoft = Color(0xFFF1F5F9);
  static const Color borderFocus = Color(0xFF111827);
  static const Color error = Color(0xFFF43F5E);
  static const Color scrim = Color(0x730F172A);

  // Shadows
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color.fromRGBO(15, 23, 42, 0.04),
      offset: Offset(0, 0),
      blurRadius: 1,
      spreadRadius: 1,
    ),
    BoxShadow(
      color: Color.fromRGBO(15, 23, 42, 0.06),
      offset: Offset(0, 4),
      blurRadius: 12,
      spreadRadius: -2,
    ),
    BoxShadow(
      color: Color.fromRGBO(15, 23, 42, 0.04),
      offset: Offset(0, 12),
      blurRadius: 24,
      spreadRadius: -4,
    ),
  ];

  static const List<BoxShadow> primaryGlow = [
    BoxShadow(
      color: Color.fromRGBO(255, 90, 95, 0.38),
      offset: Offset(0, 8),
      blurRadius: 20,
      spreadRadius: -4,
    ),
  ];

  static const List<BoxShadow> mintGlow = [
    BoxShadow(
      color: Color.fromRGBO(0, 209, 154, 0.35),
      offset: Offset(0, 8),
      blurRadius: 20,
      spreadRadius: -4,
    ),
  ];
}

/// DESIGN.md 코너 곡률 토큰
class AppRadius {
  AppRadius._();

  static const double sm = 10.0;
  static const double md = 14.0;
  static const double lg = 20.0;
  static const double xl = 28.0;
  static const double full = 999.0;

  static const BorderRadius roundedSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius roundedMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius roundedLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius roundedXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius roundedFull = BorderRadius.all(Radius.circular(full));
}
