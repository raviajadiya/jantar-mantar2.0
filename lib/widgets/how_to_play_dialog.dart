import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../engine/game_audio.dart';

/// Interactive How to Play / Game Guide Modal Dialog
class HowToPlayDialog extends StatelessWidget {
  const HowToPlayDialog({super.key});

  static Future<void> show(BuildContext context) {
    GameAudio.playSelect();
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const HowToPlayDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final dialogWidth = math.min(430.0, size.width * 0.92);
    final maxHeight = size.height * 0.85;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: Container(
          width: dialogWidth,
          constraints: BoxConstraints(maxHeight: maxHeight),
          decoration: BoxDecoration(
            color: const Color(0xFB0F172A),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.8),
              width: 1.8,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black87,
                blurRadius: 32,
                offset: Offset(0, 10),
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
              // 1. Header
              _buildHeader(context),

              const Divider(color: Color(0xFF334155), height: 1, thickness: 1.2),

              // 2. Scrollable Body
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Subtitle Banner
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: const Row(
                          children: [
                            Text('⚡', style: TextStyle(fontSize: 22)),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Complete each level in 4 simple steps to lead the Dharna movement!',
                                style: TextStyle(
                                  color: Color(0xFFE2E8F0),
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Step 1
                      _buildStepCard(
                        stepNumber: '1',
                        icon: '🚩',
                        badgeColor: const Color(0xFFF59E0B),
                        title: 'COLLECT PROTEST FLAGS',
                        desc: 'Move across circular road intersections and collect all scattered protest flags. Look at the top bar to track remaining flags.',
                      ),

                      const SizedBox(height: 12),

                      // Step 2
                      _buildStepCard(
                        stepNumber: '2',
                        icon: '👮',
                        badgeColor: const Color(0xFFEF4444),
                        title: 'EVADE PATROL POLICE',
                        desc: 'Police officers actively patrol roads. Stay away from their red vision cone. If caught, you get arrested! You have a 4s grace immunity at level start.',
                      ),

                      const SizedBox(height: 12),

                      // Step 3
                      _buildStepCard(
                        stepNumber: '3',
                        icon: '🕹️',
                        badgeColor: const Color(0xFF38BDF8),
                        title: 'SMOOTH ROAD NAVIGATION',
                        desc: 'Use the bottom-left Virtual Joystick to move along the circuit, or tap on any road junction to walk there automatically.',
                      ),

                      const SizedBox(height: 12),

                      // Step 4
                      _buildStepCard(
                        stepNumber: '4',
                        icon: '🏆',
                        badgeColor: const Color(0xFF10B981),
                        title: 'REACH JANTAR MANTAR (CENTER)',
                        desc: 'Once all flags are gathered, the central Golden Trophy unlocks. Reach the center circle to win the level and advance!',
                      ),

                      const SizedBox(height: 16),

                      // Pro Tips Box
                      _buildProTipsBox(),
                    ],
                  ),
                ),
              ),

              const Divider(color: Color(0xFF334155), height: 1, thickness: 1.2),

              // 3. Bottom Action Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      GameAudio.playSelect();
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      foregroundColor: const Color(0xFF0F172A),
                      elevation: 2,
                      shadowColor: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('✊', style: TextStyle(fontSize: 18)),
                        SizedBox(width: 8),
                        Text(
                          'GOT IT! LET\'S PLAY',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 14, 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
              border: Border.all(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                width: 1.2,
              ),
            ),
            child: const Icon(
              Icons.help_outline_rounded,
              color: Color(0xFFF59E0B),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HOW TO PLAY',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Game Rules & Step-by-Step Guide',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              GameAudio.playSelect();
              Navigator.of(context).pop();
            },
            icon: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1E293B),
                border: Border.all(color: const Color(0xFF334155), width: 1),
              ),
              child: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF94A3B8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard({
    required String stepNumber,
    required String icon,
    required Color badgeColor,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF334155),
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Number Badge
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: badgeColor.withValues(alpha: 0.5),
                width: 1.2,
              ),
            ),
            child: Center(
              child: Text(
                stepNumber,
                style: TextStyle(
                  color: badgeColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(icon, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: badgeColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(
                    color: Color(0xFFCBD5E1),
                    fontSize: 12,
                    height: 1.38,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProTipsBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('💡', style: TextStyle(fontSize: 15)),
              SizedBox(width: 6),
              Text(
                'PRO TIPS',
                style: TextStyle(
                  color: Color(0xFF38BDF8),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Text(
            '• You can only move along the road circuit.\n• Watch police sirens and yellow/red radar warnings.\n• Use Settings ⚙️ to change your Player Name, Country Flag, or Sound effects.',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 11.5,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

