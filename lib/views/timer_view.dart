import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../controllers/timer_controller.dart';
import '../models/timer_model.dart';
import 'preset_selection_view.dart';

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
      body: Consumer<TimerController>(
        builder: (context, controller, child) {
          final timer = controller.timer;

          // Show completion message
          if (timer.state == TimerState.completed) {
            return _buildCompletionScreen(controller);
          }

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
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Header with settings
                    _buildHeader(controller),

                    const SizedBox(height: 30),

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

                    const SizedBox(height: 50),

                    // Main timer circle
                    Expanded(
                      child: Center(
                        child: _buildAnimatedTimerCircle(timer),
                      ),
                    ),

                    const SizedBox(height: 50),

                    // Enhanced control buttons
                    _buildEnhancedControlButtons(controller, timer),

                    const SizedBox(height: 30),
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
    final buttonSize = _getResponsiveSize(context, 48);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // App title with glow effect
        Container(
          padding: EdgeInsets.symmetric(horizontal: _getResponsiveSize(context, 16), vertical: _getResponsiveSize(context, 8)),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00D4AA), Color(0xFF00B4AA)],
            ),
            borderRadius: BorderRadius.circular(_getResponsiveSize(context, 20)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00D4AA).withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Text(
            'Workout Set Timer',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: _getResponsiveSize(context, 16),
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
        ),

        // Action buttons
        Row(
          children: [
            // Presets button
            Container(
              width: buttonSize,
              height: buttonSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PresetSelectionView(),
                  ),
                ),
                icon: Icon(
                  Icons.library_books,
                  color: Colors.white70,
                  size: _getResponsiveSize(context, 24),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Settings button with enhanced design
            Container(
              width: buttonSize,
              height: buttonSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: IconButton(
                onPressed: () => _showSettingsModal(context, controller),
                icon: Icon(
                  Icons.tune,
                  color: Colors.white70,
                  size: _getResponsiveSize(context, 24),
                ),
              ),
            ),
          ],
        ),
      ],
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

            const SizedBox(height: 50),

            // Enhanced action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Set counter with enhanced styling
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: (timer.isInRestPeriod ? const Color(0xFFFF6B35) : const Color(0xFF00D4AA)).withOpacity(0.2),
                ),
                child: Text(
                  '${timer.currentSet}',
                  style: TextStyle(
                    color: timer.isInRestPeriod ? const Color(0xFFFF6B35) : const Color(0xFF00D4AA),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'of',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${timer.totalSets}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Enhanced progress bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.white.withOpacity(0.1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: timer.progress,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  timer.isInRestPeriod ? const Color(0xFFFF6B35) : const Color(0xFF00D4AA),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedTimerCircle(TimerModel timer) {
    final isRest = timer.isInRestPeriod;
    final primaryColor = isRest ? const Color(0xFFFF6B35) : const Color(0xFF00D4AA);
    final isRunning = timer.state == TimerState.running || timer.state == TimerState.resting;

    // Calculate responsive circle size based on screen constraints
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Use LayoutBuilder to get the actual available space in the parent Expanded widget
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate the maximum possible size while maintaining a circular shape
        final maxSize = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth * 0.9 // 90% of available width
            : constraints.maxHeight * 0.9; // 90% of available height

        // Apply minimum and maximum constraints to avoid too small or too large circles
        final circleSize = maxSize.clamp(240.0, 320.0);

        return AnimatedBuilder(
          animation: isRunning ? _pulseAnimation : _progressController,
          builder: (context, child) {
            return Transform.scale(
              scale: isRunning ? _pulseAnimation.value : 1.0,
              child: Container(
                width: circleSize,
                height: circleSize, // Equal height and width for perfect circle
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      primaryColor.withOpacity(0.15),
                      primaryColor.withOpacity(0.05),
                      Colors.transparent,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Outer ring
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
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
                        padding: const EdgeInsets.all(10),
                        child: CircularProgressIndicator(
                          value: timer.isInRestPeriod
                              ? (timer.restDurationSeconds - timer.remainingSeconds) / timer.restDurationSeconds
                              : (timer.setDurationSeconds - timer.remainingSeconds) / timer.setDurationSeconds,
                          strokeWidth: 12,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                    ),

                    // Center content
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Phase indicator with glow
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: primaryColor.withOpacity(0.2),
                              border: Border.all(
                                color: primaryColor.withOpacity(0.6),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.4),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Text(
                              timer.isInRestPeriod ? 'REST' : 'WORK',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                                letterSpacing: 2,
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Time display with enhanced styling
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.black.withOpacity(0.3),
                            ),
                            child: Text(
                              _formatTime(timer.remainingSeconds),
                              style: const TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.w200,
                                color: Colors.white,
                                height: 1,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // State indicator
                          if (timer.state != TimerState.idle)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white.withOpacity(0.1),
                              ),
                              child: Text(
                                _getStateText(timer.state),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.8),
                                  letterSpacing: 1,
                                  fontWeight: FontWeight.w500,
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
          },
        );
      },
    );
  }

  Widget _buildEnhancedControlButtons(TimerController controller, TimerModel timer) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Reset button
          _buildControlButton(
            icon: Icons.refresh,
            onPressed: controller.resetTimer,
            color: Colors.white.withOpacity(0.3),
            size: 60,
            label: 'Reset',
          ),

          // Main play/pause button
          _buildControlButton(
            icon: timer.state == TimerState.running || timer.state == TimerState.resting ? Icons.pause : Icons.play_arrow,
            onPressed:
                timer.state == TimerState.running || timer.state == TimerState.resting ? controller.pauseTimer : controller.startTimer,
            color: timer.isInRestPeriod ? const Color(0xFFFF6B35) : const Color(0xFF00D4AA),
            size: 80,
            isMain: true,
            label: timer.state == TimerState.running || timer.state == TimerState.resting ? 'Pause' : 'Start',
          ),

          // Settings button
          _buildControlButton(
            icon: Icons.tune,
            onPressed: () => _showSettingsModal(context, controller),
            color: Colors.white.withOpacity(0.3),
            size: 60,
            label: 'Settings',
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
  }) {
    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isMain
                ? RadialGradient(
                    colors: [
                      color,
                      color.withOpacity(0.8),
                    ],
                  )
                : null,
            color: isMain ? null : color,
            boxShadow: isMain
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 25,
                      spreadRadius: 3,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(size / 2),
              onTap: onPressed,
              child: Icon(
                icon,
                color: Colors.white,
                size: size * 0.4,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
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
