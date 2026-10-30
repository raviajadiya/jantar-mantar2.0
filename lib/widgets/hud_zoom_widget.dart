import 'package:flutter/material.dart';
import '../engine/game_controller.dart';

/// Top-right Zoom control button and dropdown menu
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
    return Positioned(
      top: 16,
      right: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Zoom Toggle Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: controller.toggleZoomDropdown,
              borderRadius: BorderRadius.circular(22),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xEB0F172A),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.6),
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
                child: const Center(
                  child: Text('🔍', style: TextStyle(fontSize: 18)),
                ),
              ),
            ),
          ),

          // Dropdown menu panel
          if (controller.isZoomDropdownOpen) ...[
            const SizedBox(height: 8),
            Container(
              width: 140,
              decoration: BoxDecoration(
                color: const Color(0xFA0F172A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                  width: 1.2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black87,
                    blurRadius: 14,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDropdownItem(
                    text: '➕ Zoom In',
                    onTap: controller.zoomIn,
                  ),
                  _buildDropdownDivider(),
                  _buildDropdownItem(
                    text: '➖ Zoom Out',
                    onTap: controller.zoomOut,
                  ),
                  _buildDropdownDivider(),
                  _buildDropdownItem(
                    text: '⊙ Reset View',
                    onTap: controller.resetCamera,
                  ),
                  _buildDropdownDivider(),
                  _buildDropdownItem(
                    text: '👤 Hero',
                    onTap: () {
                      controller.closeZoomDropdown();
                      onOpenHeroCustomizer();
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDropdownItem({
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
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
