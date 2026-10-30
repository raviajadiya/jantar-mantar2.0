import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../engine/game_controller.dart';
import '../widgets/game_canvas_viewport.dart';
import '../widgets/hud_top_left.dart';
import '../widgets/hud_top_bar.dart';
import '../widgets/hud_zoom_widget.dart';
import '../widgets/virtual_joystick.dart';
import '../widgets/start_card_dialog.dart';
import '../widgets/victory_modal.dart';
import '../widgets/arrest_modal.dart';
import '../widgets/help_radar_modal.dart';

/// Main Game Screen hosting the 60FPS render loop, HUD layers and modals
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late GameController _controller;
  late Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  // Keyboard input state
  final Set<LogicalKeyboardKey> _pressedKeys = {};

  // Joystick input state
  Offset _joystickDirection = Offset.zero;
  bool _joystickSprint = false;

  // Hero customizer modal toggle
  bool _isHeroCustomizerOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = GameController();

    _ticker = createTicker((elapsed) {
      if (_lastElapsed == Duration.zero) {
        _lastElapsed = elapsed;
        return;
      }
      final delta = (elapsed - _lastElapsed).inMicroseconds / 1000000.0;
      _lastElapsed = elapsed;

      final dt = delta.clamp(0.001, 0.08);

      // Manual Keyboard / Joystick Movement
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

      // Add joystick
      if (_joystickDirection != Offset.zero) {
        kx += _joystickDirection.dx;
        ky += _joystickDirection.dy;
      }

      final isShiftPressed = _pressedKeys.contains(LogicalKeyboardKey.shiftLeft) ||
          _pressedKeys.contains(LogicalKeyboardKey.shiftRight) ||
          _joystickSprint;

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
    _controller.dispose();
    super.dispose();
  }

  void _openHeroCustomizer() {
    setState(() {
      _isHeroCustomizerOpen = true;
    });
  }

  void _closeHeroCustomizer() {
    setState(() {
      _isHeroCustomizerOpen = false;
    });
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
            if (!_controller.isGameStarted && event.logicalKey == LogicalKeyboardKey.enter) {
              _controller.startGame();
            }
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
                // 1. Main 2D Viewport Canvas
                GameCanvasViewport(controller: _controller),

                // 2. In-Game HUD Elements
                if (_controller.isGameStarted && !_isHeroCustomizerOpen) ...[
                  HudTopLeft(controller: _controller),
                  HudTopBar(
                    controller: _controller,
                    onOpenHeroCustomizer: _openHeroCustomizer,
                  ),
                  HudZoomWidget(
                    controller: _controller,
                    onOpenHeroCustomizer: _openHeroCustomizer,
                  ),
                  VirtualJoystick(
                    onDirectionChanged: (dir) {
                      _joystickDirection = dir;
                    },
                    onSprintChanged: (sprint) {
                      _joystickSprint = sprint;
                    },
                  ),
                ],

                // 3. Start Game Dialog (or Hero Customizer)
                if (!_controller.isGameStarted || _isHeroCustomizerOpen)
                  Container(
                    color: Colors.black.withValues(alpha: 0.35),
                    child: StartCardDialog(
                      controller: _controller,
                      onStart: () {
                        _closeHeroCustomizer();
                        if (!_controller.isGameStarted) {
                          _controller.startGame();
                        }
                      },
                    ),
                  ),

                // 4. Detained / Arrest Modal
                if (_controller.isArrested)
                  Container(
                    color: Colors.black.withValues(alpha: 0.75),
                    child: ArrestModal(
                      controller: _controller,
                      onRestart: _controller.restartGame,
                      onHome: _controller.goToHome,
                    ),
                  ),

                // 5. Victory Modal
                if (_controller.isVictory)
                  Container(
                    color: Colors.black.withValues(alpha: 0.70),
                    child: VictoryModal(
                      controller: _controller,
                      onContinue: _controller.continueNextLevel,
                      onHome: _controller.goToHome,
                    ),
                  ),

                // 6. Help & Radar Map Modal
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
