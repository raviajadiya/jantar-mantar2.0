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
            color: const Color(0xF70F172A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.55),
              width: 1.8,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black87,
                blurRadius: 30,
                offset: Offset(0, 10),
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
                  children: [
                    // Theme Switcher Pills
                    _buildThemePills(c),

                    const SizedBox(height: 16),

                    // Name Input with Dice
                    _buildNameInput(c),

                    const SizedBox(height: 14),

                    // Country Faction Dropdown
                    _buildCountryDropdown(c),

                    const SizedBox(height: 20),

                    // Start Game Button
                    _buildStartButton(),

                    const SizedBox(height: 12),

                    // Hint
                    const Text(
                      '💡 Evade Delhi Police, collect all flags & reach the Gandhi Cap at Center to Win!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
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
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
        ),
        border: Border(
          bottom: BorderSide(color: Color(0xFF334155), width: 1.5),
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
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF0F172A),
                      border: Border.all(color: const Color(0xFFF59E0B), width: 2.0),
                    ),
                    child: Center(
                      child: Text(
                        '${c.selectedCountry.emoji} ✊',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'PROTESTER',
                    style: TextStyle(
                      color: Color(0xFFFBBF24),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
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
                        scale: 1.0 + _pulseAnim.value * 0.15,
                        child: child,
                      );
                    },
                    child: const Text('⚡', style: TextStyle(fontSize: 24)),
                  ),
                  const Text(
                    'VS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),

              // Police Fighter Side
              const Column(
                children: [
                  CircleAvatar(
                    radius: 29,
                    backgroundColor: Color(0xFF0F172A),
                    child: Center(
                      child: Text('🚨 👮', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'POLICE',
                    style: TextStyle(
                      color: Color(0xFFEF4444),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'JANTAR MANTAR 2.0',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemePills(GameController c) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => c.switchTheme(MapThemes.dark),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: c.currentTheme.isDark ? const Color(0xFFF59E0B) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    '🌙 DARK',
                    style: TextStyle(
                      color: c.currentTheme.isDark ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => c.switchTheme(MapThemes.light),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: !c.currentTheme.isDark ? const Color(0xFFF59E0B) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    '☀️ LIGHT',
                    style: TextStyle(
                      color: !c.currentTheme.isDark ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
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
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              labelText: 'Hero Name',
              labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
              filled: true,
              fillColor: const Color(0xFF1E293B),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF334155)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF334155)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFF59E0B), width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            onChanged: (val) {
              c.setPlayerProfile(val, c.selectedCountry);
            },
            onSubmitted: (_) => widget.onStart(),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: _pickRandomName,
          icon: const Text('🎲', style: TextStyle(fontSize: 22)),
          tooltip: 'Random Name',
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFF334155)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCountryDropdown(GameController c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<CountryFaction>(
          value: c.selectedCountry,
          dropdownColor: const Color(0xFF1E293B),
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFF59E0B)),
          items: CountryData.countries.map((country) {
            return DropdownMenuItem<CountryFaction>(
              value: country,
              child: Row(
                children: [
                  Text(country.emoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Text(
                    country.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    country.perk,
                    style: TextStyle(
                      color: country.color,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
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
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.3 + _pulseAnim.value * 0.25),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: child,
        );
      },
      child: ElevatedButton(
        onPressed: widget.onStart,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF59E0B),
          foregroundColor: const Color(0xFF0F172A),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('▶', style: TextStyle(fontSize: 18)),
            SizedBox(width: 8),
            Text(
              'START GAME',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
