import 'package:flutter/material.dart';

/// Map theme representation (Dark Midnight Slate vs Light Sandstone)
class MapTheme {
  final String id;
  final String name;
  final bool isDark;
  final Color bgCanvas;
  final Color roadAsphalt;
  final Color curbColor;
  final Color roadMarking;
  final Color centerGrass;
  final Color centerBorder;
  final Color centerAura;
  final List<Color> blockColors;
  final Color blockBorder;
  final Color blockShadow;
  final Color accent;

  const MapTheme({
    required this.id,
    required this.name,
    required this.isDark,
    required this.bgCanvas,
    required this.roadAsphalt,
    required this.curbColor,
    required this.roadMarking,
    required this.centerGrass,
    required this.centerBorder,
    required this.centerAura,
    required this.blockColors,
    required this.blockBorder,
    required this.blockShadow,
    required this.accent,
  });
}

class MapThemes {
  static const MapTheme dark = MapTheme(
    id: 'jantar_dark',
    name: 'Jantar Mantar (Dark Mode)',
    isDark: true,
    bgCanvas: Color(0xFF0B1120),
    roadAsphalt: Color(0xFF1E293B),
    curbColor: Color(0xFF334155),
    roadMarking: Color(0xFFF8FAFC),
    centerGrass: Color(0xFF15803D),
    centerBorder: Color(0xFFEA580C),
    centerAura: Color(0x99F59E0B),
    blockColors: [
      Color(0xFF162032),
      Color(0xFF1A273E),
      Color(0xFF131D2E),
      Color(0xFF192539),
      Color(0xFF1C2B42),
      Color(0xFF152135),
    ],
    blockBorder: Color(0xFF2D3D54),
    blockShadow: Color(0x73000000),
    accent: Color(0xFFF59E0B),
  );

  static const MapTheme light = MapTheme(
    id: 'jantar_light',
    name: 'Jantar Mantar (Light Mode)',
    isDark: false,
    bgCanvas: Color(0xFFE3DFD3),
    roadAsphalt: Color(0xFF3D444D),
    curbColor: Color(0xFFBFB5A2),
    roadMarking: Color(0xFFF4EDE2),
    centerGrass: Color(0xFF4A7C3F),
    centerBorder: Color(0xFF932D19),
    centerAura: Color(0x73F59E0B),
    blockColors: [
      Color(0xFFEAE2D3),
      Color(0xFFF1F5F9),
      Color(0xFFFED7AA),
      Color(0xFFE2E8F0),
      Color(0xFFFEF08A),
      Color(0xFFE2D9CC),
    ],
    blockBorder: Color(0xFF94A3B8),
    blockShadow: Color(0x38000000),
    accent: Color(0xFFD97706),
  );
}
