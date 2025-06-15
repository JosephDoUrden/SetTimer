import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/achievement_model.dart';

class AchievementNotificationWidget extends StatefulWidget {
  final Achievement achievement;
  final VoidCallback? onDismiss;

  const AchievementNotificationWidget({
    super.key,
    required this.achievement,
    this.onDismiss,
  });

  @override
  State<AchievementNotificationWidget> createState() => _AchievementNotificationWidgetState();
}

class _AchievementNotificationWidgetState extends State<AchievementNotificationWidget> with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: const Interval(0.5, 1.0),
    ));

    // Start animations
    _slideController.forward();
    _scaleController.forward();

    // Haptic feedback
    HapticFeedback.mediumImpact();

    // Auto-dismiss after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _dismiss() async {
    await _slideController.reverse();
    widget.onDismiss?.call();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_slideController, _scaleController]),
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: _buildNotificationCard(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 60, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.achievement.color.withOpacity(0.9),
            widget.achievement.color.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: widget.achievement.color.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Achievement icon with glow effect
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              widget.achievement.icon,
              size: 30,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          // Achievement text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      '🏆 Achievement Unlocked!',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    _buildTierBadge(),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.achievement.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.achievement.description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '+${AchievementDefinitions.getAchievementPoints(widget.achievement)} points',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Dismiss button
          GestureDetector(
            onTap: _dismiss,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.2),
              ),
              child: Icon(
                Icons.close,
                size: 16,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierBadge() {
    String tierText;
    Color tierColor;

    switch (widget.achievement.tier) {
      case AchievementTier.bronze:
        tierText = 'Bronze';
        tierColor = const Color(0xFFCD7F32);
        break;
      case AchievementTier.silver:
        tierText = 'Silver';
        tierColor = const Color(0xFFC0C0C0);
        break;
      case AchievementTier.gold:
        tierText = 'Gold';
        tierColor = const Color(0xFFFFD700);
        break;
      case AchievementTier.platinum:
        tierText = 'Platinum';
        tierColor = const Color(0xFFE5E4E2);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: tierColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Text(
        tierText.toUpperCase(),
        style: TextStyle(
          color: tierColor.computeLuminance() > 0.5 ? Colors.black87 : Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Overlay manager for showing achievement notifications
class AchievementNotificationOverlay {
  static OverlayEntry? _currentOverlay;

  static void show(BuildContext context, Achievement achievement) {
    // Remove existing overlay if present
    hide();

    _currentOverlay = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: AchievementNotificationWidget(
            achievement: achievement,
            onDismiss: hide,
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_currentOverlay!);
  }

  static void hide() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }
}
