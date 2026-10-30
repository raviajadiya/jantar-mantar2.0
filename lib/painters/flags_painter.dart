import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/flag_item.dart';
import '../models/particle.dart';

/// CustomPainter rendering protest flags along the road network and collection sparkle particles
class FlagsPainter extends CustomPainter {
  final List<FlagItem> flags;
  final List<CollectParticle> particles;
  final double animTime;

  FlagsPainter({
    required this.flags,
    required this.particles,
    required this.animTime,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Flags
    for (final f in flags) {
      if (!f.isCollected) {
        _drawFlag(canvas, f);
      }
    }

    // 2. Draw Particles
    for (final p in particles) {
      final alpha = math.max(0.0, math.min(1.0, p.life));
      final particlePaint = Paint()..color = p.color.withValues(alpha: alpha);
      canvas.drawCircle(Offset(p.x, p.y), p.size, particlePaint);
    }
  }

  void _drawFlag(Canvas canvas, FlagItem f) {
    const flagScale = 2.0;

    canvas.save();
    canvas.translate(f.x, f.y);

    // Glowing base aura
    final pulse = math.sin(animTime * 4 + f.pulseOffset) * 0.3 + 0.7;
    canvas.drawCircle(
      Offset.zero,
      36.0 * pulse * 1.15,
      Paint()..color = f.color.withValues(alpha: pulse * 0.38),
    );

    // Pulsing outer beacon ring
    canvas.drawCircle(
      Offset.zero,
      28.0 * pulse * 1.15,
      Paint()
        ..color = f.color.withValues(alpha: pulse * 0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    canvas.save();
    canvas.scale(flagScale, flagScale);

    // Flagpole base stone mount
    canvas.drawCircle(Offset.zero, 7.0, Paint()..color = const Color(0xFF475569));
    canvas.drawCircle(Offset.zero, 4.0, Paint()..color = const Color(0xFF94A3B8));

    // Golden Flagpole
    const poleH = 44.0;
    canvas.drawRect(const Rect.fromLTWH(-2, -poleH, 4, poleH + 2), Paint()..color = const Color(0xFFD97706));
    canvas.drawRect(const Rect.fromLTWH(-1, -poleH, 2, poleH + 2), Paint()..color = const Color(0xFFFBBF24));

    // Golden Orb
    canvas.drawCircle(const Offset(0, -poleH), 3.5, Paint()..color = const Color(0xFFFEF08A));

    // Waving Banner Cloth
    final wave = math.sin(animTime * 6 + f.pulseOffset) * 4.5;
    const flagW = 38.0;
    const flagH = 24.0;
    final stripes = f.stripeColors;
    final stripeH = flagH / stripes.length;

    for (int s = 0; s < stripes.length; s++) {
      final topY = -poleH + s * stripeH;
      final botY = topY + stripeH;
      final bPath = Path()
        ..moveTo(2, topY)
        ..lineTo(2 + flagW + wave, topY + wave * 0.45)
        ..lineTo(2 + flagW + wave, botY + wave * 0.45)
        ..lineTo(2, botY)
        ..close();
      canvas.drawPath(bPath, Paint()..color = stripes[s]);
    }

    // Flag outline
    final bBorder = Path()
      ..moveTo(2, -poleH)
      ..lineTo(2 + flagW + wave, -poleH + wave * 0.45)
      ..lineTo(2 + flagW + wave, -poleH + flagH + wave * 0.45)
      ..lineTo(2, -poleH + flagH);
    canvas.drawPath(
      bBorder,
      Paint()
        ..color = const Color.fromRGBO(0, 0, 0, 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    canvas.restore(); // restore scale
    canvas.restore(); // restore translate
  }

  @override
  bool shouldRepaint(covariant FlagsPainter oldDelegate) => true;
}
