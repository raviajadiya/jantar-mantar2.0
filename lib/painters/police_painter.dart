import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/police_officer.dart';

/// CustomPainter rendering Delhi Police officers with luminous searchlights,
/// siren alert fields, khaki uniforms, police caps, and speech bubbles.
class PolicePainter extends CustomPainter {
  final List<PoliceOfficer> officers;
  final double animTime;

  PolicePainter({
    required this.officers,
    required this.animTime,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final pol in officers) {
      _drawOfficer(canvas, pol);
    }
  }

  void _drawOfficer(Canvas canvas, PoliceOfficer pol) {
    const charScale = 3.8;

    canvas.save();
    canvas.translate(pol.x, pol.y);

    // ==========================================
    // 1. POLICE DETECTION AREA COVER
    // ==========================================
    if (pol.state == 'chase') {
      // Red Alert Coverage Field
      final chasePaint = Paint()
        ..shader = RadialGradient(
          colors: const [
            Color.fromRGBO(239, 68, 68, 0.42),
            Color.fromRGBO(220, 38, 38, 0.22),
            Color.fromRGBO(185, 28, 28, 0.08),
          ],
          stops: const [0.0, 0.65, 1.0],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: pol.visionRange));
      canvas.drawCircle(Offset.zero, pol.visionRange, chasePaint);

      // Pulsing Crimson Perimeter Ring
      final pulse = 1.0 + math.sin(animTime * 12) * 0.04;
      canvas.drawCircle(
        Offset.zero,
        pol.visionRange * pulse,
        Paint()
          ..color = const Color(0xFFEF4444)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5,
      );

      // Alternating Siren Flash Beam along facing angle
      final isRed = (animTime * 10).floor() % 2 == 0;
      final sirenColor = isRed
          ? const Color.fromRGBO(239, 68, 68, 0.55)
          : const Color.fromRGBO(59, 130, 246, 0.55);

      final sirenPath = Path()
        ..moveTo(0, 0)
        ..arcTo(
          Rect.fromCircle(center: Offset.zero, radius: pol.visionRange),
          pol.angle - 0.75,
          1.5,
          false,
        )
        ..close();
      canvas.drawPath(sirenPath, Paint()..color = sirenColor);
    } else {
      // Warm Searchlight Field
      final lightPaint = Paint()
        ..shader = RadialGradient(
          colors: const [
            Color.fromRGBO(254, 240, 138, 0.32),
            Color.fromRGBO(251, 191, 36, 0.18),
            Color.fromRGBO(245, 158, 11, 0.10),
            Color.fromRGBO(245, 158, 11, 0.03),
          ],
          stops: const [0.0, 0.5, 0.85, 1.0],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: pol.visionRange));
      canvas.drawCircle(Offset.zero, pol.visionRange, lightPaint);

      // Focused Flashlight / Torch Search Beam in front
      final beamPath = Path()
        ..moveTo(0, 0)
        ..arcTo(
          Rect.fromCircle(center: Offset.zero, radius: pol.visionRange),
          pol.angle - 0.7,
          1.4,
          false,
        )
        ..close();

      final beamPaint = Paint()
        ..shader = RadialGradient(
          colors: const [
            Color.fromRGBO(254, 240, 138, 0.50),
            Color.fromRGBO(251, 191, 36, 0.30),
            Color.fromRGBO(245, 158, 11, 0.05),
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: pol.visionRange));
      canvas.drawPath(beamPath, beamPaint);

      // Tactical Dashed Perimeter Ring
      _drawDashedCircle(
        canvas,
        Offset.zero,
        pol.visionRange,
        Paint()
          ..color = const Color.fromRGBO(251, 191, 36, 0.90)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.8,
      );

      // Radar sweep wave
      final sweepR = ((animTime * 0.55) % 1.0) * pol.visionRange;
      canvas.drawCircle(
        Offset.zero,
        sweepR,
        Paint()
          ..color = const Color.fromRGBO(254, 240, 138, 0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2,
      );
    }

    // Highlight aura ring around officer
    if (pol.state == 'chase') {
      final pulse = 1.0 + math.sin(animTime * 10) * 0.12;
      canvas.drawCircle(
        Offset.zero,
        12.0 * charScale * pulse,
        Paint()
          ..color = const Color.fromRGBO(239, 68, 68, 0.95)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5,
      );
    } else {
      canvas.drawCircle(
        Offset.zero,
        12.0 * charScale,
        Paint()
          ..color = const Color.fromRGBO(30, 64, 175, 0.75)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0,
      );
    }

    // 2. Officer Figurine
    canvas.save();
    canvas.scale(charScale, charScale);

    // Shadow
    canvas.drawOval(
      const Rect.fromLTWH(-9, 4, 18, 9),
      Paint()..color = const Color.fromRGBO(0, 0, 0, 0.28),
    );

    // Khaki Uniform
    canvas.drawRect(const Rect.fromLTWH(-6, -5, 12, 14), Paint()..color = const Color(0xFFB49F7D));

    // Belt & Badge
    canvas.drawRect(const Rect.fromLTWH(-6, 3, 12, 2.5), Paint()..color = const Color(0xFF1E293B));
    canvas.drawRect(const Rect.fromLTWH(-1, 3, 2, 2.5), Paint()..color = const Color(0xFFF59E0B));

    // Police Cap (Navy blue with Red band)
    canvas.drawCircle(const Offset(0, -11), 6.0, Paint()..color = const Color(0xFF1E3A8A));
    canvas.drawRect(const Rect.fromLTWH(-3, -16, 6, 3), Paint()..color = const Color(0xFFDC2626));

    // Lathi (baton)
    final lathiPaint = Paint()
      ..color = const Color(0xFF78350F)
      ..strokeWidth = 2.2;
    canvas.drawLine(const Offset(7, -6), const Offset(13, 8), lathiPaint);

    // Flashing siren during chase
    if (pol.state == 'chase') {
      final isRed = (animTime * 8).floor() % 2 == 0;
      canvas.drawCircle(
        const Offset(0, -20),
        3.5,
        Paint()..color = isRed ? const Color(0xFFEF4444) : const Color(0xFF3B82F6),
      );
    }

    canvas.restore(); // restore charScale
    canvas.restore(); // restore translate

    // 3. Status Bubble
    if (pol.bubbleTimer > 0) {
      final bubbleY = pol.y - (25.0 * charScale + 14.0);
      _drawBubble(canvas, pol.x, bubbleY, pol.bubbleText, pol.state == 'chase');
    }
  }

  void _drawDashedCircle(Canvas canvas, Offset center, double radius, Paint paint) {
    const dashLength = 10.0;
    const dashSpace = 7.0;
    final circumference = math.pi * 2 * radius;
    final numDashes = (circumference / (dashLength + dashSpace)).floor();
    final angleStep = (dashLength + dashSpace) / radius;
    final dashAngle = dashLength / radius;

    for (int i = 0; i < numDashes; i++) {
      final a = i * angleStep;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), a, dashAngle, false, paint);
    }
  }

  void _drawBubble(Canvas canvas, double x, double y, String text, bool isAlert) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white,
          fontSize: isAlert ? 12 : 10.5,
          fontWeight: isAlert ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final bw = textPainter.width + 18.0;
    const bh = 22.0;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(x, y), width: bw, height: bh),
      const Radius.circular(6),
    );

    canvas.drawRRect(
      rrect,
      Paint()
        ..color = isAlert ? const Color(0xFFDC2626) : const Color.fromRGBO(15, 23, 42, 0.92),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    textPainter.paint(
      canvas,
      Offset(x - textPainter.width / 2, y - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant PolicePainter oldDelegate) => true;
}
