import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../engine/game_controller.dart';
import '../engine/game_audio.dart';
import '../widgets/game_canvas_viewport.dart';
import 'home_screen.dart';

/// Animated Live-Preview Splash Screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late GameController _controller;
  late Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  double _loadingProgress = 0.0;
  Timer? _progressTimer;

  @override
  void initState() {
    super.initState();
    _controller = GameController();

    // Start Home BGM
    GameAudio.playHomeBgm();

    // Ticker loop for continuous cinematic background map orbit
    _ticker = createTicker((elapsed) {
      if (_lastElapsed == Duration.zero) {
        _lastElapsed = elapsed;
        return;
      }
      final delta = (elapsed - _lastElapsed).inMicroseconds / 1000000.0;
      _lastElapsed = elapsed;
      final dt = delta.clamp(0.001, 0.08);

      _controller.update(dt);
    });

    _ticker.start();

    // Smooth loading progress over ~2.8 seconds
    _progressTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (!mounted) return;
      setState(() {
        _loadingProgress += 0.012;
        if (_loadingProgress >= 1.0) {
          _loadingProgress = 1.0;
          _progressTimer?.cancel();
          _navigateToHome();
        }
      });
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    _controller.dispose();
    _progressTimer?.cancel();
    super.dispose();
  }

  void _navigateToHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 800),
        pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
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
              // 1. Live Animated Background Map Viewport
              GameCanvasViewport(controller: _controller),

              // 2. Dark Vignette Backdrop
              Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.1,
                    colors: [
                      Color(0x770F172A),
                      Color(0xFA0F172A),
                    ],
                  ),
                ),
              ),

              // 3. Main Center Branding
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Badge Container
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF0F172A),
                        border: Border.all(color: const Color(0xFFF59E0B), width: 2.5),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x66F59E0B),
                            blurRadius: 24,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('✊', style: TextStyle(fontSize: 32)),
                          SizedBox(width: 8),
                          Text('⚡', style: TextStyle(fontSize: 24)),
                          SizedBox(width: 8),
                          Text('👮', style: TextStyle(fontSize: 32)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Title
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFFFBBF24), Colors.white, Color(0xFFFBBF24)],
                      ).createShader(bounds),
                      child: const Text(
                        'JANTAR MANTAR 2.0',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              offset: Offset(0, 3),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'DHARNA MOVEMENT ARCADE • DELHI CIRCUIT',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),

                    const SizedBox(height: 42),

                    // Loading Progress Bar
                    Container(
                      width: 220,
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF334155), width: 1),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: _loadingProgress,
                          backgroundColor: Colors.transparent,
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Loading Delhi Map... ${((_loadingProgress * 100).clamp(0, 100)).toInt()}%',
                      style: const TextStyle(
                        color: Color(0xFFCBD5E1),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
