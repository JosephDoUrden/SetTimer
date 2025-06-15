import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../controllers/timer_controller.dart';
import '../models/timer_model.dart';
import '../services/achievement_service.dart';
import '../widgets/save_template_dialog.dart';
import '../widgets/achievement_notification_widget.dart';
import 'preset_selection_view.dart';
import 'audio_settings_view.dart';
import 'voice_coaching_settings_view.dart';
import 'workout_history_view.dart';
import 'about_view.dart';

class TimerView extends StatefulWidget {
  const TimerView({super.key});

  @override
  State<TimerView> createState() => _TimerViewState();
}

class _TimerViewState extends State<TimerView> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;
  final AchievementService _achievementService = AchievementService();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.elasticOut,
    ));

    _pulseController.repeat(reverse: true);
    _progressController.forward();

    // Listen for achievement unlocks
    _achievementService.achievementUnlocked.listen((achievement) {
      if (mounted) {
        AchievementNotificationOverlay.show(context, achievement);
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  // Helper method to get responsive sizing
  double _getResponsiveSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / 375; // Base iPhone width
    return baseSize * scaleFactor.clamp(0.8, 1.5);
  }

  bool _isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.height < 700;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      resizeToAvoidBottomInset: false,
      body: Consumer<TimerController>(
        builder: (context, controller, child) {
          final timer = controller.timer;

          // Show completion message
          if (timer.state == TimerState.completed) {
            return _buildCompletionScreen(controller);
          }

          final screenSize = MediaQuery.of(context).size;
          final isSmallScreen = screenSize.height < 700 || screenSize.width < 400;
          final isVerySmallScreen = screenSize.height < 600 || screenSize.width < 350;

          // Responsive spacing
          final headerSpacing = isVerySmallScreen
              ? 16.0
              : isSmallScreen
                  ? 20.0
                  : 30.0;
          final progressSpacing = isVerySmallScreen
              ? 20.0
              : isSmallScreen
                  ? 30.0
                  : 50.0;
          final bottomSpacing = isVerySmallScreen
              ? 20.0
              : isSmallScreen
                  ? 30.0
                  : 50.0;
          final endSpacing = isVerySmallScreen
              ? 16.0
              : isSmallScreen
                  ? 20.0
                  : 30.0;
          final sidePadding = isVerySmallScreen ? 16.0 : 20.0;

          return Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  Color(0xFF1A1A1A),
                  Color(0xFF0A0A0A),
                  Color(0xFF050505),
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: sidePadding, vertical: 12.0),
                child: Column(
                  children: [
                    // Header with settings
                    _buildHeader(controller),

                    SizedBox(height: headerSpacing * 0.8),

                    // Progress section with animation
                    AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: _buildProgressSection(timer),
                        );
                      },
                    ),

                    SizedBox(height: progressSpacing * 0.8),

                    // Main timer circle - use Expanded to prevent overflow
                    Expanded(
                      child: Center(
                        child: _buildAnimatedTimerCircle(timer),
                      ),
                    ),

                    SizedBox(height: bottomSpacing * 0.7),

                    // Enhanced control buttons
                    _buildEnhancedControlButtons(controller, timer),

                    SizedBox(height: endSpacing * 0.8),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(TimerController controller) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isVerySmallScreen = screenWidth < 360;
    final isSmallScreen = screenWidth < 400;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          // Modern app branding - cleaner design
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.08),
                    Colors.white.withOpacity(0.03),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // App icon with modern glow
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00D4AA), Color(0xFF00B4AA)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00D4AA).withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.timer_outlined,
                      color: Colors.white,
                      size: isVerySmallScreen ? 16 : 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // App title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'SetTimer',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: isVerySmallScreen ? 16 : 18,
                            color: Colors.white,
                            letterSpacing: 0.2,
                            height: 1.0,
                          ),
                        ),
                        if (!isVerySmallScreen) ...[
                          const SizedBox(height: 2),
                          Consumer<TimerController>(
                            builder: (context, controller, child) {
                              final presetName = controller.currentPresetName;
                              return Text(
                                presetName ?? 'by Yusufhan Saçak',
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 11,
                                  color: presetName != null ? const Color(0xFF00D4AA).withOpacity(0.8) : Colors.white.withOpacity(0.6),
                                  letterSpacing: 0.1,
                                  height: 1.0,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Streak indicator integrated in header - subtle
                  _buildCompactStreakBadge(controller),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Action buttons with better spacing
          _buildHeaderActionButtons(controller, isVerySmallScreen, isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildCompactStreakBadge(TimerController controller) {
    return FutureBuilder<int>(
      future: controller.sessionService.getWorkoutStreak(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data! <= 1) {
          return const SizedBox.shrink();
        }

        final streak = snapshot.data!;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFFF6B35).withOpacity(0.3),
                const Color(0xFFFF8E53).withOpacity(0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFFF6B35).withOpacity(0.4),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '🔥',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(width: 4),
              Text(
                '$streak',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderActionButtons(TimerController controller, bool isVerySmallScreen, bool isSmallScreen) {
    final buttonSize = isVerySmallScreen ? 40.0 : 44.0;
    final buttonSpacing = isVerySmallScreen ? 8.0 : 10.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Quick access - Presets
        _buildModernHeaderButton(
          icon: Icons.library_books_outlined,
          color: Colors.white.withOpacity(0.06),
          iconColor: Colors.white.withOpacity(0.8),
          size: buttonSize,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PresetSelectionView(),
            ),
          ),
        ),
        SizedBox(width: buttonSpacing),

        // History
        _buildModernHeaderButton(
          icon: Icons.analytics_outlined,
          color: const Color(0xFF2196F3).withOpacity(0.12),
          iconColor: const Color(0xFF2196F3),
          size: buttonSize,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const WorkoutHistoryView(),
            ),
          ),
        ),
        SizedBox(width: buttonSpacing),

        // More options menu - consolidated for clean look
        _buildModernHeaderButton(
          icon: Icons.tune_rounded,
          color: const Color(0xFF00D4AA).withOpacity(0.12),
          iconColor: const Color(0xFF00D4AA),
          size: buttonSize,
          onPressed: () => _showQuickActionsMenu(context, controller),
          isHighlighted: true,
        ),
      ],
    );
  }

  Widget _buildModernHeaderButton({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required double size,
    required VoidCallback onPressed,
    bool isHighlighted = false,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isHighlighted ? const Color(0xFF00D4AA).withOpacity(0.3) : Colors.white.withOpacity(0.12),
          width: 1,
        ),
        boxShadow: [
          if (isHighlighted)
            BoxShadow(
              color: const Color(0xFF00D4AA).withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          else
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onPressed,
          child: Icon(
            icon,
            color: iconColor,
            size: size * 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionScreen(TimerController controller) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [
            Color(0xFF1A4A1A),
            Color(0xFF0A2A0A),
            Color(0xFF050A05),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated completion icon
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [Color(0xFF00FF88), Color(0xFF00CC66)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00FF88).withOpacity(0.5),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 40),

            const Text(
              'Workout Complete!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'Great job! You completed all sets.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 24),

            // Streak celebration
            _buildStreakCelebration(controller),

            const SizedBox(height: 40),

            // Enhanced action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.history,
                  label: 'View History',
                  color: const Color(0xFF2196F3),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WorkoutHistoryView(),
                    ),
                  ),
                ),
                _buildActionButton(
                  icon: Icons.settings,
                  label: 'Settings',
                  color: Colors.white30,
                  onPressed: () => _showSettingsModal(context, controller),
                ),
                _buildActionButton(
                  icon: Icons.refresh,
                  label: 'New Workout',
                  color: const Color(0xFF00D4AA),
                  onPressed: controller.resetTimer,
                  isPrimary: true,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Developer credit
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutView()),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.favorite,
                      size: 14,
                      color: Colors.red.withOpacity(0.8),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Made by Yusufhan Saçak',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.touch_app,
                      size: 12,
                      color: Colors.white.withOpacity(0.4),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(isPrimary ? 1.0 : 0.3),
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ]
                : null,
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(TimerModel timer) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.height < 700 || screenSize.width < 400;
    final primaryColor = timer.isInRestPeriod ? const Color(0xFFFF6B35) : const Color(0xFF00D4AA);

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.06),
            Colors.white.withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Modern set counter
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSetCounterBadge(
                value: timer.currentSet,
                color: primaryColor,
                isActive: true,
                isSmallScreen: isSmallScreen,
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white.withOpacity(0.1),
                ),
                child: Text(
                  'of',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: isSmallScreen ? 13 : 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _buildSetCounterBadge(
                value: timer.totalSets,
                color: Colors.white.withOpacity(0.8),
                isActive: false,
                isSmallScreen: isSmallScreen,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Modern progress bar with better styling
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Workout Progress',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: primaryColor.withOpacity(0.15),
                      border: Border.all(
                        color: primaryColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${(timer.progress * 100).toInt()}%',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.08),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: timer.progress,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSetCounterBadge({
    required int value,
    required Color color,
    required bool isActive,
    required bool isSmallScreen,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 16,
        vertical: isSmallScreen ? 8 : 10,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isActive
            ? LinearGradient(
                colors: [
                  color.withOpacity(0.2),
                  color.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.08),
                  Colors.white.withOpacity(0.04),
                ],
              ),
        border: Border.all(
          color: isActive ? color.withOpacity(0.4) : Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Text(
        '$value',
        style: TextStyle(
          color: color,
          fontSize: isSmallScreen ? 18 : 22,
          fontWeight: FontWeight.w700,
          height: 1.0,
        ),
      ),
    );
  }

  Widget _buildAnimatedTimerCircle(TimerModel timer) {
    final isRest = timer.isInRestPeriod;
    final primaryColor = isRest ? const Color(0xFFFF6B35) : const Color(0xFF00D4AA);
    final isRunning = timer.state == TimerState.running || timer.state == TimerState.resting;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenSize = MediaQuery.of(context).size;
        final isSmallScreen = screenSize.height < 700 || screenSize.width < 400;
        final isVerySmallScreen = screenSize.height < 600 || screenSize.width < 350;

        // Calculate optimal circle size based on available space and screen characteristics
        final availableWidth = constraints.maxWidth;
        final availableHeight = constraints.maxHeight;
        final minDimension = availableWidth < availableHeight ? availableWidth : availableHeight;

        // Calculate max allowed size first
        final maxAllowedSize = minDimension * 0.9;
        const absoluteMinSize = 80.0; // Reduced absolute minimum

        // Ensure we have a valid range for clamping
        final effectiveMinSize = absoluteMinSize > maxAllowedSize ? maxAllowedSize * 0.8 : absoluteMinSize;

        // More conservative sizing to prevent overflow
        double circleSize;
        if (isVerySmallScreen) {
          circleSize = (minDimension * 0.7);
        } else if (isSmallScreen) {
          circleSize = (minDimension * 0.75);
        } else {
          circleSize = (minDimension * 0.8);
        }

        // Apply safe clamping with valid min/max range
        circleSize = circleSize.clamp(effectiveMinSize, maxAllowedSize);

        // Calculate progress
        final totalDuration = timer.isInRestPeriod ? timer.restDurationSeconds : timer.setDurationSeconds;
        final elapsed = totalDuration - timer.remainingSeconds;
        final progressValue = totalDuration > 0 ? elapsed / totalDuration : 0.0;

        // Responsive font sizes based on circle size
        final timerFontSize = (circleSize * 0.15).clamp(32.0, 52.0);
        final phaseFontSize = (circleSize * 0.05).clamp(11.0, 16.0);
        final percentageFontSize = (circleSize * 0.055).clamp(12.0, 18.0);

        return Center(
          child: AnimatedBuilder(
            animation: isRunning ? _pulseAnimation : _progressController,
            builder: (context, child) {
              return Transform.scale(
                scale: isRunning ? _pulseAnimation.value : 1.0,
                child: SizedBox(
                  width: circleSize,
                  height: circleSize,
                  child: Stack(
                    children: [
                      // Outer glow effect
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                primaryColor.withOpacity(0.2),
                                primaryColor.withOpacity(0.1),
                                primaryColor.withOpacity(0.05),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.3, 0.6, 1.0],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.4),
                                blurRadius: circleSize * 0.12,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Background circle
                      Positioned.fill(
                        child: Container(
                          margin: EdgeInsets.all(circleSize * 0.05),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.black.withOpacity(0.6),
                                Colors.black.withOpacity(0.8),
                              ],
                            ),
                            border: Border.all(
                              color: primaryColor.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                      // Progress ring
                      Positioned.fill(
                        child: Padding(
                          padding: EdgeInsets.all(circleSize * 0.05),
                          child: CircularProgressIndicator(
                            value: progressValue,
                            strokeWidth: (circleSize * 0.025).clamp(4.0, 8.0),
                            backgroundColor: Colors.white.withOpacity(0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                      ),

                      // Inner content
                      Positioned.fill(
                        child: Container(
                          margin: EdgeInsets.all(circleSize * 0.15),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Phase indicator
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: circleSize * 0.08,
                                  vertical: circleSize * 0.025,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    colors: [
                                      primaryColor,
                                      primaryColor.withOpacity(0.8),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withOpacity(0.5),
                                      blurRadius: 12,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  timer.isInRestPeriod ? 'REST' : 'WORK',
                                  style: TextStyle(
                                    fontSize: phaseFontSize,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),

                              SizedBox(height: circleSize * 0.08),

                              // Time display
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: circleSize * 0.06,
                                  vertical: circleSize * 0.03,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.black.withOpacity(0.5),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  _formatTime(timer.remainingSeconds),
                                  style: TextStyle(
                                    fontSize: timerFontSize,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.white,
                                    height: 1.0,
                                    fontFeatures: const [FontFeature.tabularFigures()],
                                  ),
                                ),
                              ),

                              SizedBox(height: circleSize * 0.05),

                              // Progress percentage
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: circleSize * 0.04,
                                  vertical: circleSize * 0.015,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: primaryColor.withOpacity(0.2),
                                ),
                                child: Text(
                                  '${(progressValue * 100).toInt()}%',
                                  style: TextStyle(
                                    fontSize: percentageFontSize,
                                    fontWeight: FontWeight.w600,
                                    color: primaryColor,
                                  ),
                                ),
                              ),

                              // State indicator (only show if not idle)
                              if (timer.state != TimerState.idle) ...[
                                SizedBox(height: circleSize * 0.03),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: circleSize * 0.04,
                                    vertical: circleSize * 0.01,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                  child: Text(
                                    _getStateText(timer.state),
                                    style: TextStyle(
                                      fontSize: (circleSize * 0.035).clamp(9.0, 11.0),
                                      color: Colors.white.withOpacity(0.7),
                                      letterSpacing: 0.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEnhancedControlButtons(TimerController controller, TimerModel timer) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.height < 700 || screenSize.width < 400;
    final isVerySmallScreen = screenSize.height < 600 || screenSize.width < 350;

    // Responsive button sizes
    final mainButtonSize = isVerySmallScreen
        ? 64.0
        : isSmallScreen
            ? 72.0
            : 80.0;
    final sideButtonSize = isVerySmallScreen
        ? 48.0
        : isSmallScreen
            ? 56.0
            : 64.0;
    final containerPadding = isVerySmallScreen
        ? 12.0
        : isSmallScreen
            ? 16.0
            : 20.0;

    return Container(
      padding: EdgeInsets.all(containerPadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Reset button
          _buildControlButton(
            icon: Icons.refresh_rounded,
            onPressed: controller.resetTimer,
            color: Colors.white.withOpacity(0.2),
            size: sideButtonSize,
            label: 'Reset',
            isEnabled: timer.state != TimerState.idle,
            isSmallScreen: isVerySmallScreen,
          ),

          // Main play/pause button
          _buildControlButton(
            icon: timer.state == TimerState.running || timer.state == TimerState.resting ? Icons.pause_rounded : Icons.play_arrow_rounded,
            onPressed:
                timer.state == TimerState.running || timer.state == TimerState.resting ? controller.pauseTimer : controller.startTimer,
            color: timer.isInRestPeriod ? const Color(0xFFFF6B35) : const Color(0xFF00D4AA),
            size: mainButtonSize,
            isMain: true,
            label: timer.state == TimerState.running || timer.state == TimerState.resting ? 'Pause' : 'Start',
            isEnabled: true,
            isSmallScreen: isVerySmallScreen,
          ),

          // Settings button
          _buildControlButton(
            icon: Icons.tune_rounded,
            onPressed: () => _showSettingsModal(context, controller),
            color: Colors.white.withOpacity(0.2),
            size: sideButtonSize,
            label: 'Settings',
            isEnabled: timer.state == TimerState.idle || timer.state == TimerState.paused,
            isSmallScreen: isVerySmallScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
    required double size,
    required String label,
    bool isMain = false,
    bool isEnabled = true,
    bool isSmallScreen = false,
  }) {
    final buttonColor = isEnabled ? color : Colors.grey.withOpacity(0.3);
    final iconColor = isEnabled ? Colors.white : Colors.white.withOpacity(0.5);
    final labelFontSize = isSmallScreen ? 10.0 : 12.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isMain && isEnabled
                ? RadialGradient(
                    colors: [
                      buttonColor,
                      buttonColor.withOpacity(0.8),
                    ],
                  )
                : null,
            color: isMain ? null : buttonColor,
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: isMain ? buttonColor.withOpacity(0.5) : Colors.black.withOpacity(0.3),
                      blurRadius: isMain ? 20 : 10,
                      spreadRadius: isMain ? 2 : 1,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(size / 2),
              onTap: isEnabled ? onPressed : null,
              child: Icon(
                icon,
                color: iconColor,
                size: size * (isMain ? 0.45 : 0.4),
              ),
            ),
          ),
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),
        Text(
          label,
          style: TextStyle(
            color: isEnabled ? Colors.white.withOpacity(0.8) : Colors.white.withOpacity(0.4),
            fontSize: labelFontSize,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _getStateText(TimerState state) {
    switch (state) {
      case TimerState.running:
        return 'RUNNING';
      case TimerState.paused:
        return 'PAUSED';
      case TimerState.resting:
        return 'RESTING';
      case TimerState.completed:
        return 'COMPLETED';
      default:
        return '';
    }
  }

  void _showSettingsModal(BuildContext context, TimerController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _SettingsModal(controller: controller),
      ),
    );
  }

  void _showSaveTemplateDialog(TimerController controller) {
    showDialog(
      context: context,
      builder: (context) => SaveTemplateDialog(
        currentSettings: controller.getCurrentSettingsAsPreset(
          name: '',
          description: '',
        ),
        onSaved: () {
          // Optionally refresh presets or show a success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Template saved successfully!'),
              backgroundColor: Color(0xFF00D4AA),
              duration: Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  void _showQuickActionsMenu(BuildContext context, TimerController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Modern handle bar
            Container(
              width: 36,
              height: 3,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Header with modern styling
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF00D4AA).withOpacity(0.2),
                        const Color(0xFF00D4AA).withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    color: Color(0xFF00D4AA),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Modern menu items
            _buildMenuOption(
              icon: Icons.volume_up_outlined,
              title: 'Audio Settings',
              subtitle: 'Sounds & notifications',
              color: const Color(0xFF9C27B0),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AudioSettingsView(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            _buildMenuOption(
              icon: Icons.record_voice_over_outlined,
              title: 'Voice Coaching',
              subtitle: 'Voice guidance & prompts',
              color: const Color(0xFF9C27B0),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VoiceCoachingSettingsView(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            _buildMenuOption(
              icon: Icons.bookmark_add_outlined,
              title: 'Save Template',
              subtitle: 'Save current settings as preset',
              color: const Color(0xFF00D4AA),
              onTap: () {
                Navigator.pop(context);
                _showSaveTemplateDialog(controller);
              },
            ),

            const SizedBox(height: 12),

            _buildMenuOption(
              icon: Icons.settings_outlined,
              title: 'Timer Settings',
              subtitle: 'Configure sets, duration & rest',
              color: const Color(0xFF2196F3),
              onTap: () {
                Navigator.pop(context);
                _showSettingsModal(context, controller);
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.05),
            Colors.white.withOpacity(0.02),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white.withOpacity(0.3),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMoreOptionsMenu(BuildContext context, TimerController controller) {
    _showQuickActionsMenu(context, controller);
  }

  void _showSettingsDialog(TimerController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _SettingsModal(controller: controller),
      isScrollControlled: true,
    );
  }

  Widget _buildStreakCelebration(TimerController controller) {
    return FutureBuilder<int>(
      future: controller.sessionService.getWorkoutStreak(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data! <= 1) {
          return const SizedBox.shrink();
        }

        final streak = snapshot.data!;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                const Color(0xFFFF6B35).withOpacity(0.2),
                const Color(0xFFFF8E53).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFFF6B35).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '🔥',
                    style: TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$streak Day Streak!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (streak >= 7) ...[
                    const SizedBox(width: 8),
                    const Text(
                      '🏆',
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _getStreakMessage(streak),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  String _getStreakMessage(int streak) {
    if (streak < 3) {
      return 'Keep it up! You\'re building a great habit.';
    } else if (streak < 7) {
      return 'Amazing consistency! Don\'t break the chain.';
    } else if (streak < 14) {
      return 'You\'re on fire! This is becoming a lifestyle.';
    } else if (streak < 30) {
      return 'Incredible dedication! You\'re unstoppable.';
    } else {
      return 'Legendary streak! You\'re an inspiration to others.';
    }
  }
}

class _SettingsModal extends StatefulWidget {
  final TimerController controller;

  const _SettingsModal({required this.controller});

  @override
  State<_SettingsModal> createState() => _SettingsModalState();
}

class _SettingsModalState extends State<_SettingsModal> {
  late int _totalSets;
  late int _setDuration;
  late int _restDuration;
  late int _restAfterSets;

  @override
  void initState() {
    super.initState();
    final timer = widget.controller.timer;
    _totalSets = timer.totalSets;
    _setDuration = timer.setDurationSeconds;
    _restDuration = timer.restDurationSeconds;
    _restAfterSets = timer.restAfterSets;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white30,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Timer Settings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 30),

          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildSlider('Total Sets', _totalSets, 1, 20, (value) {
                    setState(() => _totalSets = value.round());
                  }, context),
                  _buildSlider('Set Duration (seconds)', _setDuration, 10, 300, (value) {
                    setState(() => _setDuration = value.round());
                  }, context),
                  _buildSlider('Rest Duration (seconds)', _restDuration, 5, 120, (value) {
                    setState(() => _restDuration = value.round());
                  }, context),
                  _buildSlider('Rest After Sets', _restAfterSets, 1, 5, (value) {
                    setState(() => _restAfterSets = value.round());
                  }, context),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white30,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    widget.controller.updateTimerSettings(
                      totalSets: _totalSets,
                      setDurationSeconds: _setDuration,
                      restDurationSeconds: _restDuration,
                      restAfterSets: _restAfterSets,
                    );
                    Navigator.pop(context);

                    // Show confirmation
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Settings updated successfully!'),
                        backgroundColor: Color(0xFF00D4AA),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D4AA),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Apply Settings',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // About button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutView()),
                );
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.white.withOpacity(0.7),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'About the App',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSlider(String label, int value, int min, int max, ValueChanged<double> onChanged, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value.toString(),
                style: const TextStyle(
                  color: Color(0xFF00D4AA),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF00D4AA),
              inactiveTrackColor: Colors.white.withOpacity(0.2),
              thumbColor: const Color(0xFF00D4AA),
              overlayColor: const Color(0xFF00D4AA).withOpacity(0.2),
              trackHeight: 4,
            ),
            child: Slider(
              value: value.toDouble(),
              min: min.toDouble(),
              max: max.toDouble(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
