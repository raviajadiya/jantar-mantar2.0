import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../engine/game_controller.dart';
import '../engine/game_audio.dart';
import 'settings_dialog.dart';

/// Compact Arcade Game Start Screen Modal
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
  late AnimationController _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseAnim.dispose();
    super.dispose();
  }

  void _openSettings() {
    GameAudio.playSelect();
    showDialog(
      context: context,
      builder: (context) => SettingsDialog(controller: widget.controller),
    ).then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;

    return Center(
      child: SingleChildScrollView(
        child: Container(
          width: math.min(400.0, MediaQuery.of(context).size.width * 0.90),
          margin: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xF20F172A),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.7),
              width: 2.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black87,
                blurRadius: 32,
                offset: Offset(0, 10),
              ),
              BoxShadow(
                color: Color(0x33F59E0B),
                blurRadius: 18,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Versus Banner Header
              _buildBannerHeader(),

              // 2. Compact Body
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                child: Column(
                  children: [
                    // Profile Summary Bar + Settings Button
                    _buildProfileSettingsBar(c),

                    const SizedBox(height: 16),

                    // Big Gaming Start Button
                    _buildStartButton(),

                    const SizedBox(height: 12),

                    // Hint line
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('💡 ', style: TextStyle(fontSize: 13)),
                        Expanded(
                          child: Text(
                            'Evade Police, collect flags & reach Golden Trophy at center!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFFCBD5E1),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildBannerHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                      ),
                      border: Border.all(color: const Color(0xFFF59E0B), width: 2.2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('✊', style: TextStyle(fontSize: 26)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'PROTESTER',
                    style: TextStyle(
                      color: Color(0xFFFBBF24),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
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
                        scale: 1.0 + _pulseAnim.value * 0.12,
                        child: child,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF0F172A),
                        border: Border.all(color: const Color(0xFFF59E0B), width: 1.2),
                      ),
                      child: const Text('⚡', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'VS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),

              // Police Fighter Side
              Column(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                      ),
                      border: Border.all(color: const Color(0xFFEF4444), width: 2.2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.35),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('👮', style: TextStyle(fontSize: 26)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'POLICE',
                    style: TextStyle(
                      color: Color(0xFFEF4444),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFFBBF24), Colors.white, Color(0xFFFBBF24)],
            ).createShader(bounds),
            child: const Text(
              'JANTAR MANTAR 2.0',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSettingsBar(GameController c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF334155), width: 1.2),
      ),
      child: Row(
        children: [
          // Emoji Flag
          Text(c.selectedCountry.emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          // Player Name & Perk
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.playerName.isEmpty ? 'Protester' : c.playerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${c.selectedCountry.name} • ${c.selectedCountry.perk}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: c.selectedCountry.color,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Settings Gear Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _openSettings,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.6), width: 1.2),
                ),
                child: const Row(
                  children: [
                    Text('⚙️', style: TextStyle(fontSize: 14)),
                    SizedBox(width: 4),
                    Text(
                      'SETTINGS',
                      style: TextStyle(
                        color: Color(0xFF38BDF8),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
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
                blurRadius: 20,
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
              padding: const EdgeInsets.symmetric(vertical: 14),
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
