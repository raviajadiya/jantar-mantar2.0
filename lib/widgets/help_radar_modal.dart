import 'package:flutter/material.dart';
import '../engine/game_controller.dart';
import '../painters/minimap_painter.dart';

/// Modal dialog displaying interactive Radar Minimap and game objectives
class HelpRadarModal extends StatelessWidget {
  final GameController controller;
  final VoidCallback onClose;

  const HelpRadarModal({
    super.key,
    required this.controller,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 390,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xF70F172A),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.6),
            width: 1.8,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black87,
              blurRadius: 30,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  const Text('🗺️', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RADAR MAP & HELP',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'Radar Map & Objectives',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: onClose,
                    icon: const Text(
                      '✕',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(color: Color(0xFF334155), height: 1),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Live Interactive Radar Canvas
                  GestureDetector(
                    onTapUp: (details) {
                      const radarSize = 220.0;
                      final clickX = details.localPosition.dx;
                      final clickY = details.localPosition.dy;

                      final worldX = (clickX / radarSize) * controller.camera.worldWidth;
                      final worldY = (clickY / radarSize) * controller.camera.worldHeight;

                      controller.setDestination(worldX, worldY);
                    },
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                          width: 2.0,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black54,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: CustomPaint(
                        painter: MinimapPainter(
                          roadNetwork: controller.roadNetwork,
                          camera: controller.camera,
                          theme: controller.currentTheme,
                          playerPos: controller.playerPos,
                          officers: controller.officers,
                          flags: controller.flags,
                          animTime: controller.animTime,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),
                  const Text(
                    '★ Center: Jantar Mantar (Gandhi Cap)',
                    style: TextStyle(
                      color: Color(0xFFFBBF24),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Legend Chips
                  const Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _LegendChip(label: '🟢 You', color: Color(0xFF16A34A)),
                      _LegendChip(label: '🚨 Police', color: Color(0xFFEF4444)),
                      _LegendChip(label: '🚩 Flags', color: Color(0xFFF59E0B)),
                      _LegendChip(label: '🧢 Cap', color: Color(0xFF38BDF8)),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // 3-Step Guide
                  _buildGuideRow(
                    '1️⃣',
                    'Collect all Protest Flags while evading Delhi Police patrols.',
                  ),
                  const SizedBox(height: 8),
                  _buildGuideRow(
                    '2️⃣',
                    'After securing all flags, reach the center to claim the Gandhi Cap!',
                  ),
                  const SizedBox(height: 8),
                  _buildGuideRow(
                    '3️⃣',
                    'Tap roads to navigate, drag to pan camera, and avoid police vision cones.',
                  ),

                  const SizedBox(height: 16),

                  // Resume Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onClose,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF59E0B),
                        foregroundColor: const Color(0xFF0F172A),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        '✓ GOT IT (RESUME GAME)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideRow(String icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFFE2E8F0),
              fontSize: 11.5,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}

class _LegendChip extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
