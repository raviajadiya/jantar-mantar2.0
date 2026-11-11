import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../engine/game_controller.dart';

/// Arrested / Detained dialog when caught by Patrol Police
class ArrestModal extends StatelessWidget {
  final GameController controller;
  final VoidCallback onRestart;
  final VoidCallback onHome;

  const ArrestModal({
    super.key,
    required this.controller,
    required this.onRestart,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    final officerName = controller.arrestingOfficer?.name ?? 'Patrol Police';

    return Center(
      child: Container(
        width: math.min(380.0, MediaQuery.of(context).size.width * 0.90),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        decoration: BoxDecoration(
          color: const Color(0xF50F172A),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFEF4444), width: 2.0),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66EF4444),
              blurRadius: 28,
              spreadRadius: 3,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🚨👮🚔', style: TextStyle(fontSize: 52)),
            const SizedBox(height: 12),
            const Text(
              'PROTESTER DETAINED!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFEF4444),
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Intercepted by $officerName on road corridor.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFCBD5E1),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF334155), width: 1.2),
              ),
              child: Text(
                '⭐ LEVEL ${controller.currentLevel}  •  🚩 ${controller.collectedCount}/${controller.totalFlagsCount} Flags',
                style: const TextStyle(
                  color: Color(0xFFFCD34D),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onRestart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '🔄 RETRY LEVEL ${controller.currentLevel}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onHome,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF334155),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '🏠 GO TO HOME',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
