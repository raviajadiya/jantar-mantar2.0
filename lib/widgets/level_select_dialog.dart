import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../engine/game_controller.dart';
import '../engine/game_audio.dart';
import '../engine/level_storage_service.dart';

/// Modal Dialog displaying saved mission level progress and unlocked levels
class LevelSelectDialog extends StatefulWidget {
  final GameController controller;

  const LevelSelectDialog({
    super.key,
    required this.controller,
  });

  @override
  State<LevelSelectDialog> createState() => _LevelSelectDialogState();
}

class _LevelSelectDialogState extends State<LevelSelectDialog> {
  String? _lockedHint;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final dialogWidth = math.min(420.0, size.width * 0.92);
    final maxHeight = size.height * 0.84;

    final unlockedLevel = LevelStorageService.unlockedLevel;
    final completedCount = LevelStorageService.completedLevelsCount;
    final selectedLevel = widget.controller.currentLevel;

    // Show at least 12 tiles and always at least 4 upcoming locked levels, rounded to rows of 4
    final totalTiles = math.max(12, ((unlockedLevel + 4 + 3) ~/ 4) * 4);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: Container(
          width: dialogWidth,
          constraints: BoxConstraints(maxHeight: maxHeight),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: const Color(0xFB0F172A),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.7),
              width: 2.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black87,
                blurRadius: 30,
                offset: Offset(0, 10),
              ),
              BoxShadow(
                color: Color(0x33F59E0B),
                blurRadius: 20,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: const BoxDecoration(
                  color: Color(0xFF1E293B),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  border: Border(
                    bottom: BorderSide(color: Color(0xFF334155), width: 1.5),
                  ),
                ),
                child: Row(
                  children: [
                    const Text('🏆', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'MISSION LEVELS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$completedCount Completed • Current: Level $unlockedLevel',
                            style: const TextStyle(
                              color: Color(0xFFFBBF24),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        GameAudio.playSelect();
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8), size: 24),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Close',
                    ),
                  ],
                ),
              ),

              // Locked feedback banner if user tapped a locked level
              if (_lockedHint != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(18, 12, 18, 0),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7F1D1D).withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.7),
                    ),
                  ),
                  child: Text(
                    _lockedHint!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFFCA5A5),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

              // Scrollable Level Grid
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(18),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: totalTiles,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.80,
                    ),
                    itemBuilder: (context, index) {
                      final lvl = index + 1;
                      final isCompleted = lvl < unlockedLevel;
                      final isCurrentUnlocked = lvl == unlockedLevel;
                      final isSelected = lvl == selectedLevel;
                      final isLocked = lvl > unlockedLevel;

                      return _buildLevelTile(
                        level: lvl,
                        isCompleted: isCompleted,
                        isCurrentUnlocked: isCurrentUnlocked,
                        isSelected: isSelected,
                        isLocked: isLocked,
                      );
                    },
                  ),
                ),
              ),

              const Divider(color: Color(0xFF334155), height: 1, thickness: 1.2),

              // Bottom Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Tap any unlocked level to play',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        GameAudio.playSelect();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E293B),
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF475569), width: 1.2),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'CLOSE',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelTile({
    required int level,
    required bool isCompleted,
    required bool isCurrentUnlocked,
    required bool isSelected,
    required bool isLocked,
  }) {
    final flagCount = math.min<int>(64, 4 + level * 2);

    Color bgColor;
    Color borderColor;
    Color statusColor;
    String statusIcon;
    String statusLabel;

    if (isLocked) {
      bgColor = const Color(0xFF0F172A);
      borderColor = const Color(0xFF334155);
      statusColor = const Color(0xFF64748B);
      statusIcon = '🔒';
      statusLabel = 'LOCKED';
    } else if (isCompleted) {
      bgColor = const Color(0xFF052E16).withValues(alpha: 0.65);
      borderColor = isSelected ? const Color(0xFFF59E0B) : const Color(0xFF22C55E);
      statusColor = const Color(0xFF4ADE80);
      statusIcon = '✅';
      statusLabel = isSelected ? 'SELECTED' : 'DONE';
    } else {
      bgColor = const Color(0xFF451A03).withValues(alpha: 0.55);
      borderColor = const Color(0xFFF59E0B);
      statusColor = const Color(0xFFFBBF24);
      statusIcon = '⭐';
      statusLabel = isSelected ? 'ACTIVE' : 'PLAY';
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (isLocked) {
            GameAudio.playSelect();
            setState(() {
              _lockedHint = '🔒 Complete Level ${level - 1} first to unlock Level $level!';
            });
            return;
          }
          widget.controller.selectLevel(level);
          Navigator.of(context).pop();
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 2.2 : 1.4,
            ),
            boxShadow: isSelected || isCurrentUnlocked
                ? [
                    BoxShadow(
                      color: borderColor.withValues(alpha: 0.3),
                      blurRadius: 10,
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(statusIcon, style: const TextStyle(fontSize: 15)),
              const SizedBox(height: 2),
              Text(
                'L$level',
                style: TextStyle(
                  color: isLocked ? const Color(0xFF64748B) : Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                isLocked ? statusLabel : '🚩$flagCount • $statusLabel',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
