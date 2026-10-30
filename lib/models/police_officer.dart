import 'dart:ui';

/// Delhi Police patrol and chase state
class PoliceOfficer {
  final String id;
  final String name;
  final double startX;
  final double startY;
  double x;
  double y;
  double angle;
  String state; // 'patrol', 'chase', 'lost'
  final double speed;
  final double chaseSpeed;
  final double visionRange;
  final double loseChaseRange;

  List<Offset> currentPath;
  int waypointIndex;
  final String patrolType;
  final int ringIdx;
  final int patrolDir;
  final int spokeIdx;

  String bubbleText;
  double bubbleTimer;

  PoliceOfficer({
    required this.id,
    required this.name,
    required this.startX,
    required this.startY,
    required this.x,
    required this.y,
    this.angle = 0.0,
    this.state = 'patrol',
    this.speed = 95.0,
    this.chaseSpeed = 165.0,
    this.visionRange = 145.0,
    this.loseChaseRange = 260.0,
    List<Offset>? currentPath,
    this.waypointIndex = 0,
    this.patrolType = 'ring',
    this.ringIdx = 1,
    this.patrolDir = 1,
    this.spokeIdx = 0,
    this.bubbleText = 'Patrolling road',
    this.bubbleTimer = 0.0,
  }) : currentPath = currentPath ?? [];

  Offset get position => Offset(x, y);
}
