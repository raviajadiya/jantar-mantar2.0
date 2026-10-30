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

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

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

    // 2. Pulse Glow Animation for Continue Button
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // 3. 4-second Countdown Timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
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
    _pulseController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final nextLevel = c.currentLevel + 1;

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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF22C55E).withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Color(0xFF22C55E),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Unlocking Level $nextLevel in $_countdown s...',
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
              Column(
                children: [
                  // CONTINUE NEXT LEVEL BUTTON (Identical to Home Start Game button!)
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      final glowAlpha = 0.4 + _pulseAnimation.value * 0.35;
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
                          onTap: widget.onContinue,
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
                                Text(
                                  'CONTINUE TO LEVEL $nextLevel',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.4,
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
                  ),

                  const SizedBox(height: 12),

                  // GO TO HOME BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: widget.onHome,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E293B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        side: const BorderSide(color: Color(0xFF334155), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('🏠', style: TextStyle(fontSize: 15)),
                          SizedBox(width: 8),
                          Text(
                            'GO TO HOME',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
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
