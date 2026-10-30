import 'package:flutter/material.dart';
import '../engine/game_controller.dart';

/// Floating Bottom-Right Zoom control button and popup menu
class HudZoomWidget extends StatelessWidget {
  final GameController controller;
  final VoidCallback onOpenHeroCustomizer;

  const HudZoomWidget({
    super.key,
    required this.controller,
    required this.onOpenHeroCustomizer,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Dropdown menu panel (Opens upwards)
        if (controller.isZoomDropdownOpen) ...[
          Container(
            width: 140,
            decoration: BoxDecoration(
              color: const Color(0xFA0F172A),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.6),
                width: 1.5,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black87,
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDropdownItem('➕ Zoom In', controller.zoomIn),
                _buildDropdownDivider(),
                _buildDropdownItem('➖ Zoom Out', controller.zoomOut),
                _buildDropdownDivider(),
                _buildDropdownItem('⊙ Reset View', controller.resetCamera),
                _buildDropdownDivider(),
                _buildDropdownItem('⚙️ Settings', () {
                  controller.closeZoomDropdown();
                  onOpenHeroCustomizer();
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Floating Zoom Toggle Button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: controller.toggleZoomDropdown,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFA0F172A),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.7),
                  width: 1.8,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black87,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text('🔍', style: TextStyle(fontSize: 20)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownItem(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownDivider() {
    return Container(
      height: 1,
      color: Colors.white12,
    );
  }
}
