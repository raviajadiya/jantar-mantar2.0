import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../engine/game_controller.dart';
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
      // When returning to HomeScreen, reset to home cinematic view
      _controller.goToHome();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // 1. Live Animated Background Map
              GameCanvasViewport(controller: _controller),

              // 2. Start Game Dialog Card
              Container(
                color: Colors.black.withValues(alpha: 0.35),
                child: StartCardDialog(
                  controller: _controller,
                  onStart: _onStartGame,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
