import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Audio coordinator with SharedPreferences persistence, smooth transitions, looping & App Lifecycle handling
class GameAudio with WidgetsBindingObserver {
  static final GameAudio _instance = GameAudio._();
  GameAudio._();

  static final AudioPlayer _bgmPlayer = AudioPlayer();
  static String? _currentBgm;
  static bool _isSoundEnabled = true;
  static bool _isInitialized = false;
  static bool _isAppPaused = false;

  static const String _prefSoundKey = 'is_sound_enabled';

  static bool get isSoundEnabled => _isSoundEnabled;

  static Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;
    AudioCache.instance.prefix = '';
    WidgetsBinding.instance.addObserver(_instance);

    try {
      final prefs = await SharedPreferences.getInstance();
      _isSoundEnabled = prefs.getBool(_prefSoundKey) ?? true;
    } catch (_) {}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      pauseBgm();
    } else if (state == AppLifecycleState.resumed) {
      resumeBgm();
    }
  }

  static Future<void> pauseBgm() async {
    _isAppPaused = true;
    try {
      if (_bgmPlayer.state == PlayerState.playing) {
        await _bgmPlayer.pause();
      }
    } catch (_) {}
  }

  static Future<void> resumeBgm() async {
    _isAppPaused = false;
    if (!_isSoundEnabled) return;
    try {
      if (_bgmPlayer.state == PlayerState.paused && _currentBgm != null) {
        await _bgmPlayer.resume();
      }
    } catch (_) {}
  }

  static Future<void> setSoundEnabled(bool enabled) async {
    _isSoundEnabled = enabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefSoundKey, enabled);
    } catch (_) {}

    if (!enabled) {
      await stopBgm();
    } else if (!_isAppPaused) {
      // Resume current BGM if sound turned on
      final lastBgm = _currentBgm;
      _currentBgm = null;
      if (lastBgm == 'home.mp3') {
        await playHomeBgm();
      } else if (lastBgm == 'gameplay.mp3') {
        await playGameplayBgm();
      } else if (lastBgm == 'game_over.mp3') {
        await playGameOverBgm();
      } else {
        await playHomeBgm();
      }
    }
  }

  static Future<void> playHomeBgm() async {
    await init();
    if (!_isSoundEnabled || _isAppPaused) return;
    if (_currentBgm == 'home.mp3' && _bgmPlayer.state == PlayerState.playing) return;
    await _smoothPlay('sound/home.mp3', 'home.mp3');
  }

  static Future<void> playGameplayBgm() async {
    await init();
    if (!_isSoundEnabled || _isAppPaused) return;
    if (_currentBgm == 'gameplay.mp3' && _bgmPlayer.state == PlayerState.playing) return;
    await _smoothPlay('sound/gameplay.mp3', 'gameplay.mp3');
  }

  static Future<void> playGameOverBgm() async {
    await init();
    if (!_isSoundEnabled || _isAppPaused) return;
    if (_currentBgm == 'game_over.mp3' && _bgmPlayer.state == PlayerState.playing) return;
    await _smoothPlay('sound/game_over.mp3', 'game_over.mp3');
  }

  static Future<void> playVictorySound() async {
    await init();
    if (!_isSoundEnabled) return;
    try {
      await stopBgm();
      playBlastPop();
      playFanfare();
    } catch (_) {}
  }

  static Future<void> playNextLevelSound() async {
    await init();
    if (!_isSoundEnabled) return;
    try {
      _currentBgm = 'next_lavel.mp3';
      await _bgmPlayer.stop();
      await _bgmPlayer.setReleaseMode(ReleaseMode.stop);
      await _bgmPlayer.setVolume(1.0);
      await _bgmPlayer.play(AssetSource('sound/next_lavel.mp3'));
      playBlastPop();
      playFanfare();
    } catch (_) {}
  }

  /// Smooth audio transition (fade out current -> play new -> fade in)
  static Future<void> _smoothPlay(String assetPath, String bgmKey) async {
    try {
      _currentBgm = bgmKey;

      // Smooth Fade Out if currently playing
      if (_bgmPlayer.state == PlayerState.playing) {
        for (double v = 1.0; v >= 0.0; v -= 0.25) {
          await _bgmPlayer.setVolume(v.clamp(0.0, 1.0));
          await Future.delayed(const Duration(milliseconds: 25));
        }
      }

      await _bgmPlayer.stop();
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer.setVolume(0.0);
      await _bgmPlayer.play(AssetSource(assetPath));

      // Smooth Fade In
      for (double v = 0.0; v <= 1.0; v += 0.2) {
        if (_currentBgm != bgmKey || !_isSoundEnabled || _isAppPaused) break;
        await _bgmPlayer.setVolume(v.clamp(0.0, 1.0));
        await Future.delayed(const Duration(milliseconds: 30));
      }
      if (_currentBgm == bgmKey && _isSoundEnabled && !_isAppPaused) {
        await _bgmPlayer.setVolume(1.0);
      }
    } catch (_) {}
  }

  static Future<void> stopBgm() async {
    try {
      if (_bgmPlayer.state == PlayerState.playing) {
        for (double v = 1.0; v >= 0.0; v -= 0.25) {
          await _bgmPlayer.setVolume(v.clamp(0.0, 1.0));
          await Future.delayed(const Duration(milliseconds: 20));
        }
      }
      await _bgmPlayer.stop();
    } catch (_) {}
  }

  // Sound effects & Haptics
  static void playHover() {
    if (_isSoundEnabled && !_isAppPaused) SystemSound.play(SystemSoundType.click);
  }

  static void playSelect() {
    if (!_isAppPaused) HapticFeedback.selectionClick();
    if (_isSoundEnabled && !_isAppPaused) SystemSound.play(SystemSoundType.click);
  }

  static void playDeploy() {
    if (!_isAppPaused) HapticFeedback.mediumImpact();
  }

  static void playCollect() {
    if (!_isAppPaused) HapticFeedback.lightImpact();
  }

  static void playPoliceSiren() {
    if (!_isAppPaused) HapticFeedback.heavyImpact();
  }

  static void playBlastPop() {
    if (!_isAppPaused) HapticFeedback.heavyImpact();
  }

  static void playFanfare() {
    if (!_isAppPaused) HapticFeedback.mediumImpact();
  }
}
