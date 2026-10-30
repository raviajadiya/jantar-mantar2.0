import 'package:flutter/material.dart';
import '../engine/game_controller.dart';

/// Minimal Top HUD Bar respecting SafeArea and showing player status
class HudTopBar extends StatelessWidget {
  final GameController controller;
  final VoidCallback onOpenHeroCustomizer;
  final VoidCallback? onHome;

  const HudTopBar({
    super.key,
    required this.controller,
    required this.onOpenHeroCustomizer,
    this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 8,
      left: 10,
      right: 10,
      child: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 20,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xF20F172A),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.65),
              width: 1.6,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Home Button
                if (onHome != null) ...[
                  InkWell(
                    onTap: onHome,
                    borderRadius: BorderRadius.circular(10),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('🏠', style: TextStyle(fontSize: 15)),
                        ],
                      ),
                    ),
                  ),
                  _buildDivider(),
                ],

                // Player Profile Badge
                InkWell(
                  onTap: onOpenHeroCustomizer,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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
                    const Text('🚩', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 5),
                    Text(
                      '${controller.collectedCount}/${controller.totalFlagsCount}',
                      style: const TextStyle(
                        color: Color(0xFFFBBF24),
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),

                _buildDivider(),

                // Level Indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFF59E0B), width: 1.2),
                  ),
                  child: Text(
                    '⭐ L${controller.currentLevel}',
                    style: const TextStyle(
                      color: Color(0xFFFCD34D),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Threat Status Badge
                _buildThreatBadge(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 18,
      margin: const EdgeInsets.symmetric(horizontal: 8),
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
        text: '✨ CLAIM TROPHY!',
        bgColor: const Color(0xFFB45309),
        borderColor: const Color(0xFFF59E0B),
      );
    }

    if (controller.isAnyPoliceChasing()) {
      return _buildThreatContainer(
        text: '🚨 CHASE!',
        bgColor: const Color(0xFF991B1B),
        borderColor: const Color(0xFFEF4444),
      );
    }

    final dist = controller.getClosestPoliceDistance();
    if (dist < 260.0) {
      return _buildThreatContainer(
        text: '⚠️ POLICE',
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
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
