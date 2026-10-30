import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import '../engine/game_controller.dart';
import '../engine/game_audio.dart';
import '../widgets/game_canvas_viewport.dart';
import '../widgets/start_card_dialog.dart';
import 'game_screen.dart';

/// 1. Dedicated Home / Main Menu Screen
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late GameController _controller;
  late Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  // Track if a modal dialog (like Settings or Exit) is active
  bool _isModalDialogOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = GameController();

    // Start Home BGM loop
    GameAudio.playHomeBgm();

    _ticker = createTicker((elapsed) {
      if (_lastElapsed == Duration.zero) {
        _lastElapsed = elapsed;
        return;
      }
      final delta = (elapsed - _lastElapsed).inMicroseconds / 1000000.0;
      _lastElapsed = elapsed;
      final dt = delta.clamp(0.001, 0.08);

      // Continuously update cinematic camera orbit on Home Screen
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

  void _onStartGame() {
    _controller.startGame();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GameScreen(controller: _controller),
      ),
    ).then((_) {
      // When returning to HomeScreen, resume Home BGM & reset cinematic view
      GameAudio.playHomeBgm();
      _controller.goToHome();
      if (mounted) {
        setState(() {
          _isModalDialogOpen = false;
        });
      }
    });
  }

  void _showExitAppDialog() {
    GameAudio.playSelect();
    setState(() {
      _isModalDialogOpen = true;
    });

    showDialog(
      context: context,
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
                const Text('🚪', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 12),
                const Text(
                  'EXIT APP?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Are you sure you want to quit Jantar Mantar 2.0?',
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
                      child: OutlinedButton(
                        onPressed: () {
                          GameAudio.playSelect();
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFF334155), width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('CANCEL', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          SystemNavigator.pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('EXIT', style: TextStyle(fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      if (mounted) {
        setState(() {
          _isModalDialogOpen = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _showExitAppDialog();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              fit: StackFit.expand,
              children: [
                // 1. Live Animated Background Map
                GameCanvasViewport(controller: _controller),

                // 2. Start Game Dialog Card (Hidden when a modal dialog like Exit App / Settings is active!)
                if (!_isModalDialogOpen)
                  Container(
                    color: Colors.black.withValues(alpha: 0.35),
                    child: StartCardDialog(
                      controller: _controller,
                      onStart: _onStartGame,
                      onModalToggle: (isOpen) {
                        setState(() {
                          _isModalDialogOpen = isOpen;
                        });
                      },
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
