import 'dart:math' as math;
import 'dart:ui';

/// Fast Euclidean hypotenuse utility
double hypot(double a, double b) => math.sqrt(a * a + b * b);

/// Core Game Configuration constants for Jantar Mantar 2.0
class GameConfig {
  static const double defaultWorldWidth = 3600.0;
  static const double defaultWorldHeight = 3600.0;
  static const Offset defaultCenter = Offset(1800.0, 1800.0);

  static const double roadWidth = 90.0;
  static const double sanctuaryRadius = 240.0;
  static const double centerPlazaRadius = 65.0;

  static const List<double> baseRings = [240.0, 480.0, 760.0, 1080.0, 1400.0];

  // Speeds
  static const double playerSpeed = 220.0;
  static const double playerSprintSpeed = 330.0;
  static const double policePatrolSpeed = 95.0;
  static const double policeChaseSpeed = 165.0;

  // Ranges & Distances
  static const double policeVisionRange = 145.0;
  static const double policeLoseChaseRange = 260.0;
  static const double catchDistance = 38.0;
  static const double flagPickupRadius = 75.0;
  static const double safeGraceSeconds = 4.0;
  static const double claimCapDistance = 60.0;

  // Zoom bounds
  static const double minZoom = 0.22;
  static const double maxZoom = 2.4;

  // Headlines
  static const List<String> newsHeadlines = [
    'MISSION: Collect all protest flags on Delhi\'s circular roads before reaching Jantar Mantar!',
    'POLICE WARNING: Delhi Police patrolling circular roads; stay out of their red vision cone!',
    'TIP: If police spot you, break line-of-sight and sprint onto another radial road to lose them!',
    'JANTAR MANTAR CENTER: Reach the Samrat Yantra sundial with all flags to achieve victory!',
    'DELHI DIARY: Raju Dhaba on Outer Ring is serving cutting chai to escaping protesters',
    'DHARNA UPDATE: Section 144 imposed on Ring 3; protesters taking Ring 2 detour'
  ];
}
