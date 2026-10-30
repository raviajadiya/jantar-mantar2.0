import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/particle.dart';

/// CustomPainter rendering 3D rotating confetti, paper cards and gold stars
class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;

  ConfettiPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      if (p.opacity <= 0) continue;

      canvas.save();
      canvas.translate(p.x, p.y);
      canvas.rotate(p.rotZ);

      final alpha = math.max(0.0, math.min(1.0, p.opacity));
      final particlePaint = Paint()..color = p.color.withValues(alpha: alpha);

      if (p.type == 'star') {
        final starSize = (p.w / 2) * math.cos(p.rotZ).abs();
        _drawStar(
          canvas,
          0,
          0,
          5,
          math.max(3.0, starSize),
          math.max(1.5, starSize * 0.48),
          p.color.withValues(alpha: alpha),
        );
      } else {
        // Card or Ribbon
        final scaleX = math.cos(p.rotX);
        final scaleY = math.sin(p.rotY);
        canvas.scale(scaleX == 0 ? 0.05 : scaleX, scaleY == 0 ? 0.05 : scaleY);

        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: p.w, height: p.h),
          particlePaint,
        );

        // Edge shine
        canvas.drawRect(
          Rect.fromLTWH(-p.w / 2, -p.h / 2, p.w, 2),
          Paint()..color = Colors.white.withValues(alpha: alpha * 0.4),
        );
      }

      canvas.restore();
    }
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
  }

  @override
  bool shouldRepaint(covariant ConfettiPainter oldDelegate) => true;
}
