import 'package:flutter/material.dart';

/// Country faction representing the protester's movement, perks and flag stripes
class CountryFaction {
  final String code;
  final String name;
  final String emoji;
  final String perk;
  final Color color;
  final List<Color> stripeColors;

  const CountryFaction({
    required this.code,
    required this.name,
    required this.emoji,
    required this.perk,
    required this.color,
    required this.stripeColors,
  });
}

class CountryData {
  static const List<CountryFaction> countries = [
    CountryFaction(
      code: 'IND',
      name: 'India',
      emoji: '🇮🇳',
      perk: '⚡ Satyagraha Aura (+Speed)',
      color: Color(0xFFF97316),
      stripeColors: [Color(0xFFFF9933), Color(0xFFFFFFFF), Color(0xFF138808)],
    ),
    CountryFaction(
      code: 'USA',
      name: 'USA',
      emoji: '🇺🇸',
      perk: '🦅 Eagle Eye (+Minimap Radar)',
      color: Color(0xFF3B82F6),
      stripeColors: [Color(0xFFB22234), Color(0xFFFFFFFF), Color(0xFF3C3B6E)],
    ),
    CountryFaction(
      code: 'GBR',
      name: 'United Kingdom',
      emoji: '🇬🇧',
      perk: '🛡️ London Shroud (+Stealth)',
      color: Color(0xFF1D4ED8),
      stripeColors: [Color(0xFF012169), Color(0xFFFFFFFF), Color(0xFFC8102E)],
    ),
    CountryFaction(
      code: 'CAN',
      name: 'Canada',
      emoji: '🇨🇦',
      perk: '🍁 Maple Rush (+Agility)',
      color: Color(0xFFEF4444),
      stripeColors: [Color(0xFFFF0000), Color(0xFFFFFFFF), Color(0xFFFF0000)],
    ),
    CountryFaction(
      code: 'JPN',
      name: 'Japan',
      emoji: '🇯🇵',
      perk: '⛩️ Shinobi Step (-Detection)',
      color: Color(0xFFDC2626),
      stripeColors: [Color(0xFFFFFFFF), Color(0xFFBC002D), Color(0xFFFFFFFF)],
    ),
    CountryFaction(
      code: 'DEU',
      name: 'Germany',
      emoji: '🇩🇪',
      perk: '⚙️ Autobahn Precision',
      color: Color(0xFFEAB308),
      stripeColors: [Color(0xFF000000), Color(0xFFDD0000), Color(0xFFFFCE00)],
    ),
    CountryFaction(
      code: 'FRA',
      name: 'France',
      emoji: '🇫🇷',
      perk: '⚜️ Bastille Call (+Morale)',
      color: Color(0xFF2563EB),
      stripeColors: [Color(0xFF0055A4), Color(0xFFFFFFFF), Color(0xFFEF4135)],
    ),
    CountryFaction(
      code: 'AUS',
      name: 'Australia',
      emoji: '🇦🇺',
      perk: '🦘 Outback Endurance',
      color: Color(0xFF0284C7),
      stripeColors: [Color(0xFF00008B), Color(0xFFFF0000), Color(0xFFFFFFFF)],
    ),
    CountryFaction(
      code: 'BRA',
      name: 'Brazil',
      emoji: '🇧🇷',
      perk: '⚡ Carnival Dash (+Sprint)',
      color: Color(0xFF16A34A),
      stripeColors: [Color(0xFF009C3B), Color(0xFFFFDF00), Color(0xFF002776)],
    ),
    CountryFaction(
      code: 'ZAF',
      name: 'South Africa',
      emoji: '🇿🇦',
      perk: '🌈 Rainbow Nation Unity',
      color: Color(0xFF059669),
      stripeColors: [Color(0xFF007749), Color(0xFFE03C31), Color(0xFF001489)],
    ),
    CountryFaction(
      code: 'ARE',
      name: 'UAE',
      emoji: '🇦🇪',
      perk: '🦅 Falcon Vision Glide',
      color: Color(0xFFDC2626),
      stripeColors: [Color(0xFF00732F), Color(0xFFFFFFFF), Color(0xFF000000)],
    ),
    CountryFaction(
      code: 'ITA',
      name: 'Italy',
      emoji: '🇮🇹',
      perk: '🍕 Vespa Drift Stamina',
      color: Color(0xFF16A34A),
      stripeColors: [Color(0xFF009246), Color(0xFFFFFFFF), Color(0xFFCE2B37)],
    ),
    CountryFaction(
      code: 'ESP',
      name: 'Spain',
      emoji: '🇪🇸',
      perk: '🐂 Matador Corner Dodge',
      color: Color(0xFFEAB308),
      stripeColors: [Color(0xFFAA151B), Color(0xFFF1BF00), Color(0xFFAA151B)],
    ),
    CountryFaction(
      code: 'GLO',
      name: 'Global Unity',
      emoji: '🏳️‍🌈',
      perk: '🌟 Ultimate Harmony Shield',
      color: Color(0xFF8B5CF6),
      stripeColors: [
        Color(0xFFEF4444),
        Color(0xFFF59E0B),
        Color(0xFF10B981),
        Color(0xFF3B82F6),
        Color(0xFF8B5CF6)
      ],
    ),
  ];

  static const List<String> randomNames = [
    'Aam Aadmi',
    'Dilli Rebel',
    'Azad Hind',
    'Kisan Sena',
    'Satyagrahi',
    'Bharat Veer',
    'Freedom Voice',
    'Inquilab',
    'Metro Commuter',
    'CP Walker',
    'Nayi Dilli Guy',
    'Desh Premi',
  ];
}
