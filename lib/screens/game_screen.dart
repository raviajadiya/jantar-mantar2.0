import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../engine/game_controller.dart';
import '../engine/game_audio.dart';
import '../painters/confetti_painter.dart';
import '../widgets/game_canvas_viewport.dart';
import '../widgets/hud_top_bar.dart';
import '../widgets/hud_zoom_widget.dart';
import '../widgets/victory_modal.dart';
import '../widgets/arrest_modal.dart';
import '../widgets/help_radar_modal.dart';
import '../widgets/settings_dialog.dart';

/// 2. Active Gameplay Screen
class GameScreen extends StatefulWidget {
  final GameController controller;

  const GameScreen({super.key, required this.controller});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late GameController _controller;
  late Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  // Keyboard input state
  final Set<LogicalKeyboardKey> _pressedKeys = {};

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;

    // Start Gameplay BGM loop
    GameAudio.playGameplayBgm();

    _ticker = createTicker((elapsed) {
      if (_lastElapsed == Duration.zero) {
        _lastElapsed = elapsed;
        return;
      }
      final delta = (elapsed - _lastElapsed).inMicroseconds / 1000000.0;
      _lastElapsed = elapsed;

      final dt = delta.clamp(0.001, 0.08);

      // Keyboard Movement
      double kx = 0;
      double ky = 0;

      if (_pressedKeys.contains(LogicalKeyboardKey.keyW) ||
          _pressedKeys.contains(LogicalKeyboardKey.arrowUp)) {
        ky -= 1.0;
      }
      if (_pressedKeys.contains(LogicalKeyboardKey.keyS) ||
          _pressedKeys.contains(LogicalKeyboardKey.arrowDown)) {
        ky += 1.0;
      }
      if (_pressedKeys.contains(LogicalKeyboardKey.keyA) ||
          _pressedKeys.contains(LogicalKeyboardKey.arrowLeft)) {
        kx -= 1.0;
      }
      if (_pressedKeys.contains(LogicalKeyboardKey.keyD) ||
          _pressedKeys.contains(LogicalKeyboardKey.arrowRight)) {
        kx += 1.0;
      }

      final isShiftPressed = _pressedKeys.contains(LogicalKeyboardKey.shiftLeft) ||
          _pressedKeys.contains(LogicalKeyboardKey.shiftRight);

      if (_controller.isGameStarted && (kx != 0 || ky != 0)) {
        _controller.manualMove(kx, ky, dt, isShiftPressed);
      }

      _controller.update(dt);
    });

    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _openSettings() {
    _controller.pauseGame();
    showDialog(
      context: context,
      builder: (context) => SettingsDialog(controller: _controller),
    ).then((_) {
      _controller.startResumeCountdown();
    });
  }

  void _showExitToHomeDialog() {
    _controller.pauseGame();
    GameAudio.playSelect();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 330,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
            decoration: BoxDecoration(
              color: const Color(0xFB0F172A),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF59E0B), width: 2.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black87,
                  blurRadius: 28,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🏠', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 12),
                const Text(
                  'GO TO HOME?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Current level progress will be lost. Return to Home Screen?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFCBD5E1),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          GameAudio.playSelect();
                          Navigator.of(context).pop();
                          _controller.startResumeCountdown();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF334155),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('RESUME', style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _returnToHome();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF59E0B),
                          foregroundColor: const Color(0xFF0F172A),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('GO HOME', style: TextStyle(fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _returnToHome() {
    GameAudio.playHomeBgm();
    _controller.goToHome();
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _showExitToHomeDialog();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Focus(
          autofocus: true,
          onKeyEvent: (node, event) {
            if (event is KeyDownEvent) {
              _pressedKeys.add(event.logicalKey);
            } else if (event is KeyUpEvent) {
              _pressedKeys.remove(event.logicalKey);
            }
            return KeyEventResult.ignored;
          },
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  // 1. Interactive 2D World Canvas
                  GameCanvasViewport(controller: _controller),

                  // 2. In-Game HUD Elements
                  if (_controller.isGameStarted) ...[
                    HudTopBar(
                      controller: _controller,
                      onOpenHeroCustomizer: _openSettings,
                      onHome: _showExitToHomeDialog,
                    ),
                    Positioned(
                      bottom: 24,
                      right: 20,
                      child: HudZoomWidget(
                        controller: _controller,
                        onOpenHeroCustomizer: _openSettings,
                        onHome: _showExitToHomeDialog,
                      ),
                    ),
                  ],

                  // 3. 3-Second Resume Countdown Overlay (Screen Overlay)
                  if (_controller.resumeCountdown > 0)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 22),
                        decoration: BoxDecoration(
                          color: const Color(0xFA0F172A),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFF59E0B), width: 2.2),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x88F59E0B),
                              blurRadius: 32,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${_controller.resumeCountdown}',
                              style: const TextStyle(
                                color: Color(0xFFFBBF24),
                                fontSize: 68,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'GET READY!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // 4. Detained / Arrest Modal
                  if (_controller.isArrested)
                    Container(
                      color: Colors.black.withValues(alpha: 0.75),
                      child: ArrestModal(
                        controller: _controller,
                        onRestart: _controller.restartGame,
                        onHome: _returnToHome,
                      ),
                    ),

                  // 5. Victory Modal
                  if (_controller.isVictory)
                    Container(
                      color: Colors.black.withValues(alpha: 0.70),
                      child: VictoryModal(
                        controller: _controller,
                        onContinue: _controller.continueNextLevel,
                        onHome: _returnToHome,
                      ),
                    ),

                  // 6. Celebration Confetti
                  if (_controller.isConfettiActive)
                    IgnorePointer(
                      child: CustomPaint(
                        painter: ConfettiPainter(particles: _controller.confettiParticles),
                        size: MediaQuery.of(context).size,
                      ),
                    ),

                  // 7. Help & Radar Map Modal
                  if (_controller.isHelpModalOpen)
                    Container(
                      color: Colors.black.withValues(alpha: 0.75),
                      child: HelpRadarModal(
                        controller: _controller,
                        onClose: _controller.closeHelpModal,
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
