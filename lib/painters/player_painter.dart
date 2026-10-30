import '../constants/game_config.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/country_data.dart';

/// CustomPainter rendering the Protester Player character (Kurta, Nehru jacket,
/// spectacles, Gandhi cap, bamboo flagpole, and waving country flag banner).
class PlayerPainter extends CustomPainter {
  final Offset position;
  final double angle;
  final bool isMoving;
  final bool isSprinting;
  final List<Offset> path;
  final int waypointIndex;
  final String playerName;
  final CountryFaction country;
  final double animTime;

  PlayerPainter({
    required this.position,
    required this.angle,
    required this.isMoving,
    required this.isSprinting,
    required this.path,
    required this.waypointIndex,
    required this.playerName,
    required this.country,
    required this.animTime,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const charScale = 3.8;

    // 1. Waypoint Path line
    if (path.isNotEmpty && waypointIndex < path.length) {
      final pathPaint = Paint()
        ..color = const Color.fromRGBO(249, 115, 22, 0.7)
        ..strokeWidth = 4.0
        ..style = PaintingStyle.stroke;

      _drawDashedPath(canvas, position, path.sublist(waypointIndex), pathPaint);

      // Destination Bullseye
      final finalTarget = path.last;
      canvas.drawCircle(finalTarget, 9.0, Paint()..color = const Color(0xFFF97316));
      canvas.drawCircle(
        finalTarget,
        9.0,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
    }

    // 2. Orange Walking Ring Indicator
    canvas.drawCircle(
      position,
      12.0 * charScale,
      Paint()
        ..color = const Color(0xFFF97316)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5,
    );

    // Subtle pulsing outer aura
    final auraPulse = math.sin(animTime * 4) * 0.12 + 0.88;
    canvas.drawCircle(
      position,
      12.0 * charScale + 5.0 * auraPulse,
      Paint()
        ..color = const Color.fromRGBO(249, 115, 22, 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0,
    );

    // 3. Protester Figurine Body
    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.scale(charScale, charScale);

    final sway = isMoving ? math.sin(animTime * (isSprinting ? 20 : 12)) * 3.5 : 0.0;

    // Shadow
    canvas.drawOval(
      const Rect.fromLTWH(-8, 5, 20, 10),
      Paint()..color = const Color.fromRGBO(0, 0, 0, 0.28),
    );

    // Feet
    final feetPaint = Paint()..color = const Color(0xFF78350F);
    canvas.drawRect(Rect.fromLTWH(-6 + sway, 8, 4, 6), feetPaint);
    canvas.drawRect(Rect.fromLTWH(2 - sway, 8, 4, 6), feetPaint);

    // White Kurta
    final kurtaRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-8, -6, 16, 16),
      const Radius.circular(4),
    );
    canvas.drawRRect(kurtaRect, Paint()..color = Colors.white);
    canvas.drawRRect(
      kurtaRect,
      Paint()
        ..color = const Color(0xFF94A3B8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // Nehru Jacket
    final jacketPaint = Paint()..color = const Color(0xFF78716C);
    canvas.drawRect(const Rect.fromLTWH(-7, -4, 5, 12), jacketPaint);
    canvas.drawRect(const Rect.fromLTWH(2, -4, 5, 12), jacketPaint);

    // Head
    canvas.drawCircle(const Offset(0, -14), 7.5, Paint()..color = const Color(0xFFFBCFE8));

    // Round Spectacles
    final specsPaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(const Offset(-2.5, -14), 2.5, specsPaint);
    canvas.drawCircle(const Offset(2.5, -14), 2.5, specsPaint);

    // White Gandhi Cap
    canvas.drawOval(
      const Rect.fromLTWH(-7.5, -22.5, 15, 7),
      Paint()..color = const Color(0xFFF8FAFC),
    );

    // Flagpole
    final polePaint = Paint()
      ..color = const Color(0xFF92400E)
      ..strokeWidth = 2.2;
    canvas.drawLine(const Offset(9, -8), const Offset(9, 14), polePaint);

    // Dynamic Country Flag Banner
    final flagWave = math.sin(animTime * (isMoving ? 14 : 7)) * 2.5;
    const flagW = 20.0;
    const flagH = 14.0;
    final stripes = country.stripeColors;
    final stripeH = flagH / stripes.length;

    for (int s = 0; s < stripes.length; s++) {
      final topY = -22.0 + s * stripeH;
      final botY = topY + stripeH;
      final fPath = Path()
        ..moveTo(9, topY)
        ..lineTo(9 + flagW + flagWave, topY + flagWave * 0.4)
        ..lineTo(9 + flagW + flagWave, botY + flagWave * 0.4)
        ..lineTo(9, botY)
        ..close();
      canvas.drawPath(fPath, Paint()..color = stripes[s]);
    }

    // Flag outline
    final fBorder = Path()
      ..moveTo(9, -22)
      ..lineTo(9 + flagW + flagWave, -22 + flagWave * 0.4)
      ..lineTo(9 + flagW + flagWave, -22 + flagH + flagWave * 0.4)
      ..lineTo(9, -22 + flagH);
    canvas.drawPath(
      fBorder,
      Paint()
        ..color = const Color.fromRGBO(0, 0, 0, 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    canvas.restore();

    // 4. Speech/Identity badge capsule
    _drawLabel(canvas, position.dx, position.dy - 65, '${country.emoji} $playerName');
  }

  void _drawDashedPath(Canvas canvas, Offset start, List<Offset> points, Paint paint) {
    if (points.isEmpty) return;
    var all = [start, ...points];
    const dashLength = 10.0;
    const dashSpace = 7.0;

    for (int p = 0; p < all.length - 1; p++) {
      final p1 = all[p];
      final p2 = all[p + 1];
      final dx = p2.dx - p1.dx;
      final dy = p2.dy - p1.dy;
      final dist = hypot(dx, dy);
      if (dist == 0) continue;
      final count = (dist / (dashLength + dashSpace)).floor();
      final uX = dx / dist;
      final uY = dy / dist;

      double cur = 0;
      for (int i = 0; i < count; i++) {
        final s = Offset(p1.dx + uX * cur, p1.dy + uY * cur);
        final e = Offset(p1.dx + uX * (cur + dashLength), p1.dy + uY * (cur + dashLength));
        canvas.drawLine(s, e, paint);
        cur += dashLength + dashSpace;
      }
    }
  }

  void _drawLabel(Canvas canvas, double x, double y, String text) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final bw = textPainter.width + 22.0;
    const bh = 24.0;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(x, y), width: bw, height: bh),
      const Radius.circular(7),
    );

    // Glassmorphic capsule
    canvas.drawRRect(rrect, Paint()..color = const Color.fromRGBO(15, 23, 42, 0.94));
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = country.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    // Text
    textPainter.paint(
      canvas,
      Offset(x - textPainter.width / 2, y - textPainter.height / 2),
    );

    // Pointer notch
    final notch = Path()
      ..moveTo(x, y + bh / 2 + 5)
      ..lineTo(x - 5, y + bh / 2)
      ..lineTo(x + 5, y + bh / 2)
      ..close();
    canvas.drawPath(notch, Paint()..color = country.color);
  }

  @override
  bool shouldRepaint(covariant PlayerPainter oldDelegate) => true;
}
