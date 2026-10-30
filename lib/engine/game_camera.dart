import 'dart:math' as math;
import 'dart:ui';
import '../constants/game_config.dart';

/// 2D Camera Engine with Smooth Pan, Zoom, Bounds Clamping and Coordinate Conversion
class GameCamera {
  double viewportWidth;
  double viewportHeight;
  double worldWidth;
  double worldHeight;

  double x = 1640.0;
  double y = 1640.0;
  double targetX = 1640.0;
  double targetY = 1640.0;

  double zoom = 0.52;
  double targetZoom = 0.52;
  final double minZoom = GameConfig.minZoom;
  final double maxZoom = GameConfig.maxZoom;

  Offset? followTarget;
  bool isDragging = false;
  final double lerpSpeed = 0.12;

  GameCamera({
    this.viewportWidth = 800.0,
    this.viewportHeight = 600.0,
    this.worldWidth = GameConfig.defaultWorldWidth,
    this.worldHeight = GameConfig.defaultWorldHeight,
  });

  void resize(double w, double h) {
    viewportWidth = w;
    viewportHeight = h;
  }

  void setWorldSize(double w, double h) {
    worldWidth = w;
    worldHeight = h;
  }

  void setFollow(Offset? target) {
    followTarget = target;
  }

  void clearFollow() {
    followTarget = null;
  }

  void moveTo(double worldX, double worldY, [bool instant = false]) {
    targetX = worldX;
    targetY = worldY;
    if (instant) {
      x = worldX;
      y = worldY;
    }
  }

  void setZoom(double zoomLevel) {
    targetZoom = math.max(minZoom, math.min(maxZoom, zoomLevel));
  }

  void zoomBy(double delta, [double? cursorX, double? cursorY]) {
    final cx = cursorX ?? viewportWidth / 2;
    final cy = cursorY ?? viewportHeight / 2;

    final worldPosBefore = screenToWorld(cx, cy);
    final newZoom = math.max(minZoom, math.min(maxZoom, targetZoom * delta));
    targetZoom = newZoom;
    zoom = newZoom;

    final worldPosAfter = screenToWorld(cx, cy);
    targetX += (worldPosBefore.dx - worldPosAfter.dx);
    targetY += (worldPosBefore.dy - worldPosAfter.dy);
    x = targetX;
    y = targetY;
  }

  void update() {
    if (followTarget != null && !isDragging) {
      targetX = followTarget!.dx;
      targetY = followTarget!.dy;
    }

    x += (targetX - x) * lerpSpeed;
    y += (targetY - y) * lerpSpeed;
    zoom += (targetZoom - zoom) * lerpSpeed;

    final halfVW = (viewportWidth / 2) / zoom;
    final halfVH = (viewportHeight / 2) / zoom;

    if (worldWidth > halfVW * 2) {
      x = math.max(halfVW, math.min(worldWidth - halfVW, x));
    } else {
      x = worldWidth / 2;
    }

    if (worldHeight > halfVH * 2) {
      y = math.max(halfVH, math.min(worldHeight - halfVH, y));
    } else {
      y = worldHeight / 2;
    }
  }

  Offset screenToWorld(double screenX, double screenY) {
    return Offset(
      (screenX - viewportWidth / 2) / zoom + x,
      (screenY - viewportHeight / 2) / zoom + y,
    );
  }

  Offset worldToScreen(double worldX, double worldY) {
    return Offset(
      (worldX - x) * zoom + viewportWidth / 2,
      (worldY - y) * zoom + viewportHeight / 2,
    );
  }

  Rect getVisibleBounds() {
    final halfVW = (viewportWidth / 2) / zoom;
    final halfVH = (viewportHeight / 2) / zoom;
    return Rect.fromLTRB(
      x - halfVW - 100,
      y - halfVH - 100,
      x + halfVW + 100,
      y + halfVH + 100,
    );
  }
}
