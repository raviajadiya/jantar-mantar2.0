import 'dart:math' as math;
import 'dart:ui';
import '../models/road_node.dart';
import '../models/road_segment.dart';
import '../constants/game_config.dart';

/// Road Network Engine: 100% interconnected graph, strict road constraints & Dijkstra pathfinding
class RoadNetwork {
  Offset center = GameConfig.defaultCenter;
  final double roadWidth = GameConfig.roadWidth;

  final List<RoadNode> nodes = [];
  final Map<int, List<int>> edges = {};
  final List<RoadSegment> segments = [];
  List<double> rings = [];
  List<double> radials = [];

  RoadNode? centerNode;
  int _nodeIdCounter = 0;
  int currentLevel = 1;

  RoadNetwork() {
    buildGraphForLevel(1);
  }

  void buildGraphForLevel(int level) {
    currentLevel = math.max(1, level);
    nodes.clear();
    edges.clear();
    segments.clear();
    _nodeIdCounter = 0;

    final cx = center.dx;
    final cy = center.dy;

    final extraRings = currentLevel ~/ 5;
    final List<double> base = [240.0, 480.0, 760.0, 1080.0, 1400.0];
    rings = List<double>.from(base);
    for (int i = 1; i <= extraRings; i++) {
      rings.add(1400.0 + i * 320.0);
    }
    final maxRingIdx = rings.length - 1;

    // 16 Radials
    radials = [];
    for (int i = 0; i < 16; i++) {
      radials.add(-math.pi / 2 + (i * math.pi) / 8);
    }
    final numRadials = radials.length;

    // 1. Segments: Circular Ring Roads
    for (final r in rings) {
      segments.add(RoadSegment.arc(
        cx: cx,
        cy: cy,
        radius: r,
        startAngle: 0,
        endAngle: math.pi * 2,
        width: 90.0,
      ));
    }

    // 8 Main Radial Avenues from Ring 0 to outermost
    for (int a = 0; a < numRadials; a += 2) {
      final angle = radials[a];
      segments.add(RoadSegment.line(
        x1: cx + math.cos(angle) * rings[0],
        y1: cy + math.sin(angle) * rings[0],
        x2: cx + math.cos(angle) * (rings[maxRingIdx] + 30),
        y2: cy + math.sin(angle) * (rings[maxRingIdx] + 30),
        width: 90.0,
        isMain: true,
      ));
    }

    // 8 Intermediate Radial Avenues from Ring 2 to outermost
    for (int a = 1; a < numRadials; a += 2) {
      final angle = radials[a];
      segments.add(RoadSegment.line(
        x1: cx + math.cos(angle) * rings[2],
        y1: cy + math.sin(angle) * rings[2],
        x2: cx + math.cos(angle) * (rings[maxRingIdx] + 30),
        y2: cy + math.sin(angle) * (rings[maxRingIdx] + 30),
        width: 90.0,
        isIntermediate: true,
      ));
    }

    // Central Sanctuary Circular Courtyard Plaza
    segments.add(RoadSegment.circle(
      cx: cx,
      cy: cy,
      radius: 65.0,
      width: 130.0,
    ));

    // 8 Radial Walkways into Central Plaza
    for (int a = 0; a < numRadials; a += 2) {
      final angle = radials[a];
      segments.add(RoadSegment.line(
        x1: cx,
        y1: cy,
        x2: cx + math.cos(angle) * rings[0],
        y2: cy + math.sin(angle) * rings[0],
        width: 65.0,
        isWalkway: true,
      ));
    }

    // 2. Exact Intersection Nodes Matrix: [ringIdx][radIdx]
    final List<List<RoadNode?>> matrix = List.generate(
      rings.length,
      (_) => List<RoadNode?>.filled(numRadials, null),
    );

    for (int r = 0; r < rings.length; r++) {
      for (int a = 0; a < numRadials; a++) {
        if (r < 2 && a % 2 != 0) continue;
        final angle = radials[a];
        final node = _createNode(
          cx + math.cos(angle) * rings[r],
          cy + math.sin(angle) * rings[r],
        );
        node.ringIndex = r;
        node.radialIndex = a;
        node.isMainSpoke = (a % 2 == 0);
        node.isIntersection = true;
        matrix[r][a] = node;
      }
    }

    // Center Sanctuary Hub Node (Gandhi Victory Cap)
    final cNode = _createNode(cx, cy, true);
    cNode.ringIndex = -1;
    cNode.isIntersection = true;
    centerNode = cNode;

    // Connect Center Node to all 8 Ring 0 intersections
    for (int a = 0; a < numRadials; a += 2) {
      final ring0Node = matrix[0][a]!;
      final angle = radials[a];

      final walk1 = _createNode(
        cx + math.cos(angle) * (rings[0] * 0.35),
        cy + math.sin(angle) * (rings[0] * 0.35),
      );
      walk1.isCenterAvenue = true;
      walk1.radialIndex = a;

      final walk2 = _createNode(
        cx + math.cos(angle) * (rings[0] * 0.70),
        cy + math.sin(angle) * (rings[0] * 0.70),
      );
      walk2.isCenterAvenue = true;
      walk2.radialIndex = a;

      _connect(cNode.id, walk1.id);
      _connect(walk1.id, walk2.id);
      _connect(walk2.id, ring0Node.id);
    }

    // Connect radially between rings
    for (int a = 0; a < numRadials; a++) {
      final startR = (a % 2 == 0) ? 0 : 2;
      for (int r = startR; r < rings.length - 1; r++) {
        final n1 = matrix[r][a];
        final n2 = matrix[r + 1][a];
        if (n1 == null || n2 == null) continue;

        final mid1 = _createNode(
          n1.x + (n2.x - n1.x) * 0.33,
          n1.y + (n2.y - n1.y) * 0.33,
        );
        mid1.ringIndex = r;
        mid1.radialIndex = a;

        final mid2 = _createNode(
          n1.x + (n2.x - n1.x) * 0.67,
          n1.y + (n2.y - n1.y) * 0.67,
        );
        mid2.ringIndex = r;
        mid2.radialIndex = a;

        _connect(n1.id, mid1.id);
        _connect(mid1.id, mid2.id);
        _connect(mid2.id, n2.id);
      }
    }

    // Connect circularly along each ring
    for (int r = 0; r < rings.length; r++) {
      final radius = rings[r];
      final step = (r < 2) ? 2 : 1;
      final div = (r < 2) ? 4 : 3;

      for (int a = 0; a < numRadials; a += step) {
        final nextA = (a + step) % numRadials;
        final startNode = matrix[r][a];
        final endNode = matrix[r][nextA];
        if (startNode == null || endNode == null) continue;

        double startAngle = radials[a];
        double endAngle = radials[nextA];
        if (endAngle <= startAngle) endAngle += math.pi * 2;

        RoadNode prev = startNode;
        for (int s = 1; s < div; s++) {
          final t = s / div;
          final arcAngle = startAngle + t * (endAngle - startAngle);
          final subNode = _createNode(
            cx + math.cos(arcAngle) * radius,
            cy + math.sin(arcAngle) * radius,
          );
          subNode.ringIndex = r;
          _connect(prev.id, subNode.id);
          prev = subNode;
        }
        _connect(prev.id, endNode.id);
      }
    }
  }

  RoadNode _createNode(double x, double y, [bool isCenter = false]) {
    final node = RoadNode(
      id: _nodeIdCounter++,
      x: x,
      y: y,
      isCenter: isCenter,
    );
    nodes.add(node);
    edges[node.id] = [];
    return node;
  }

  void _connect(int idA, int idB) {
    if (idA == idB) return;
    edges.putIfAbsent(idA, () => []);
    edges.putIfAbsent(idB, () => []);

    final listA = edges[idA]!;
    final listB = edges[idB]!;
    if (!listA.contains(idB)) listA.add(idB);
    if (!listB.contains(idA)) listB.add(idA);
  }

  List<RoadNode> getOuterRingNodes() {
    final maxRingIdx = rings.length - 1;
    return nodes.where((n) => n.ringIndex == maxRingIdx).toList();
  }

  List<RoadNode> getOuterRingSpokeNodes() {
    final maxRingIdx = rings.length - 1;
    return nodes
        .where((n) => n.ringIndex == maxRingIdx && n.isIntersection && n.isMainSpoke)
        .toList();
  }

  double distToSegment(double px, double py, double x1, double y1, double x2, double y2) {
    final dx = x2 - x1;
    final dy = y2 - y1;
    final lenSq = dx * dx + dy * dy;
    if (lenSq == 0) return hypot(px - x1, py - y1);
    double t = ((px - x1) * dx + (py - y1) * dy) / lenSq;
    t = math.max(0.0, math.min(1.0, t));
    return hypot(px - (x1 + t * dx), py - (y1 + t * dy));
  }

  bool isPointOnRoad(double x, double y, [double padding = 15.0]) {
    for (final seg in segments) {
      final halfW = (seg.width / 2) + padding;
      if (seg.type == RoadSegmentType.line) {
        final d = distToSegment(x, y, seg.x1, seg.y1, seg.x2, seg.y2);
        if (d <= halfW) return true;
      } else if (seg.type == RoadSegmentType.circle) {
        final dToC = hypot(x - seg.cx, y - seg.cy);
        if (dToC <= seg.radius + padding) return true;
      } else if (seg.type == RoadSegmentType.arc) {
        final dToC = hypot(x - seg.cx, y - seg.cy);
        if ((dToC - seg.radius).abs() <= halfW) {
          if ((seg.endAngle - seg.startAngle).abs() >= math.pi * 1.95) return true;
          double a = math.atan2(y - seg.cy, x - seg.cx);
          if (a < 0) a += math.pi * 2;
          double s = seg.startAngle % (math.pi * 2);
          if (s < 0) s += math.pi * 2;
          double e = seg.endAngle % (math.pi * 2);
          if (e < 0) e += math.pi * 2;
          if (s <= e) {
            if (a >= s - 0.05 && a <= e + 0.05) return true;
          } else {
            if (a >= s - 0.05 || a <= e + 0.05) return true;
          }
        }
      }
    }
    return false;
  }

  Offset findClosestPointOnRoad(double px, double py) {
    double bestDist = double.infinity;
    Offset bestPoint = Offset(px, py);

    for (final seg in segments) {
      if (seg.type == RoadSegmentType.line) {
        final dx = seg.x2 - seg.x1;
        final dy = seg.y2 - seg.y1;
        final lenSq = dx * dx + dy * dy;
        double t = lenSq == 0 ? 0.0 : ((px - seg.x1) * dx + (py - seg.y1) * dy) / lenSq;
        t = math.max(0.0, math.min(1.0, t));
        final projX = seg.x1 + t * dx;
        final projY = seg.y1 + t * dy;
        final dist = hypot(px - projX, py - projY);
        if (dist < bestDist) {
          bestDist = dist;
          bestPoint = Offset(projX, projY);
        }
      } else if (seg.type == RoadSegmentType.circle) {
        final dToC = hypot(px - seg.cx, py - seg.cy);
        if (dToC <= seg.radius) {
          return Offset(px, py);
        }
        final a = math.atan2(py - seg.cy, px - seg.cx);
        final projX = seg.cx + math.cos(a) * seg.radius;
        final projY = seg.cy + math.sin(a) * seg.radius;
        final dist = dToC - seg.radius;
        if (dist < bestDist) {
          bestDist = dist;
          bestPoint = Offset(projX, projY);
        }
      } else if (seg.type == RoadSegmentType.arc) {
        final a = math.atan2(py - seg.cy, px - seg.cx);
        final projX = seg.cx + math.cos(a) * seg.radius;
        final projY = seg.cy + math.sin(a) * seg.radius;
        final dist = hypot(px - projX, py - projY);
        if (dist < bestDist) {
          bestDist = dist;
          bestPoint = Offset(projX, projY);
        }
      }
    }
    return bestPoint;
  }

  RoadNode? findClosestNode(double x, double y) {
    RoadNode? closest;
    double minDist = double.infinity;
    for (final node in nodes) {
      final d = hypot(node.x - x, node.y - y);
      if (d < minDist) {
        minDist = d;
        closest = node;
      }
    }
    return closest;
  }

  bool hasRoadLineOfSight(double x1, double y1, double x2, double y2) {
    final dist = hypot(x2 - x1, y2 - y1);
    if (dist < 8) return true;
    if (dist > 350) return false;
    final steps = math.max(6, (dist / 22).ceil());

    for (int i = 1; i < steps; i++) {
      final t = i / steps;
      final testX = x1 + (x2 - x1) * t;
      final testY = y1 + (y2 - y1) * t;
      if (!isPointOnRoad(testX, testY, -6.0)) {
        return false;
      }
    }
    return true;
  }

  List<Offset> findPath(double startX, double startY, double targetX, double targetY) {
    if (hasRoadLineOfSight(startX, startY, targetX, targetY)) {
      return [Offset(targetX, targetY)];
    }

    final startNode = findClosestNode(startX, startY);
    final targetNode = findClosestNode(targetX, targetY);
    if (startNode == null || targetNode == null) return [];

    if (startNode.id == targetNode.id) {
      final res = <Offset>[];
      if (hypot(startX - startNode.x, startY - startNode.y) > 12) {
        res.add(Offset(startNode.x, startNode.y));
      }
      res.add(Offset(targetX, targetY));
      return res;
    }

    // Dijkstra
    final dist = <int, double>{};
    final parent = <int, int>{};
    final unvisited = <int>{};

    for (final node in nodes) {
      dist[node.id] = double.infinity;
      unvisited.add(node.id);
    }
    dist[startNode.id] = 0.0;

    final nodeMap = {for (var n in nodes) n.id: n};

    while (unvisited.isNotEmpty) {
      int? currentId;
      double minD = double.infinity;
      for (final id in unvisited) {
        final d = dist[id]!;
        if (d < minD) {
          minD = d;
          currentId = id;
        }
      }

      if (currentId == null || minD == double.infinity) break;
      if (currentId == targetNode.id) break;

      unvisited.remove(currentId);
      final currNode = nodeMap[currentId]!;
      final neighbors = edges[currentId] ?? [];

      for (final nId in neighbors) {
        if (!unvisited.contains(nId)) continue;
        final neighborNode = nodeMap[nId]!;
        final stepDist = hypot(neighborNode.x - currNode.x, neighborNode.y - currNode.y);
        final alt = minD + stepDist;

        if (alt < dist[nId]!) {
          dist[nId] = alt;
          parent[nId] = currentId;
        }
      }
    }

    if (!parent.containsKey(targetNode.id)) {
      return [];
    }

    final nodePath = <Offset>[];
    int? curr = targetNode.id;
    while (curr != null) {
      final n = nodeMap[curr]!;
      nodePath.insert(0, Offset(n.x, n.y));
      curr = parent[curr];
    }

    int startIndex = 0;
    if (nodePath.length > 1 && hasRoadLineOfSight(startX, startY, nodePath[1].dx, nodePath[1].dy)) {
      startIndex = 1;
    }

    final fullPath = <Offset>[];
    for (int i = startIndex; i < nodePath.length; i++) {
      fullPath.add(nodePath[i]);
    }

    if (hypot(targetX - targetNode.x, targetY - targetNode.y) > 8) {
      fullPath.add(Offset(targetX, targetY));
    }

    return fullPath;
  }
}
