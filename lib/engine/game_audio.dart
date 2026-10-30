import 'package:flutter/services.dart';

/// Audio and Haptic feedback coordinator for mobile and desktop platforms
class GameAudio {
  static void playHover() {
    SystemSound.play(SystemSoundType.click);
  }

  static void playSelect() {
    HapticFeedback.selectionClick();
    SystemSound.play(SystemSoundType.click);
  }

  static void playDeploy() {
    HapticFeedback.mediumImpact();
  }

  static void playCollect() {
    HapticFeedback.lightImpact();
  }

  static void playPoliceSiren() {
    HapticFeedback.heavyImpact();
  }

  static void playBlastPop() {
    HapticFeedback.heavyImpact();
  }

  static void playFanfare() {
    HapticFeedback.mediumImpact();
  }
}
