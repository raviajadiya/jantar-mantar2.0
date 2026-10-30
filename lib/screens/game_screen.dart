import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../engine/game_controller.dart';
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
    showDialog(
      context: context,
      builder: (context) => SettingsDialog(controller: _controller),
    );
  }

  void _returnToHome() {
    _controller.goToHome();
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    onHome: _returnToHome,
                  ),
                  Positioned(
                    bottom: 24,
                    right: 20,
                    child: HudZoomWidget(
                      controller: _controller,
                      onOpenHeroCustomizer: _openSettings,
                      onHome: _returnToHome,
                    ),
                  ),
                ],

                // 3. Detained / Arrest Modal
                if (_controller.isArrested)
                  Container(
                    color: Colors.black.withValues(alpha: 0.75),
                    child: ArrestModal(
                      controller: _controller,
                      onRestart: _controller.restartGame,
                      onHome: _returnToHome,
                    ),
                  ),

                // 4. Victory Modal
                if (_controller.isVictory)
                  Container(
                    color: Colors.black.withValues(alpha: 0.70),
                    child: VictoryModal(
                      controller: _controller,
                      onContinue: _controller.continueNextLevel,
                      onHome: _returnToHome,
                    ),
                  ),

                // 5. Help & Radar Map Modal
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
    );
  }
}
