import 'package:flutter/material.dart';
import '../engine/game_controller.dart';

/// Arrested / Detained dialog when caught by Delhi Police
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
    final officerName = controller.arrestingOfficer?.name ?? 'Delhi Police';

    return Center(
      child: Container(
        width: 380,
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
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onRestart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      '🔄 RESTART GAME',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
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
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      '🏠 GO TO HOME',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
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
