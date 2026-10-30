import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/map_themes.dart';
import '../engine/road_network.dart';
import '../engine/game_camera.dart';
import '../models/flag_item.dart';
import '../models/police_officer.dart';
import '../models/road_segment.dart';

/// CustomPainter rendering the interactive DILLI MAP radar
class MinimapPainter extends CustomPainter {
  final RoadNetwork roadNetwork;
  final GameCamera camera;
  final MapTheme theme;
  final Offset playerPos;
  final List<PoliceOfficer> officers;
  final List<FlagItem> flags;
  final double animTime;

  MinimapPainter({
    required this.roadNetwork,
    required this.camera,
    required this.theme,
    required this.playerPos,
    required this.officers,
    required this.flags,
    required this.animTime,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Background
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = theme.bgCanvas,
    );

    final scaleX = size.width / camera.worldWidth;
    final scaleY = size.height / camera.worldHeight;
    final cx = roadNetwork.center.dx * scaleX;
    final cy = roadNetwork.center.dy * scaleY;

    // 2. Road Network Segments
    final segPaint = Paint()
      ..color = theme.curbColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8;

    for (final seg in roadNetwork.segments) {
      if (seg.type == RoadSegmentType.line) {
        canvas.drawLine(
          Offset(seg.x1 * scaleX, seg.y1 * scaleY),
          Offset(seg.x2 * scaleX, seg.y2 * scaleY),
          segPaint,
        );
      } else if (seg.type == RoadSegmentType.arc) {
        final rRect = Rect.fromCircle(
          center: Offset(seg.cx * scaleX, seg.cy * scaleY),
          radius: seg.radius * scaleX,
        );
        canvas.drawArc(rRect, seg.startAngle, seg.endAngle - seg.startAngle, false, segPaint);
      }
    }

    // 3. Central Sanctuary Circle & Star
    final allSecured = flags.isNotEmpty && flags.every((f) => f.isCollected);
    final sanctuaryR = (roadNetwork.rings.isNotEmpty ? roadNetwork.rings.first : 240.0) * scaleX;
    canvas.drawCircle(Offset(cx, cy), sanctuaryR, Paint()..color = theme.centerGrass);

    if (allSecured) {
      final pR = 10.0 + math.sin(animTime * 6) * 4.0;
      canvas.drawCircle(
        Offset(cx, cy),
        pR,
        Paint()
          ..color = const Color(0xFFF59E0B)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
      _drawStar(canvas, cx, cy, 5, 10.0, 5.0, const Color(0xFFFACC15));
    } else {
      _drawStar(canvas, cx, cy, 5, 8.0, 4.0, theme.accent);
    }

    // 4. Flags
    for (final f in flags) {
      if (!f.isCollected) {
        final fx = f.x * scaleX;
        final fy = f.y * scaleY;
        canvas.drawCircle(Offset(fx, fy), 3.5, Paint()..color = f.color);
        canvas.drawCircle(
          Offset(fx, fy),
          3.5,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0,
        );
      }
    }

    // 5. Police Officers
    for (final p in officers) {
      final px = p.x * scaleX;
      final py = p.y * scaleY;
      final isChasing = p.state == 'chase';
      final pRad = isChasing ? 5.0 : 3.5;

      canvas.drawCircle(
        Offset(px, py),
        pRad,
        Paint()..color = isChasing ? const Color(0xFFEF4444) : const Color(0xFFF97316),
      );

      if (isChasing) {
        canvas.drawCircle(
          Offset(px, py),
          pRad,
          Paint()
            ..color = const Color(0xFFDC2626)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
      }
    }

    // 6. Player
    final plx = playerPos.dx * scaleX;
    final ply = playerPos.dy * scaleY;
    canvas.drawCircle(Offset(plx, ply), 6.0, Paint()..color = const Color(0xFF16A34A));
    canvas.drawCircle(
      Offset(plx, ply),
      6.0,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    // 7. Camera Viewport Box
    final bounds = camera.getVisibleBounds();
    final bx = bounds.left * scaleX;
    final by = bounds.top * scaleY;
    final bw = bounds.width * scaleX;
    final bh = bounds.height * scaleY;

    canvas.drawRect(
      Rect.fromLTWH(bx, by, bw, bh),
      Paint()
        ..color = const Color.fromRGBO(248, 250, 252, 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  void _drawStar(Canvas canvas, double cx, double cy, int spikes, double outerR, double innerR, Color color) {
    double rot = (math.pi / 2) * 3;
    final step = math.pi / spikes;
    final path = Path();

    path.moveTo(cx, cy - outerR);
    for (int i = 0; i < spikes; i++) {
      path.lineTo(cx + math.cos(rot) * outerR, cy + math.sin(rot) * outerR);
      rot += step;
      path.lineTo(cx + math.cos(rot) * innerR, cy + math.sin(rot) * innerR);
      rot += step;
    }
    path.close();

    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFB45309)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  @override
  bool shouldRepaint(covariant MinimapPainter oldDelegate) => true;
}
