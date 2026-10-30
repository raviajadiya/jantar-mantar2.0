import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/country_data.dart';
import '../constants/map_themes.dart';
import '../engine/game_controller.dart';
import '../engine/game_audio.dart';

/// Compact Game Card Start Screen & Customizer Modal
class StartCardDialog extends StatefulWidget {
  final GameController controller;
  final VoidCallback onStart;

  const StartCardDialog({
    super.key,
    required this.controller,
    required this.onStart,
  });

  @override
  State<StartCardDialog> createState() => _StartCardDialogState();
}

class _StartCardDialogState extends State<StartCardDialog> with SingleTickerProviderStateMixin {
  late TextEditingController _nameController;
  late AnimationController _pulseAnim;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.controller.playerName);
    _pulseAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pulseAnim.dispose();
    super.dispose();
  }

  void _pickRandomName() {
    GameAudio.playSelect();
    final names = CountryData.randomNames;
    final rName = names[math.Random().nextInt(names.length)];
    setState(() {
      _nameController.text = rName;
    });
    widget.controller.setPlayerProfile(rName, widget.controller.selectedCountry);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;

    return Center(
      child: SingleChildScrollView(
        child: Container(
          width: math.min(420.0, MediaQuery.of(context).size.width * 0.92),
          margin: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: const Color(0xFA0F172A),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.6),
              width: 2.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black87,
                blurRadius: 36,
                offset: Offset(0, 12),
              ),
              BoxShadow(
                color: Color(0x33F59E0B),
                blurRadius: 20,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Versus Banner Header
              _buildBannerHeader(c),

              // 2. Body Customizer
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Label
                    const Padding(
                      padding: EdgeInsets.only(left: 2, bottom: 6),
                      child: Text(
                        'MAP THEME',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),

                    // Theme Switcher Pills
                    _buildThemePills(c),

                    const SizedBox(height: 16),

                    // Label
                    const Padding(
                      padding: EdgeInsets.only(left: 2, bottom: 6),
                      child: Text(
                        'PLAYER NAME',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),

                    // Name Input with Dice
                    _buildNameInput(c),

                    const SizedBox(height: 16),

                    // Label
                    const Padding(
                      padding: EdgeInsets.only(left: 2, bottom: 6),
                      child: Text(
                        'FACTION / COUNTRY PERK',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),

                    // Country Faction Dropdown
                    _buildCountryDropdown(c),

                    const SizedBox(height: 22),

                    // Start Game Button
                    _buildStartButton(),

                    const SizedBox(height: 16),

                    // Hint Container
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B).withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.3),
                          width: 1.2,
                        ),
                      ),
                      child: const Row(
                        children: [
                          Text('💡', style: TextStyle(fontSize: 16)),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Evade Delhi Police, collect all flags & reach Gandhi Cap at center to win!',
                              style: TextStyle(
                                color: Color(0xFFE2E8F0),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBannerHeader(GameController c) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        border: Border(
          bottom: BorderSide(color: Color(0xFF334155), width: 1.8),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Protester Fighter Side
              Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(color: const Color(0xFFF59E0B), width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                          blurRadius: 14,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        '✊',
                        style: TextStyle(fontSize: 30),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'PROTESTER',
                    style: TextStyle(
                      color: Color(0xFFFBBF24),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),

              // VS Emblem
              Column(
                children: [
                  AnimatedBuilder(
                    animation: _pulseAnim,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + _pulseAnim.value * 0.14,
                        child: child,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF0F172A),
                        border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x44F59E0B),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Text('⚡', style: TextStyle(fontSize: 22)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'VS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),

              // Police Fighter Side
              Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(color: const Color(0xFFEF4444), width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.4),
                          blurRadius: 14,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        '👮',
                        style: TextStyle(fontSize: 30),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'POLICE',
                    style: TextStyle(
                      color: Color(0xFFEF4444),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFFBBF24), Colors.white, Color(0xFFFBBF24)],
            ).createShader(bounds),
            child: const Text(
              'JANTAR MANTAR 2.0',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemePills(GameController c) {
    final isDark = c.currentTheme.isDark;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155), width: 1.5),
      ),
      child: Row(
        children: [
          // DARK THEME BUTTON
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => c.switchTheme(MapThemes.dark),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    gradient: isDark
                        ? const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isDark
                        ? [
                            BoxShadow(
                              color: const Color(0xFF6366F1).withValues(alpha: 0.45),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🌙', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Text(
                        'DARK MODE',
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF94A3B8),
                          fontSize: 12.5,
                          fontWeight: isDark ? FontWeight.w800 : FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          // LIGHT THEME BUTTON
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => c.switchTheme(MapThemes.light),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    gradient: !isDark
                        ? const LinearGradient(
                            colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: !isDark
                        ? [
                            BoxShadow(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.45),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('☀️', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Text(
                        'LIGHT MODE',
                        style: TextStyle(
                          color: !isDark ? Colors.white : const Color(0xFF94A3B8),
                          fontSize: 12.5,
                          fontWeight: !isDark ? FontWeight.w800 : FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameInput(GameController c) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: 'Enter your hero name',
              hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
              filled: true,
              fillColor: const Color(0xFF0F172A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF334155), width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF334155), width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFF59E0B), width: 2.0),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onChanged: (val) {
              c.setPlayerProfile(val, c.selectedCountry);
            },
            onSubmitted: (_) => widget.onStart(),
          ),
        ),
        const SizedBox(width: 10),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _pickRandomName,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.6), width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22F59E0B),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Text('🎲', style: TextStyle(fontSize: 22)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCountryDropdown(GameController c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155), width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<CountryFaction>(
          value: c.selectedCountry,
          dropdownColor: const Color(0xFF0F172A),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFFF59E0B), size: 26),
          items: CountryData.countries.map((country) {
            return DropdownMenuItem<CountryFaction>(
              value: country,
              child: Row(
                children: [
                  Text(country.emoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Text(
                    country.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: country.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: country.color.withValues(alpha: 0.4), width: 1),
                    ),
                    child: Text(
                      country.perk,
                      style: TextStyle(
                        color: country.color,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (selected) {
            if (selected != null) {
              c.setPlayerProfile(_nameController.text, selected);
            }
          },
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, child) {
        final glowAlpha = 0.4 + _pulseAnim.value * 0.35;
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF59E0B).withValues(alpha: glowAlpha),
                blurRadius: 22,
                spreadRadius: 2,
              ),
            ],
          ),
          child: child,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFFF59E0B), Color(0xFFEA580C)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.35),
            width: 1.2,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onStart,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.black26,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'START GAME',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.6,
                      shadows: [
                        Shadow(
                          color: Colors.black45,
                          offset: Offset(0, 1.5),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
