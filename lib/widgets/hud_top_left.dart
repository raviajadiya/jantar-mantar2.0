import 'package:flutter/material.dart';
import '../constants/map_themes.dart';
import '../engine/game_controller.dart';

/// Top-left HUD controls (Help/Radar toggle and Theme switcher)
class HudTopLeft extends StatelessWidget {
  final GameController controller;

  const HudTopLeft({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16,
      left: 16,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Help Button
          _buildPillButton(
            icon: '❓',
            label: 'HELP',
            onTap: controller.toggleHelpModal,
          ),
          const SizedBox(width: 8),

          // Theme Switcher Button
          _buildPillButton(
            icon: controller.currentTheme.isDark ? '🌙' : '☀️',
            label: controller.currentTheme.isDark ? 'DARK' : 'LIGHT',
            onTap: () {
              final next = controller.currentTheme.isDark ? MapThemes.light : MapThemes.dark;
              controller.switchTheme(next);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPillButton({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xEB0F172A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(icon, style: const TextStyle(fontSize: 15)),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
