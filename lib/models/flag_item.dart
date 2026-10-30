import 'package:flutter/material.dart';

/// Protest Flag to collect on the road network
class FlagItem {
  final String id;
  String name;
  String label;
  Color color;
  List<Color> stripeColors;
  String countryEmoji;
  final double x;
  final double y;
  bool isCollected;
  final double pulseOffset;

  FlagItem({
    required this.id,
    required this.name,
    required this.label,
    required this.color,
    required this.stripeColors,
    required this.countryEmoji,
    required this.x,
    required this.y,
    this.isCollected = false,
    this.pulseOffset = 0.0,
  });

  Offset get position => Offset(x, y);
}
