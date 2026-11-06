import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../firebase_config/firebase_analytics_service.dart';

/// Clean, modern Update Dialog supporting both Flexible and Force Updates for Jantar Mantar 2.0.
class AppUpdateDialog extends StatelessWidget {
  final String updatedBuildNo;
  final String currentBuildNo;
  final String? currentVersion;
  final bool isCancelable;
  final String storeLink;

  const AppUpdateDialog({
    super.key,
    required this.updatedBuildNo,
    required this.currentBuildNo,
    this.currentVersion,
    required this.isCancelable,
    required this.storeLink,
  });

  /// Helper to display the Update Dialog with entrance animation
  static Future<void> show(
    BuildContext context, {
    required String updatedBuildNo,
    required String currentBuildNo,
    String? currentVersion,
    required bool isCancelable,
    required String storeLink,
  }) {
    FirebaseAnalyticsService.instance.logUpdateDialogShown(
      updatedBuildNo: updatedBuildNo,
      currentBuildNo: currentBuildNo,
      isCancelable: isCancelable,
    );

    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: isCancelable,
      barrierLabel: isCancelable ? "Dismiss" : null,
      barrierColor: Colors.black.withValues(alpha: 0.80),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (context, animation, secondaryAnimation) {
        return AppUpdateDialog(
          updatedBuildNo: updatedBuildNo,
          currentBuildNo: currentBuildNo,
          currentVersion: currentVersion,
          isCancelable: isCancelable,
          storeLink: storeLink,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  Future<void> _launchStoreUrl(BuildContext context) async {
    FirebaseAnalyticsService.instance.logUpdateDialogAction(
      action: 'update_clicked',
      updatedBuildNo: updatedBuildNo,
    );

    if (storeLink.trim().isEmpty) return;

    final uri = Uri.tryParse(storeLink.trim());
    if (uri != null) {
      try {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } catch (e) {
        debugPrint("[AppUpdateDialog] Could not launch store url: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final dialogWidth = (size.width - 40).clamp(300.0, 380.0);

    return PopScope(
      canPop: isCancelable,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Center(
          child: SizedBox(
            width: dialogWidth,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                // Main Dialog Card
                Container(
                  margin: const EdgeInsets.only(top: 36),
                  padding: const EdgeInsets.fromLTRB(24, 46, 24, 22),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isCancelable
                          ? const Color(0xFFF59E0B).withValues(alpha: 0.8)
                          : const Color(0xFFEF4444).withValues(alpha: 0.8),
                      width: 1.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.6),
                        blurRadius: 32,
                        offset: const Offset(0, 12),
                      ),
                      BoxShadow(
                        color: (isCancelable
                                ? const Color(0xFFF59E0B)
                                : const Color(0xFFEF4444))
                            .withValues(alpha: 0.2),
                        blurRadius: 28,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Status Tag Pill
                      _buildTagPill(),

                      const SizedBox(height: 14),

                      // Headline
                      Text(
                        isCancelable ? "New Version Available" : "Update Required",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Description
                      Text(
                        isCancelable
                            ? "A new update is available with improved gameplay, fixes, and smoother performance. Update now for the best experience!"
                            : "An essential update is required to continue playing Jantar Mantar 2.0. Please update the app to proceed.",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 13.5,
                          height: 1.45,
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Version Information Card
                      _buildVersionPill(),

                      const SizedBox(height: 24),

                      // Action Buttons
                      _buildActionButtons(context),
                    ],
                  ),
                ),

                // Floating Icon at the top
                Positioned(
                  top: 0,
                  child: _buildTopIconBadge(),
                ),

                // Close Button (Only if cancelable)
                if (isCancelable)
                  Positioned(
                    top: 48,
                    right: 14,
                    child: _buildCloseButton(context),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopIconBadge() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isCancelable
              ? [
                  const Color(0xFFF59E0B),
                  const Color(0xFFD97706),
                ]
              : [
                  const Color(0xFFEF4444),
                  const Color(0xFFB91C1C),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: (isCancelable
                    ? const Color(0xFFF59E0B)
                    : const Color(0xFFEF4444))
                .withValues(alpha: 0.45),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF0F172A),
          width: 4,
        ),
      ),
      child: Icon(
        isCancelable ? Icons.system_update_rounded : Icons.priority_high_rounded,
        size: 34,
        color: Colors.white,
      ),
    );
  }

  Widget _buildTagPill() {
    final color = isCancelable ? const Color(0xFFF59E0B) : const Color(0xFFEF4444);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isCancelable ? "RECOMMENDED UPDATE" : "MANDATORY UPDATE",
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF334155),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "CURRENT",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                currentVersion != null && currentVersion!.isNotEmpty
                    ? "v$currentVersion ($currentBuildNo)"
                    : "Build $currentBuildNo",
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Icon(
              Icons.arrow_forward_rounded,
              size: 16,
              color: Color(0xFFF59E0B),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "LATEST",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "Build $updatedBuildNo",
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Primary Update Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () => _launchStoreUrl(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: const Color(0xFF0F172A),
              elevation: 3,
              shadowColor: const Color(0xFFF59E0B).withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.download_rounded, size: 20),
                SizedBox(width: 8),
                Text(
                  "UPDATE NOW",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Optional Dismiss Button
        if (isCancelable) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: TextButton(
              onPressed: () {
                FirebaseAnalyticsService.instance.logUpdateDialogAction(
                  action: 'dismiss_later',
                  updatedBuildNo: updatedBuildNo,
                );
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF94A3B8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                "MAYBE LATER",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          FirebaseAnalyticsService.instance.logUpdateDialogAction(
            action: 'close_button',
            updatedBuildNo: updatedBuildNo,
          );
          Navigator.of(context).pop();
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF1E293B).withValues(alpha: 0.9),
            border: Border.all(
              color: const Color(0xFF334155),
              width: 1,
            ),
          ),
          child: const Icon(
            Icons.close_rounded,
            size: 18,
            color: Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }
}

