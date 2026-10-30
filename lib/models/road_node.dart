import 'dart:ui';

/// Node in the Delhi circular road graph
class RoadNode {
  final int id;
  final double x;
  final double y;
  final bool isCenter;
  int ringIndex;
  int radialIndex;
  bool isIntersection;
  bool isMainSpoke;
  bool isCenterAvenue;

  RoadNode({
    required this.id,
    required this.x,
    required this.y,
    this.isCenter = false,
    this.ringIndex = -1,
    this.radialIndex = -1,
    this.isIntersection = false,
    this.isMainSpoke = false,
    this.isCenterAvenue = false,
  });

  Offset get position => Offset(x, y);
}
