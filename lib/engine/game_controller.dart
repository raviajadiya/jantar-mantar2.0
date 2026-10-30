import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/game_config.dart';
import '../constants/map_themes.dart';
import '../constants/country_data.dart';
import '../models/flag_item.dart';
import '../models/police_officer.dart';
import '../models/particle.dart';
import 'road_network.dart';
import 'game_camera.dart';
import 'game_audio.dart';

/// Main State Coordinator & Game Logic Controller
class GameController extends ChangeNotifier {
  late RoadNetwork roadNetwork;
  late GameCamera camera;

  MapTheme currentTheme = MapThemes.dark;
  CountryFaction selectedCountry = CountryData.countries[0]; // India
  String playerName = 'Protester';

  // Player State
  Offset playerPos = const Offset(400, 1800);
  double playerAngle = 0.0;
  bool isMoving = false;
  bool isSprinting = false;
  List<Offset> playerPath = [];
  int currentWaypointIndex = 0;
  bool manualMovingThisFrame = false;

  // Entities
  List<FlagItem> flags = [];
  final List<CollectParticle> collectParticles = [];
  List<PoliceOfficer> officers = [];
  final List<ConfettiParticle> confettiParticles = [];
  bool isConfettiActive = false;

  // Lifecycle
  int currentLevel = 1;
  bool isGameStarted = false;
  bool isGameOver = false;
  bool isVictory = false;
  bool isArrested = false;
  PoliceOfficer? arrestingOfficer;

  double graceTimer = 0.0;
  double animTime = 0.0;
  double cinematicAngle = 0.0;
  double sunAngle = 0.0;

  // UI Modals
  bool isHelpModalOpen = false;
  bool isZoomDropdownOpen = false;

  // Pause & Resume Countdown
  bool isPaused = false;
  int resumeCountdown = 0;
  Timer? _resumeTimer;

  void pauseGame() {
    isPaused = true;
    _resumeTimer?.cancel();
    resumeCountdown = 0;
    notifyListeners();
  }

  void startResumeCountdown() {
    _resumeTimer?.cancel();
    resumeCountdown = 3;
    notifyListeners();

    _resumeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resumeCountdown > 1) {
        resumeCountdown--;
        notifyListeners();
      } else {
        resumeCountdown = 0;
        isPaused = false;
        _resumeTimer?.cancel();
        notifyListeners();
      }
    });
  }

  GameController() {
    roadNetwork = RoadNetwork();
    camera = GameCamera(
      worldWidth: GameConfig.defaultWorldWidth,
      worldHeight: GameConfig.defaultWorldHeight,
    );
    _initLevel(1);
    _spawnPlayerOnOuterRing();
  }

  void _initLevel(int level) {
    currentLevel = level;
    isGameOver = false;
    isVictory = false;
    isArrested = false;
    arrestingOfficer = null;
    collectParticles.clear();
    confettiParticles.clear();
    isConfettiActive = false;
    camera.clearFollow();
    camera.isDragging = false;
    camera.setZoom(0.52);

    // Road network
    roadNetwork.buildGraphForLevel(level);

    // World size
    final maxR = roadNetwork.rings.last;
    final worldSize = (maxR + 380.0) * 2;
    roadNetwork.center = Offset(worldSize / 2, worldSize / 2);
    camera.setWorldSize(worldSize, worldSize);

    // Flags
    _initFlags();

    // Police
    _initPolice();
  }

  void _initFlags() {
    flags.clear();
    final count = 4 + currentLevel * 2;

    final validNodes = roadNetwork.nodes.where((n) {
      return !n.isCenter && n.ringIndex >= 1 && n.isIntersection;
    }).toList();

    if (validNodes.isEmpty) return;

    final step = math.max(1, validNodes.length ~/ count);

    for (int i = 0; i < count; i++) {
      final nodeIdx = (i * step + 1) % validNodes.length;
      final node = validNodes[nodeIdx];

      flags.add(FlagItem(
        id: 'flag-lvl$currentLevel-${i + 1}',
        name: '${selectedCountry.emoji} Flag #${i + 1} (${selectedCountry.name})',
        label: 'Flag #${i + 1}',
        color: selectedCountry.color,
        stripeColors: selectedCountry.stripeColors,
        countryEmoji: selectedCountry.emoji,
        x: node.x,
        y: node.y,
        pulseOffset: i * 0.65,
      ));
    }
  }

  void _initPolice() {
    officers.clear();
    final count = math.min<int>(18, 8 + (currentLevel - 1) * 2);
    final rings = roadNetwork.rings;
    final radials = roadNetwork.radials;
    final center = roadNetwork.center;
    final maxRingIdx = rings.length - 1;

    final baseNames = [
      'Const. Bhati', 'Const. Sharma', 'Const. Gupta', 'SI Verma',
      'Const. Yadav', 'ACP Malik', 'Insp. Chauhan', 'Const. Singh',
      'Const. Meena', 'Insp. Rawat', 'Const. Tomar', 'SI Tyagi',
    ];

    for (int i = 0; i < count; i++) {
      final ringIdx = 1 + (i % math.max<int>(1, maxRingIdx - 1));
      final radIdx = (i * 2 + 1) % radials.length;
      final angle = radials[radIdx];
      final r = rings[ringIdx];

      final x = center.dx + math.cos(angle) * r;
      final y = center.dy + math.sin(angle) * r;

      officers.add(PoliceOfficer(
        id: 'pol-$i',
        name: baseNames[i % baseNames.length],
        startX: x,
        startY: y,
        x: x,
        y: y,
        angle: angle,
        patrolType: (i % 2 == 0) ? 'ring' : 'radial',
        ringIdx: ringIdx,
        spokeIdx: radIdx,
        patrolDir: (i % 3 == 0) ? -1 : 1,
      ));
    }
  }

  void _spawnPlayerOnOuterRing() {
    final outerNodes = roadNetwork.getOuterRingNodes();
    if (outerNodes.isNotEmpty) {
      final node = outerNodes[math.Random().nextInt(outerNodes.length)];
      playerPos = Offset(node.x, node.y);
    } else {
      playerPos = Offset(roadNetwork.center.dx + 1400, roadNetwork.center.dy);
    }
    playerPath.clear();
    isMoving = false;
  }

  void startGame() {
    GameAudio.playDeploy();
    GameAudio.playGameplayBgm();
    isPaused = false;
    resumeCountdown = 0;
    _resumeTimer?.cancel();
    isGameOver = false;
    isVictory = false;
    isArrested = false;
    _spawnPlayerOnOuterRing();

    // Reset police & grant 4s safe immunity
    graceTimer = GameConfig.safeGraceSeconds;
    for (final off in officers) {
      off.x = off.startX;
      off.y = off.startY;
      if (hypot(off.x - playerPos.dx, off.y - playerPos.dy) < 650) {
        off.x = roadNetwork.center.dx - (off.startX - roadNetwork.center.dx);
        off.y = roadNetwork.center.dy - (off.startY - roadNetwork.center.dy);
      }
      off.state = 'patrol';
      off.currentPath.clear();
      off.bubbleText = 'Patrolling road';
      off.bubbleTimer = 1.0;
    }

    isGameStarted = true;
    camera.moveTo(playerPos.dx, playerPos.dy);
    camera.setFollow(playerPos);
    camera.setZoom(0.52);
    notifyListeners();
  }

  void switchTheme(MapTheme theme) {
    currentTheme = theme;
    GameAudio.playSelect();
    notifyListeners();
  }

  void setPlayerProfile(String name, CountryFaction country) {
    if (name.trim().isNotEmpty) {
      playerName = name.trim();
    }
    selectedCountry = country;
    for (final f in flags) {
      f.countryEmoji = country.emoji;
      f.color = country.color;
      f.stripeColors = country.stripeColors;
    }
    GameAudio.playSelect();
    notifyListeners();
  }

  void toggleHelpModal() {
    isHelpModalOpen = !isHelpModalOpen;
    GameAudio.playSelect();
    notifyListeners();
  }

  void closeHelpModal() {
    isHelpModalOpen = false;
    notifyListeners();
  }

  void toggleZoomDropdown() {
    isZoomDropdownOpen = !isZoomDropdownOpen;
    GameAudio.playSelect();
    notifyListeners();
  }

  void closeZoomDropdown() {
    if (isZoomDropdownOpen) {
      isZoomDropdownOpen = false;
      notifyListeners();
    }
  }

  void setDestination(double targetX, double targetY) {
    final targetRoad = roadNetwork.findClosestPointOnRoad(targetX, targetY);
    final startRoad = roadNetwork.findClosestPointOnRoad(playerPos.dx, playerPos.dy);
    final path = roadNetwork.findPath(startRoad.dx, startRoad.dy, targetRoad.dx, targetRoad.dy);

    if (path.isNotEmpty) {
      playerPath = path;
      currentWaypointIndex = 0;
      isMoving = true;
      camera.isDragging = false;
      camera.setFollow(playerPos);
      notifyListeners();
    }
  }

  void manualMove(double dx, double dy, double deltaTime, bool isSprint) {
    isSprinting = isSprint;
    manualMovingThisFrame = true;
    final curSpeed = isSprint ? GameConfig.playerSprintSpeed : GameConfig.playerSpeed;
    final len = hypot(dx, dy);
    if (len == 0) return;

    final step = curSpeed * deltaTime;
    final stepX = (dx / len) * step;
    final stepY = (dy / len) * step;

    // 1. Try full diagonal step
    if (roadNetwork.isPointOnRoad(playerPos.dx + stepX, playerPos.dy + stepY, 15.0)) {
      playerPos = Offset(playerPos.dx + stepX, playerPos.dy + stepY);
      playerAngle = math.atan2(dy, dx);
      isMoving = true;
      playerPath.clear();
      camera.setFollow(playerPos);
      return;
    }

    // 2. Slide X only
    if (roadNetwork.isPointOnRoad(playerPos.dx + stepX, playerPos.dy, 15.0)) {
      playerPos = Offset(playerPos.dx + stepX, playerPos.dy);
      playerAngle = math.atan2(0, dx);
      isMoving = true;
      playerPath.clear();
      camera.setFollow(playerPos);
      return;
    }

    // 3. Slide Y only
    if (roadNetwork.isPointOnRoad(playerPos.dx, playerPos.dy + stepY, 15.0)) {
      playerPos = Offset(playerPos.dx, playerPos.dy + stepY);
      playerAngle = math.atan2(dy, 0);
      isMoving = true;
      playerPath.clear();
      camera.setFollow(playerPos);
      return;
    }
  }

  void triggerVictory() {
    isGameOver = true;
    isVictory = true;
    GameAudio.playNextLevelSound();
    spawnCelebrationBlast(camera.viewportWidth / 2, camera.viewportHeight / 2);
    notifyListeners();
  }

  void triggerArrest(PoliceOfficer officer) {
    isGameOver = true;
    isArrested = true;
    arrestingOfficer = officer;
    GameAudio.playPoliceSiren();
    GameAudio.playGameOverBgm();
    notifyListeners();
  }

  void continueNextLevel() {
    _initLevel(currentLevel + 1);
    startGame();
  }

  void restartGame() {
    _initLevel(currentLevel);
    startGame();
  }

  void goToHome() {
    isPaused = false;
    resumeCountdown = 0;
    _resumeTimer?.cancel();
    isGameOver = false;
    isGameStarted = false;
    isVictory = false;
    isArrested = false;
    isConfettiActive = false;
    confettiParticles.clear();
    camera.clearFollow();
    camera.isDragging = false;
    camera.setZoom(0.52);
    _initLevel(1);
    _spawnPlayerOnOuterRing();
    GameAudio.playHomeBgm();
    notifyListeners();
  }

  void spawnCelebrationBlast(double cx, double cy) {
    confettiParticles.clear();
    isConfettiActive = true;

    final cardColors = [
      const Color(0xFFF97316),
      const Color(0xFFFFFFFF),
      const Color(0xFF16A34A),
      const Color(0xFFFACC15),
      const Color(0xFF38BDF8),
      const Color(0xFFEC4899),
      const Color(0xFFA855F7),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
    ];

    final rnd = math.Random();
    for (int i = 0; i < 160; i++) {
      final roll = rnd.nextDouble();
      final isStar = roll < 0.30;
      final isRibbon = roll >= 0.30 && roll < 0.48;
      final type = isStar ? 'star' : (isRibbon ? 'ribbon' : 'card');

      final angle = rnd.nextDouble() * math.pi * 2;
      final speed = 8.0 + rnd.nextDouble() * 20.0;

      confettiParticles.add(ConfettiParticle(
        x: cx + (rnd.nextDouble() - 0.5) * 60,
        y: cy + (rnd.nextDouble() - 0.5) * 60,
        vx: math.cos(angle) * speed,
        vy: math.sin(angle) * speed,
        type: type,
        color: cardColors[rnd.nextInt(cardColors.length)],
        w: isStar ? 16 : (isRibbon ? 6 : (11 + rnd.nextDouble() * 12)),
        h: isStar ? 16 : (isRibbon ? 24 + rnd.nextDouble() * 20 : (8 + rnd.nextDouble() * 10)),
        rotX: rnd.nextDouble() * math.pi * 2,
        rotY: rnd.nextDouble() * math.pi * 2,
        rotZ: rnd.nextDouble() * math.pi * 2,
        spinX: (rnd.nextDouble() - 0.5) * 0.28,
        spinY: (rnd.nextDouble() - 0.5) * 0.28,
        spinZ: (rnd.nextDouble() - 0.5) * 0.18,
        gravity: 0.36 + rnd.nextDouble() * 0.18,
        drag: 0.965,
        wobble: rnd.nextDouble() * math.pi * 2,
        wobbleSpeed: 0.05 + rnd.nextDouble() * 0.08,
        wobbleAmp: 1.2 + rnd.nextDouble() * 2.0,
        opacity: 1.0,
        fadeSpeed: 0.003 + rnd.nextDouble() * 0.005,
      ));
    }
  }

  void _spawnCollectParticles(double x, double y, List<Color> colors) {
    final rnd = math.Random();
    for (int i = 0; i < 28; i++) {
      final angle = rnd.nextDouble() * math.pi * 2;
      final speed = 70.0 + rnd.nextDouble() * 140.0;
      collectParticles.add(CollectParticle(
        x: x,
        y: y,
        vx: math.cos(angle) * speed,
        vy: math.sin(angle) * speed,
        color: colors[rnd.nextInt(colors.length)],
        life: 0.9 + rnd.nextDouble() * 0.5,
        size: 3.0 + rnd.nextDouble() * 4.0,
      ));
    }
  }

  bool get areAllFlagsCollected => flags.isNotEmpty && flags.every((f) => f.isCollected);
  int get collectedCount => flags.where((f) => f.isCollected).length;
  int get totalFlagsCount => flags.length;

  /// Game tick loop called by ticker / VSync
  void update(double deltaTime) {
    animTime += deltaTime;
    sunAngle += deltaTime * 0.15;

    if (!isGameStarted) {
      cinematicAngle += deltaTime * 0.16;
      const radius = 640.0;
      final camX = roadNetwork.center.dx + math.cos(cinematicAngle) * radius;
      final camY = roadNetwork.center.dy + math.sin(cinematicAngle * 0.8) * (radius * 0.65);
      camera.moveTo(camX, camY);
      camera.update();
      notifyListeners();
      return;
    }

    if (isPaused || resumeCountdown > 0) {
      notifyListeners();
      return;
    }

    if (graceTimer > 0) {
      graceTimer -= deltaTime;
    }

    final curSpeed = isSprinting ? GameConfig.playerSprintSpeed : GameConfig.playerSpeed;

    // 1. Player Waypoint Follow
    if (playerPath.isNotEmpty && currentWaypointIndex < playerPath.length) {
      final target = playerPath[currentWaypointIndex];
      final dx = target.dx - playerPos.dx;
      final dy = target.dy - playerPos.dy;
      final dist = hypot(dx, dy);

      if (dist < 14) {
        currentWaypointIndex++;
        if (currentWaypointIndex >= playerPath.length) {
          playerPath.clear();
          isMoving = false;
        }
      } else {
        isMoving = true;
        playerAngle = math.atan2(dy, dx);
        final step = math.min(dist, curSpeed * deltaTime);
        final nextX = playerPos.dx + (dx / dist) * step;
        final nextY = playerPos.dy + (dy / dist) * step;

        if (roadNetwork.isPointOnRoad(nextX, nextY, 15.0)) {
          playerPos = Offset(nextX, nextY);
        } else {
          final snapped = roadNetwork.findClosestPointOnRoad(nextX, nextY);
          playerPos = snapped;
        }
      }
    } else if (playerPath.isEmpty && !manualMovingThisFrame) {
      isMoving = false;
    }
    manualMovingThisFrame = false;

    // 2. Flags collection
    if (!isGameOver) {
      for (final f in flags) {
        if (!f.isCollected) {
          final dist = hypot(playerPos.dx - f.x, playerPos.dy - f.y);
          if (dist < GameConfig.flagPickupRadius) {
            f.isCollected = true;
            _spawnCollectParticles(f.x, f.y, f.stripeColors);
            GameAudio.playCollect();

            if (areAllFlagsCollected) {
              GameAudio.playFanfare();
              setDestination(roadNetwork.center.dx, roadNetwork.center.dy);
            }
          }
        }
      }

      // Check Victory Condition
      final distToCenter = hypot(
        playerPos.dx - roadNetwork.center.dx,
        playerPos.dy - roadNetwork.center.dy,
      );
      if (areAllFlagsCollected && distToCenter < GameConfig.claimCapDistance) {
        triggerVictory();
      }
    }

    // 3. Police AI updates
    if (!isGameOver) {
      final playerInSanctuary = hypot(
        playerPos.dx - roadNetwork.center.dx,
        playerPos.dy - roadNetwork.center.dy,
      ) < 230.0;

      final isPlayerSafe = graceTimer > 0 || (areAllFlagsCollected && playerInSanctuary);

      for (final off in officers) {
        off.bubbleTimer -= deltaTime;
        final distToPlayer = hypot(playerPos.dx - off.x, playerPos.dy - off.y);
        final hasLOS = !isPlayerSafe &&
            distToPlayer < off.visionRange &&
            roadNetwork.hasRoadLineOfSight(off.x, off.y, playerPos.dx, playerPos.dy);

        if (areAllFlagsCollected && playerInSanctuary && off.state == 'chase') {
          off.state = 'lost';
          off.bubbleText = '⚠️ Sanctuary Zone! Cannot enter!';
          off.bubbleTimer = 2.5;
          off.currentPath.clear();
        } else if (isPlayerSafe && off.state != 'patrol') {
          off.state = 'patrol';
          off.currentPath.clear();
        }

        if (off.state == 'patrol') {
          if (hasLOS) {
            off.state = 'chase';
            off.bubbleText = '🚨 RUKO! STOP!';
            off.bubbleTimer = 2.5;
            off.currentPath = roadNetwork.findPath(off.x, off.y, playerPos.dx, playerPos.dy);
            off.waypointIndex = 0;
          } else {
            _patrolContinuous(off, deltaTime);
          }
        } else if (off.state == 'chase') {
          if (isPlayerSafe || distToPlayer > off.loseChaseRange) {
            off.state = 'lost';
            off.bubbleText = '❓ Lost him! Resuming patrol';
            off.bubbleTimer = 2.0;
            off.currentPath.clear();
          } else {
            if (math.Random().nextDouble() < 0.15 || off.currentPath.isEmpty) {
              off.currentPath = roadNetwork.findPath(off.x, off.y, playerPos.dx, playerPos.dy);
              off.waypointIndex = 0;
            }
            _followPath(off, off.chaseSpeed, deltaTime);

            if (!isPlayerSafe && distToPlayer < GameConfig.catchDistance) {
              triggerArrest(off);
              break;
            }
          }
        } else if (off.state == 'lost') {
          if (off.bubbleTimer <= 0) {
            off.state = 'patrol';
          } else {
            _patrolContinuous(off, deltaTime * 0.6);
          }
        }
      }
    }

    // 4. Update Collect Particles
    for (int i = collectParticles.length - 1; i >= 0; i--) {
      final p = collectParticles[i];
      p.x += p.vx * deltaTime;
      p.y += p.vy * deltaTime;
      p.life -= deltaTime;
      if (p.life <= 0) {
        collectParticles.removeAt(i);
      }
    }

    // 5. Update Confetti Particles
    if (isConfettiActive) {
      for (int i = confettiParticles.length - 1; i >= 0; i--) {
        final p = confettiParticles[i];
        p.life++;
        p.vx *= p.drag;
        p.vy = p.vy * p.drag + p.gravity;
        p.x += p.vx;
        p.y += p.vy;

        p.wobble += p.wobbleSpeed;
        p.x += math.sin(p.wobble) * p.wobbleAmp;

        p.rotX += p.spinX;
        p.rotY += p.spinY;
        p.rotZ += p.spinZ;

        if (p.life > 140) {
          p.opacity -= p.fadeSpeed * 2.5;
        }

        if (p.y > camera.viewportHeight + 60 || p.opacity <= 0) {
          confettiParticles.removeAt(i);
        }
      }
      if (confettiParticles.isEmpty) {
        isConfettiActive = false;
      }
    }

    // Update Camera
    camera.setFollow(playerPos);
    camera.update();

    notifyListeners();
  }

  void _patrolContinuous(PoliceOfficer off, double deltaTime) {
    if (off.currentPath.isEmpty || off.waypointIndex >= off.currentPath.length) {
      final curNode = roadNetwork.findClosestNode(off.x, off.y);
      if (curNode != null) {
        final neighbors = roadNetwork.edges[curNode.id] ?? [];
        if (neighbors.isNotEmpty) {
          final valid = neighbors.where((id) {
            final n = roadNetwork.nodes[id];
            return !n.isCenter && !n.isCenterAvenue;
          }).toList();
          final pool = valid.isNotEmpty ? valid : neighbors;
          final nextId = pool[math.Random().nextInt(pool.length)];
          final nextNode = roadNetwork.nodes[nextId];
          off.currentPath = [Offset(nextNode.x, nextNode.y)];
          off.waypointIndex = 0;
        }
      }
    }
    _followPath(off, off.speed, deltaTime);
  }

  void _followPath(PoliceOfficer off, double speed, double deltaTime) {
    if (off.currentPath.isEmpty || off.waypointIndex >= off.currentPath.length) return;
    final target = off.currentPath[off.waypointIndex];
    final dx = target.dx - off.x;
    final dy = target.dy - off.y;
    final dist = hypot(dx, dy);

    if (dist < 8) {
      off.waypointIndex++;
      if (off.waypointIndex >= off.currentPath.length) {
        off.currentPath.clear();
      }
    } else if (dist > 0) {
      off.angle = math.atan2(dy, dx);
      final step = math.min(dist, speed * deltaTime);
      off.x += (dx / dist) * step;
      off.y += (dy / dist) * step;
    }
  }

  bool isAnyPoliceChasing() {
    if (graceTimer > 0) return false;
    return officers.any((o) => o.state == 'chase');
  }

  double getClosestPoliceDistance() {
    double minDist = double.infinity;
    for (final o in officers) {
      final d = hypot(playerPos.dx - o.x, playerPos.dy - o.y);
      if (d < minDist) minDist = d;
    }
    return minDist;
  }

  void zoomIn() {
    camera.zoomBy(1.25);
    notifyListeners();
  }

  void zoomOut() {
    camera.zoomBy(0.8);
    notifyListeners();
  }

  void resetCamera() {
    camera.isDragging = false;
    camera.moveTo(playerPos.dx, playerPos.dy);
    camera.setFollow(playerPos);
    camera.setZoom(0.52);
    closeZoomDropdown();
    notifyListeners();
  }

}
