import 'dart:async';
import 'package:flutter/material.dart';
import '../engine/game_controller.dart';

/// Level victory dialog with animated trophy and 4-second button unlock countdown
class VictoryModal extends StatefulWidget {
  final GameController controller;
  final VoidCallback onContinue;
  final VoidCallback onHome;

  const VictoryModal({
    super.key,
    required this.controller,
    required this.onContinue,
    required this.onHome,
  });

  @override
  State<VictoryModal> createState() => _VictoryModalState();
}

class _VictoryModalState extends State<VictoryModal> with TickerProviderStateMixin {
  late AnimationController _swingController;
  late Animation<double> _swingAnimation;

  int _countdown = 4;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // 1. Trophy Swing Animation (left-to-right rotation)
    _swingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _swingAnimation = Tween<double>(begin: -0.15, end: 0.15).animate(
      CurvedAnimation(parent: _swingController, curve: Curves.easeInOut),
    );

    // 2. 4-second Countdown Timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        setState(() {
          _countdown--;
        });
      } else {
        setState(() {
          _countdown = 0;
        });
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _swingController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;

    return Center(
      child: Container(
        width: 380,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: BoxDecoration(
          color: const Color(0xF50F172A),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFF22C55E), width: 2.2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x6622C55E),
              blurRadius: 32,
              spreadRadius: 3,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated Swinging Golden Trophy
            AnimatedBuilder(
              animation: _swingAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _swingAnimation.value,
                  child: child,
                );
              },
              child: const Text('🏆', style: TextStyle(fontSize: 68)),
            ),

            const SizedBox(height: 12),

            Text(
              'LEVEL ${c.currentLevel} COMPLETED!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF22C55E),
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'All flags secured & Trophy claimed at Jantar Mantar!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFCBD5E1),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 24),

            // 4-Second Countdown OR Action Buttons
            if (_countdown > 0) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.5), width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Color(0xFF22C55E),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Unlocking next level in $_countdown s...',
                      style: const TextStyle(
                        color: Color(0xFF86EFAC),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Action Buttons revealed after 4s
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: widget.onContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF59E0B),
                        foregroundColor: const Color(0xFF0F172A),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        '▶ CONTINUE NEXT',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: widget.onHome,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF334155),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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
          ],
        ),
      ),
    );
  }
}
