import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/country_data.dart';
import '../constants/map_themes.dart';
import '../engine/game_controller.dart';
import '../engine/game_audio.dart';

/// Dedicated Settings & Customizer Modal Dialog
class SettingsDialog extends StatefulWidget {
  final GameController controller;

  const SettingsDialog({
    super.key,
    required this.controller,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.controller.playerName);
  }

  @override
  void dispose() {
    _nameController.dispose();
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

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: math.min(420.0, MediaQuery.of(context).size.width * 0.92),
        decoration: BoxDecoration(
          color: const Color(0xFB0F172A),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xFF38BDF8).withValues(alpha: 0.6),
            width: 2.0,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black87,
              blurRadius: 30,
              offset: Offset(0, 10),
            ),
            BoxShadow(
              color: Color(0x3338BDF8),
              blurRadius: 20,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                border: Border(
                  bottom: BorderSide(color: Color(0xFF334155), width: 1.5),
                ),
              ),
              child: Row(
                children: [
                  const Text('⚙️', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  const Text(
                    'GAME SETTINGS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      GameAudio.playSelect();
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8), size: 24),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Audio Sound Toggle
                  const Text(
                    'AUDIO SOUND',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildSoundPills(),

                  const SizedBox(height: 16),

                  // 2. Theme Selection
                  const Text(
                    'MAP THEME',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildThemePills(c),

                  const SizedBox(height: 16),

                  // 3. Player Name
                  const Text(
                    'PLAYER HERO NAME',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildNameInput(c),

                  const SizedBox(height: 16),

                  // 4. Country Faction
                  const Text(
                    'FACTION & SPECIAL PERK',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildCountryDropdown(c),

                  const SizedBox(height: 22),

                  // Done Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        GameAudio.playSelect();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF38BDF8),
                        foregroundColor: const Color(0xFF0F172A),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        'SAVE & CLOSE',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoundPills() {
    final isEnabled = GameAudio.isSoundEnabled;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF334155), width: 1.5),
      ),
      child: Row(
        children: [
          // SOUND ON
          Expanded(
            child: InkWell(
              onTap: () async {
                await GameAudio.setSoundEnabled(true);
                setState(() {});
              },
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: isEnabled
                      ? const LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF059669)],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isEnabled
                      ? [
                          BoxShadow(
                            color: const Color(0xFF10B981).withValues(alpha: 0.4),
                            blurRadius: 8,
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🔊', style: TextStyle(fontSize: 15)),
                    const SizedBox(width: 6),
                    Text(
                      'SOUND ON',
                      style: TextStyle(
                        color: isEnabled ? Colors.white : const Color(0xFF94A3B8),
                        fontSize: 12,
                        fontWeight: isEnabled ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          // SOUND OFF
          Expanded(
            child: InkWell(
              onTap: () async {
                await GameAudio.setSoundEnabled(false);
                setState(() {});
              },
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: !isEnabled
                      ? const LinearGradient(
                          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: !isEnabled
                      ? [
                          BoxShadow(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.4),
                            blurRadius: 8,
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🔇', style: TextStyle(fontSize: 15)),
                    const SizedBox(width: 6),
                    Text(
                      'SOUND OFF',
                      style: TextStyle(
                        color: !isEnabled ? Colors.white : const Color(0xFF94A3B8),
                        fontSize: 12,
                        fontWeight: !isEnabled ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF334155), width: 1.5),
      ),
      child: Row(
        children: [
          // DARK MODE
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() => c.switchTheme(MapThemes.dark));
              },
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: isDark
                      ? const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isDark
                      ? [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                            blurRadius: 8,
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🌙', style: TextStyle(fontSize: 15)),
                    const SizedBox(width: 6),
                    Text(
                      'DARK MODE',
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF94A3B8),
                        fontSize: 12,
                        fontWeight: isDark ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          // LIGHT MODE
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() => c.switchTheme(MapThemes.light));
              },
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: !isDark
                      ? const LinearGradient(
                          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: !isDark
                      ? [
                          BoxShadow(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                            blurRadius: 8,
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('☀️', style: TextStyle(fontSize: 15)),
                    const SizedBox(width: 6),
                    Text(
                      'LIGHT MODE',
                      style: TextStyle(
                        color: !isDark ? Colors.white : const Color(0xFF94A3B8),
                        fontSize: 12,
                        fontWeight: !isDark ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                  ],
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
              hintText: 'Enter hero name',
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
                borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 2.0),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            onChanged: (val) {
              c.setPlayerProfile(val, c.selectedCountry);
            },
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: _pickRandomName,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.6), width: 1.5),
            ),
            child: const Text('🎲', style: TextStyle(fontSize: 20)),
          ),
        ),
      ],
    );
  }

  Widget _buildCountryDropdown(GameController c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
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
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF38BDF8), size: 24),
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: country.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: country.color.withValues(alpha: 0.4), width: 1),
                    ),
                    child: Text(
                      country.perk,
                      style: TextStyle(
                        color: country.color,
                        fontSize: 10,
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
              setState(() {
                c.setPlayerProfile(_nameController.text, selected);
              });
            }
          },
        ),
      ),
    );
  }
}
