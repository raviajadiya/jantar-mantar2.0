import 'package:flutter/material.dart';

/// Particle for flag collection sparkles
class CollectParticle {
  double x;
  double y;
  double vx;
  double vy;
  Color color;
  double life;
  double size;

  CollectParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.life,
    required this.size,
  });
}

/// Particle for victory celebration blast (paper card, star, ribbon)
class ConfettiParticle {
  double x;
  double y;
  double vx;
  double vy;
  String type; // 'card', 'star', 'ribbon'
  Color color;
  double w;
  double h;
  double rotX;
  double rotY;
  double rotZ;
  double spinX;
  double spinY;
  double spinZ;
  double gravity;
  double drag;
  double wobble;
  double wobbleSpeed;
  double wobbleAmp;
  double opacity;
  double fadeSpeed;
  int life;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.type,
    required this.color,
    required this.w,
    required this.h,
    required this.rotX,
    required this.rotY,
    required this.rotZ,
    required this.spinX,
    required this.spinY,
    required this.spinZ,
    required this.gravity,
    required this.drag,
    required this.wobble,
    required this.wobbleSpeed,
    required this.wobbleAmp,
    required this.opacity,
    required this.fadeSpeed,
    this.life = 0,
  });
}
