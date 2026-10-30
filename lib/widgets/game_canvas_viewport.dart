import 'package:flutter/material.dart';
import '../engine/game_controller.dart';
import '../painters/map_painter.dart';
import '../painters/flags_painter.dart';
import '../painters/police_painter.dart';
import '../painters/player_painter.dart';
import '../painters/confetti_painter.dart';

/// Interactive Game Viewport rendering the 2D world with camera transformations & touch gesture handling
class GameCanvasViewport extends StatefulWidget {
  final GameController controller;

  const GameCanvasViewport({super.key, required this.controller});

  @override
  State<GameCanvasViewport> createState() => _GameCanvasViewportState();
}

class _GameCanvasViewportState extends State<GameCanvasViewport> {
  Offset _dragStart = Offset.zero;
  Offset _camStart = Offset.zero;
  double _startZoom = 1.0;
  DateTime _lastTapTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;

    return LayoutBuilder(
      builder: (context, constraints) {
        c.camera.resize(constraints.maxWidth, constraints.maxHeight);

        return GestureDetector(
          onScaleStart: (details) {
            _dragStart = details.focalPoint;
            _camStart = Offset(c.camera.targetX, c.camera.targetY);
            _startZoom = c.camera.zoom;
          },
          onScaleUpdate: (details) {
            if (details.pointerCount > 1) {
              // 2-finger Pinch Zoom
              final newZoom = _startZoom * details.scale;
              c.camera.setZoom(newZoom);
            } else {
              // 1-finger Drag to Pan Map
              final delta = details.focalPoint - _dragStart;
              if (delta.distance > 8.0) {
                c.camera.isDragging = true;
                c.camera.targetX = _camStart.dx - delta.dx / c.camera.zoom;
                c.camera.targetY = _camStart.dy - delta.dy / c.camera.zoom;
                c.camera.x = c.camera.targetX;
                c.camera.y = c.camera.targetY;
              }
            }
          },
          onScaleEnd: (details) {
            c.camera.isDragging = false;
          },
          onTapUp: (details) {
            if (!c.isGameStarted) {
              return;
            }

            final now = DateTime.now();
            final isDoubleTap = now.difference(_lastTapTime).inMilliseconds < 350;
            _lastTapTime = now;

            final worldPos = c.camera.screenToWorld(
              details.localPosition.dx,
              details.localPosition.dy,
            );

            c.setDestination(worldPos.dx, worldPos.dy);
            if (isDoubleTap) {
              c.isSprinting = true;
            }
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Main Game World CustomPaint
              CustomPaint(
                painter: _WorldCompositePainter(controller: c),
                size: Size(constraints.maxWidth, constraints.maxHeight),
              ),

              // Fullscreen Celebration Confetti
              if (c.isConfettiActive)
                CustomPaint(
                  painter: ConfettiPainter(particles: c.confettiParticles),
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Composite painter that applies camera transformations and paints all world entities
class _WorldCompositePainter extends CustomPainter {
  final GameController controller;

  _WorldCompositePainter({required this.controller});

  @override
  void paint(Canvas canvas, Size size) {
    final camera = controller.camera;

    // Background fill
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = controller.currentTheme.bgCanvas,
    );

    // Apply 2D Camera transformation
    canvas.save();
    canvas.translate(camera.viewportWidth / 2, camera.viewportHeight / 2);
    canvas.scale(camera.zoom, camera.zoom);
    canvas.translate(-camera.x, -camera.y);

    // 1. Draw Map (Roads, Blocks, Jantar Mantar instruments & Gandhi Cap)
    final mapPainter = MapPainter(
      roadNetwork: controller.roadNetwork,
      theme: controller.currentTheme,
      animTime: controller.animTime,
      sunAngle: controller.sunAngle,
      allFlagsCollected: controller.areAllFlagsCollected,
    );
    mapPainter.paint(canvas, size);

    // 2. Draw Flags & collect sparkle particles
    final flagsPainter = FlagsPainter(
      flags: controller.flags,
      particles: controller.collectParticles,
      animTime: controller.animTime,
    );
    flagsPainter.paint(canvas, size);

    // 3. Draw Police Officers & Detection Areas
    final policePainter = PolicePainter(
      officers: controller.officers,
      animTime: controller.animTime,
    );
    policePainter.paint(canvas, size);

    // 4. Draw Player Figurine, Waypoint Path & Banner
    final playerPainter = PlayerPainter(
      position: controller.playerPos,
      angle: controller.playerAngle,
      isMoving: controller.isMoving,
      isSprinting: controller.isSprinting,
      path: controller.playerPath,
      waypointIndex: controller.currentWaypointIndex,
      playerName: controller.playerName,
      country: controller.selectedCountry,
      animTime: controller.animTime,
    );
    playerPainter.paint(canvas, size);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WorldCompositePainter oldDelegate) => true;
}
