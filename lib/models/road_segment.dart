enum RoadSegmentType { line, arc, circle }

/// Road segment representation for collision check and visual corridor rendering
class RoadSegment {
  final RoadSegmentType type;
  final double width;

  // For Line
  final double x1;
  final double y1;
  final double x2;
  final double y2;
  final bool isMain;
  final bool isIntermediate;
  final bool isWalkway;

  // For Arc & Circle
  final double cx;
  final double cy;
  final double radius;
  final double startAngle;
  final double endAngle;

  const RoadSegment.line({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    this.width = 90.0,
    this.isMain = false,
    this.isIntermediate = false,
    this.isWalkway = false,
  })  : type = RoadSegmentType.line,
        cx = 0,
        cy = 0,
        radius = 0,
        startAngle = 0,
        endAngle = 0;

  const RoadSegment.arc({
    required this.cx,
    required this.cy,
    required this.radius,
    required this.startAngle,
    required this.endAngle,
    this.width = 90.0,
  })  : type = RoadSegmentType.arc,
        x1 = 0,
        y1 = 0,
        x2 = 0,
        y2 = 0,
        isMain = false,
        isIntermediate = false,
        isWalkway = false;

  const RoadSegment.circle({
    required this.cx,
    required this.cy,
    required this.radius,
    this.width = 130.0,
  })  : type = RoadSegmentType.circle,
        x1 = 0,
        y1 = 0,
        x2 = 0,
        y2 = 0,
        startAngle = 0,
        endAngle = 6.283185307179586,
        isMain = false,
        isIntermediate = false,
        isWalkway = false;
}
