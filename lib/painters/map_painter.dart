import '../constants/game_config.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/map_themes.dart';
import '../engine/road_network.dart';
import '../models/road_segment.dart';

/// CustomPainter rendering city blocks, road corridors, curbs, dashed lines,
/// historical Jantar Mantar instruments and the central Gandhi Cap.
class MapPainter extends CustomPainter {
  final RoadNetwork roadNetwork;
  final MapTheme theme;
  final double animTime;
  final double sunAngle;
  final bool allFlagsCollected;

  MapPainter({
    required this.roadNetwork,
    required this.theme,
    required this.animTime,
    required this.sunAngle,
    required this.allFlagsCollected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawCityBlocks(canvas);
    _drawRoadCorridors(canvas);
    _drawRoadMarkings(canvas);
    _drawCentralJantarMantar(canvas);
  }

  void _drawCityBlocks(Canvas canvas) {
    final rings = roadNetwork.rings;
    final center = roadNetwork.center;
    final halfW = roadNetwork.roadWidth / 2;
    final blockColors = theme.blockColors;

    final shadowPaint = Paint()..color = theme.blockShadow;
    final borderPaint = Paint()
      ..color = theme.blockBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    for (int rIdx = 0; rIdx < rings.length - 1; rIdx++) {
      final innerR = rings[rIdx] + halfW + 6.0;
      final outerR = rings[rIdx + 1] - halfW - 6.0;
      if (outerR <= innerR) continue;

      final numSectors = (rIdx < 2) ? 8 : 16;
      final angleStep = (math.pi * 2) / numSectors;
      final angleMargin = math.max(0.038, 52.0 / outerR);

      for (int sIdx = 0; sIdx < numSectors; sIdx++) {
        final startRad = -math.pi / 2 + sIdx * angleStep;
        final endRad = startRad + angleStep;
        final a1 = startRad + angleMargin;
        final a2 = endRad - angleMargin;
        if (a2 <= a1) continue;

        // Shadow path
        final shadowPath = Path()
          ..arcTo(
            Rect.fromCircle(center: center + const Offset(8, 8), radius: outerR),
            a1,
            a2 - a1,
            false,
          )
          ..arcTo(
            Rect.fromCircle(center: center + const Offset(8, 8), radius: innerR),
            a2,
            a1 - a2,
            false,
          )
          ..close();
        canvas.drawPath(shadowPath, shadowPaint);

        // Block path
        final blockColor = blockColors[(rIdx * 3 + sIdx) % blockColors.length];
        final blockPaint = Paint()..color = blockColor;

        final path = Path()
          ..arcTo(
            Rect.fromCircle(center: center, radius: outerR),
            a1,
            a2 - a1,
            false,
          )
          ..arcTo(
            Rect.fromCircle(center: center, radius: innerR),
            a2,
            a1 - a2,
            false,
          )
          ..close();

        canvas.drawPath(path, blockPaint);
        canvas.drawPath(path, borderPaint);
      }
    }
  }

  void _drawRoadCorridors(Canvas canvas) {
    final segments = roadNetwork.segments;

    // Pass 1: Curbs / Sidewalk
    final curbPaint = Paint()
      ..color = theme.curbColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final seg in segments) {
      curbPaint.strokeWidth = seg.width + 16.0;
      _strokeSegment(canvas, seg, curbPaint);
    }

    // Pass 2: Asphalt Surface
    final asphaltPaint = Paint()
      ..color = theme.roadAsphalt
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final seg in segments) {
      asphaltPaint.strokeWidth = seg.width;
      _strokeSegment(canvas, seg, asphaltPaint);
    }
  }

  void _strokeSegment(Canvas canvas, RoadSegment seg, Paint paint) {
    if (seg.type == RoadSegmentType.line) {
      canvas.drawLine(Offset(seg.x1, seg.y1), Offset(seg.x2, seg.y2), paint);
    } else if (seg.type == RoadSegmentType.arc) {
      final rect = Rect.fromCircle(center: Offset(seg.cx, seg.cy), radius: seg.radius);
      canvas.drawArc(rect, seg.startAngle, seg.endAngle - seg.startAngle, false, paint);
    } else if (seg.type == RoadSegmentType.circle) {
      canvas.drawCircle(Offset(seg.cx, seg.cy), seg.radius, paint);
    }
  }

  void _drawRoadMarkings(Canvas canvas) {
    final segments = roadNetwork.segments;
    final markingPaint = Paint()
      ..color = theme.roadMarking
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    for (final seg in segments) {
      if (seg.type == RoadSegmentType.line) {
        final d1 = hypot(seg.x1 - roadNetwork.center.dx, seg.y1 - roadNetwork.center.dy);
        final d2 = hypot(seg.x2 - roadNetwork.center.dx, seg.y2 - roadNetwork.center.dy);
        if (math.min(d1, d2) >= 200.0) {
          _drawDashedLine(canvas, Offset(seg.x1, seg.y1), Offset(seg.x2, seg.y2), markingPaint);
        }
      } else if (seg.type == RoadSegmentType.arc) {
        if (seg.radius > 260.0) {
          _drawDashedArc(
            canvas,
            Offset(seg.cx, seg.cy),
            seg.radius,
            seg.startAngle,
            seg.endAngle,
            markingPaint,
          );
        }
      }
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dashLength = 18.0;
    const dashSpace = 14.0;
    final dx = p2.dx - p1.dx;
    final dy = p2.dy - p1.dy;
    final dist = hypot(dx, dy);
    final count = (dist / (dashLength + dashSpace)).floor();
    final uX = dx / dist;
    final uY = dy / dist;

    double cur = 0;
    for (int i = 0; i < count; i++) {
      final start = Offset(p1.dx + uX * cur, p1.dy + uY * cur);
      final end = Offset(p1.dx + uX * (cur + dashLength), p1.dy + uY * (cur + dashLength));
      canvas.drawLine(start, end, paint);
      cur += dashLength + dashSpace;
    }
  }

  void _drawDashedArc(
    Canvas canvas,
    Offset center,
    double radius,
    double startAngle,
    double endAngle,
    Paint paint,
  ) {
    final circumference = (endAngle - startAngle).abs() * radius;
    const dashLength = 18.0;
    const dashSpace = 14.0;
    final numDashes = (circumference / (dashLength + dashSpace)).floor();
    final angleStep = (dashLength + dashSpace) / radius;
    final dashAngle = dashLength / radius;

    for (int i = 0; i < numDashes; i++) {
      final a = startAngle + i * angleStep;
      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawArc(rect, a, dashAngle, false, paint);
    }
  }

  void _drawCentralJantarMantar(Canvas canvas) {
    final c = roadNetwork.center;
    const r = 240.0;

    // 1. Sanctuary lawn
    final grassPaint = Paint()..color = theme.centerGrass;
    final borderPaint = Paint()
      ..color = theme.centerBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0;

    canvas.drawCircle(c, r, grassPaint);
    canvas.drawCircle(c, r, borderPaint);

    // Glowing border aura
    final pulse = (math.sin(animTime * 3) + 1) * 0.5;
    final glowPaint = Paint()
      ..color = Color.fromRGBO(245, 158, 11, 0.4 + pulse * 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0;
    canvas.drawCircle(c, r - 8.0, glowPaint);

    // 2. 8 Grand Sandstone Radial Walkways into Center
    final radials = [
      -math.pi / 2, -math.pi / 4, 0.0, math.pi / 4,
      math.pi / 2, (3 * math.pi) / 4, math.pi, -(3 * math.pi) / 4
    ];

    final walkCurb = Paint()
      ..color = const Color(0xFFC4B59D)
      ..strokeWidth = 56.0
      ..strokeCap = StrokeCap.round;

    final walkSurface = Paint()
      ..color = const Color(0xFFDED5C5)
      ..strokeWidth = 44.0
      ..strokeCap = StrokeCap.round;

    for (final a in radials) {
      final end = c + Offset(math.cos(a) * r, math.sin(a) * r);
      canvas.drawLine(c, end, walkCurb);
      canvas.drawLine(c, end, walkSurface);
    }

    // 3. Central Plaza Courtyard
    canvas.drawCircle(c, 66.0, Paint()..color = const Color(0xFFC4B59D));
    canvas.drawCircle(c, 60.0, Paint()..color = const Color(0xFFEAE2D3));
    canvas.drawCircle(
      c,
      60.0,
      Paint()
        ..color = const Color(0xFFBFA588)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0,
    );
    canvas.drawCircle(
      c,
      42.0,
      Paint()
        ..color = const Color.fromRGBO(180, 150, 120, 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    // 4. Astronomical Instruments
    _drawSamratYantra(canvas, c.dx - 110, c.dy - 110);
    _drawMisraYantra(canvas, c.dx + 110, c.dy - 110);
    _drawJaiPrakashYantra(canvas, c.dx - 115, c.dy + 110, c.dx - 70, c.dy + 125);
    _drawRamYantra(canvas, c.dx + 110, c.dy + 110, 26.0);
    _drawCentralStage(canvas, c.dx - 45, c.dy - 170, 90.0, 36.0);

    // 5. Central Gandhi Protest Cap
    _drawGandhiCap(canvas, c.dx, c.dy, allFlagsCollected);
  }

  void _drawSamratYantra(Canvas canvas, double x, double y) {
    const gnomonW = 24.0;
    const gnomonL = 90.0;
    const quadR = 55.0;

    final marblePaint = Paint()
      ..color = const Color(0xFFF8FAFC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18.0;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(x - gnomonW / 2, y), radius: quadR),
      math.pi * 0.5,
      math.pi * 0.5,
      false,
      marblePaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(x + gnomonW / 2, y), radius: quadR),
      0.0,
      math.pi * 0.5,
      false,
      marblePaint,
    );

    // Sandstone ramp
    final rampRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(x, y), width: gnomonW, height: gnomonL),
      const Radius.circular(4),
    );
    canvas.drawRRect(rampRect, Paint()..color = const Color(0xFFEA580C));
    canvas.drawRRect(
      rampRect,
      Paint()
        ..color = const Color(0xFFC2410C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
  }

  void _drawMisraYantra(Canvas canvas, double x, double y) {
    final rect = Rect.fromCenter(center: Offset(x, y), width: 60, height: 40);
    canvas.drawRect(rect, Paint()..color = const Color(0xFFEA580C));
  }

  void _drawJaiPrakashYantra(Canvas canvas, double x1, double y1, double x2, double y2) {
    final p = Paint()..color = const Color(0xFFF8FAFC);
    canvas.drawCircle(Offset(x1, y1), 22.0, p);
    canvas.drawCircle(Offset(x2, y2), 22.0, p);
  }

  void _drawRamYantra(Canvas canvas, double x, double y, double radius) {
    canvas.drawCircle(Offset(x, y), radius, Paint()..color = const Color(0xFFF8FAFC));
  }

  void _drawCentralStage(Canvas canvas, double x, double y, double w, double h) {
    canvas.drawRect(Rect.fromLTWH(x, y, w, h), Paint()..color = const Color(0xFFF97316));
  }

  void _drawGandhiCap(Canvas canvas, double x, double y, bool isUnlocked) {
    canvas.save();
    final t = animTime;

    if (isUnlocked) {
      // Radiant starburst rays
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(t * 0.7);
      final rayPaint = Paint()
        ..color = const Color.fromRGBO(245, 158, 11, 0.28)
        ..strokeWidth = 3.5;
      for (int i = 0; i < 12; i++) {
        final ang = (i * math.pi * 2) / 12;
        canvas.drawLine(
          Offset.zero,
          Offset(math.cos(ang) * 95, math.sin(ang) * 95),
          rayPaint,
        );
      }
      canvas.restore();

      // Pulsing golden beacon ring
      final pulseR = 36.0 + math.sin(t * 5) * 8.0;
      canvas.drawCircle(
        Offset(x, y),
        pulseR,
        Paint()
          ..color = const Color(0xFFF59E0B)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5,
      );
      canvas.drawCircle(
        Offset(x, y),
        pulseR,
        Paint()..color = const Color.fromRGBO(245, 158, 11, 0.25),
      );

      // Floating Trophy Cup
      final hoverY = y + math.sin(t * 4) * 6.0;
      canvas.save();
      canvas.translate(x, hoverY);

      // Shadow
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(0, 20.0 - math.sin(t * 4) * 3.0),
          width: 38,
          height: 12,
        ),
        Paint()..color = const Color.fromRGBO(0, 0, 0, 0.35),
      );

      // Golden Trophy Cup
      final trophyPainter = TextPainter(
        text: const TextSpan(
          text: '🏆',
          style: TextStyle(fontSize: 38),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      trophyPainter.paint(canvas, Offset(-trophyPainter.width / 2, -trophyPainter.height / 2));

      // Overhead animated arrow
      final arrowY = -42.0 + math.sin(t * 6) * 4.0;
      final textPainter = TextPainter(
        text: const TextSpan(
          text: '⬇',
          style: TextStyle(
            color: Color(0xFFFACC15),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(-textPainter.width / 2, arrowY));

      // Label Capsule
      final badgeRect = RRect.fromRectAndRadius(
        const Rect.fromLTWH(-85, -68, 170, 22),
        const Radius.circular(6),
      );
      canvas.drawRRect(badgeRect, Paint()..color = const Color(0xFF0F172A));
      canvas.drawRRect(
        badgeRect,
        Paint()
          ..color = const Color(0xFFF59E0B)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8,
      );

      final labelPainter = TextPainter(
        text: const TextSpan(
          text: '★ CLAIM TROPHY TO WIN! ★',
          style: TextStyle(
            color: Color(0xFFFEF08A),
            fontSize: 10.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      labelPainter.paint(canvas, Offset(-labelPainter.width / 2, -64));

      canvas.restore();
    } else {
      // Locked state
      canvas.save();
      canvas.translate(x, y);

      // Altar
      canvas.drawCircle(
        Offset.zero,
        30.0,
        Paint()..color = const Color.fromRGBO(15, 23, 42, 0.7),
      );
      canvas.drawCircle(
        Offset.zero,
        30.0,
        Paint()
          ..color = const Color.fromRGBO(255, 255, 255, 0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );

      // Translucent Trophy
      final trophyPainter = TextPainter(
        text: const TextSpan(
          text: '🏆',
          style: TextStyle(fontSize: 28),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      trophyPainter.paint(canvas, Offset(-trophyPainter.width / 2, -trophyPainter.height / 2));

      // Lock tag
      final tagRect = RRect.fromRectAndRadius(
        const Rect.fromLTWH(-66, -34, 132, 18),
        const Radius.circular(5),
      );
      canvas.drawRRect(tagRect, Paint()..color = const Color.fromRGBO(15, 23, 42, 0.88));
      canvas.drawRRect(
        tagRect,
        Paint()
          ..color = const Color(0xFFF87171)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );

      final lockPainter = TextPainter(
        text: const TextSpan(
          text: '🔒 COLLECT ALL FLAGS FIRST',
          style: TextStyle(
            color: Color(0xFFFCA5A5),
            fontSize: 9.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      lockPainter.paint(canvas, Offset(-lockPainter.width / 2, -31));

      canvas.restore();
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant MapPainter oldDelegate) {
    return oldDelegate.animTime != animTime ||
        oldDelegate.allFlagsCollected != allFlagsCollected ||
        oldDelegate.theme.id != theme.id;
  }
}
