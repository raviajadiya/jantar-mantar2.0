import 'package:flutter/material.dart';
import '../engine/game_controller.dart';

/// Top-center HUD Bar showing player badge, flags collected, level and threat status
class HudTopBar extends StatelessWidget {
  final GameController controller;
  final VoidCallback onOpenHeroCustomizer;

  const HudTopBar({
    super.key,
    required this.controller,
    required this.onOpenHeroCustomizer,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xF20F172A),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.6),
              width: 1.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            children: [
              // Player Profile Badge
              InkWell(
                onTap: onOpenHeroCustomizer,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        controller.selectedCountry.emoji,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        controller.playerName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              _buildDivider(),

              // Flags Count
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🚩', style: TextStyle(fontSize: 15)),
                  const SizedBox(width: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'FLAGS',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        '${controller.collectedCount} / ${controller.totalFlagsCount}',
                        style: const TextStyle(
                          color: Color(0xFFFBBF24),
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              _buildDivider(),

              // Level Indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF59E0B), width: 1.2),
                ),
                child: Text(
                  '⭐ L${controller.currentLevel}',
                  style: const TextStyle(
                    color: Color(0xFFFCD34D),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              // Threat Status Badge
              _buildThreatBadge(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 20,
      color: Colors.white24,
    );
  }

  Widget _buildThreatBadge() {
    if (controller.graceTimer > 0) {
      return _buildThreatContainer(
        text: '🛡️ SAFE (${controller.graceTimer.ceil()}s)',
        bgColor: const Color(0xFF065F46),
        borderColor: const Color(0xFF10B981),
      );
    }

    if (controller.areAllFlagsCollected) {
      return _buildThreatContainer(
        text: '✨ 🧢 CLAIM CAP AT CENTER!',
        bgColor: const Color(0xFFB45309),
        borderColor: const Color(0xFFF59E0B),
      );
    }

    if (controller.isAnyPoliceChasing()) {
      return _buildThreatContainer(
        text: '🚨 CHASE ALERT!',
        bgColor: const Color(0xFF991B1B),
        borderColor: const Color(0xFFEF4444),
      );
    }

    final dist = controller.getClosestPoliceDistance();
    if (dist < 260.0) {
      return _buildThreatContainer(
        text: '⚠️ POLICE NEARBY',
        bgColor: const Color(0xFF92400E),
        borderColor: const Color(0xFFF59E0B),
      );
    }

    return _buildThreatContainer(
      text: '🟢 SAFE',
      bgColor: const Color(0xFF064E3B),
      borderColor: const Color(0xFF059669),
    );
  }

  Widget _buildThreatContainer({
    required String text,
    required Color bgColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
