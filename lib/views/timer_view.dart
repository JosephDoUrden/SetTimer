import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/timer_controller.dart';
import '../models/timer_model.dart';

class TimerView extends StatelessWidget {
  const TimerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text(
          'SetTimer',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<TimerController>(
        builder: (context, controller, child) {
          final timer = controller.timer;

          // Show completion message
          if (timer.state == TimerState.completed) {
            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0A0A0A),
                    Color(0xFF1A1A1A),
                    Color(0xFF2A2A2A),
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 100,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Workout Complete!',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: controller.resetTimer,
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: const Text(
                        'Start New Workout',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00D4AA),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => _showSettingsModal(context, controller),
                      icon: const Icon(Icons.settings, color: Colors.white70),
                      label: const Text(
                        'Settings',
                        style: TextStyle(color: Colors.white70),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white30,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0A0A0A),
                  Color(0xFF1A1A1A),
                  Color(0xFF2A2A2A),
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Settings button
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        onPressed: () => _showSettingsModal(context, controller),
                        icon: const Icon(
                          Icons.settings,
                          color: Colors.white70,
                          size: 28,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Progress section
                    _buildProgressSection(timer),

                    const SizedBox(height: 40),

                    // Timer circle
                    Expanded(
                      child: Center(
                        child: _buildTimerCircle(timer),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Control buttons
                    _buildControlButtons(context, controller, timer),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressSection(TimerModel timer) {
    return Column(
      children: [
        // Set counter
        Text(
          'SET ${timer.currentSet} OF ${timer.totalSets}',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),

        // Progress bar
        Container(
          height: 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: Colors.white10,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: 1 - timer.progress,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                timer.isInRestPeriod ? const Color(0xFFFF6B35) : const Color(0xFF00D4AA),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimerCircle(TimerModel timer) {
    final isRest = timer.isInRestPeriod;
    final primaryColor = isRest ? const Color(0xFFFF6B35) : const Color(0xFF00D4AA);

    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            primaryColor.withOpacity(0.1),
            primaryColor.withOpacity(0.05),
            Colors.transparent,
          ],
        ),
        border: Border.all(
          color: primaryColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          // Animated progress ring
          Positioned.fill(
            child: CircularProgressIndicator(
              value: timer.isInRestPeriod
                  ? (timer.restDurationSeconds - timer.remainingSeconds) / timer.restDurationSeconds
                  : (timer.setDurationSeconds - timer.remainingSeconds) / timer.setDurationSeconds,
              strokeWidth: 8,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),
          ),

          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Phase indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: primaryColor.withOpacity(0.2),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    timer.isInRestPeriod ? 'REST' : 'WORK',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                      letterSpacing: 1,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Time display
                Text(
                  _formatTime(timer.remainingSeconds),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                    height: 1,
                  ),
                ),

                const SizedBox(height: 8),

                // State indicator
                if (timer.state != TimerState.idle)
                  Text(
                    _getStateText(timer.state),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white60,
                      letterSpacing: 1,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons(BuildContext context, TimerController controller, TimerModel timer) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Reset button
        _buildControlButton(
          icon: Icons.refresh,
          onPressed: controller.resetTimer,
          color: Colors.white30,
          size: 56,
        ),

        // Main play/pause button
        _buildControlButton(
          icon: timer.state == TimerState.running || timer.state == TimerState.resting ? Icons.pause : Icons.play_arrow,
          onPressed: timer.state == TimerState.running || timer.state == TimerState.resting ? controller.pauseTimer : controller.startTimer,
          color: timer.isInRestPeriod ? const Color(0xFFFF6B35) : const Color(0xFF00D4AA),
          size: 72,
          isMain: true,
        ),

        // Settings button (placeholder for symmetry)
        _buildControlButton(
          icon: Icons.tune,
          onPressed: () => _showSettingsModal(context, controller),
          color: Colors.white30,
          size: 56,
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
    required double size,
    bool isMain = false,
  }) {
    return Container(
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
        color: isMain ? null : color.withOpacity(0.2),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: isMain
            ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: isMain ? Colors.white : color,
          size: size * 0.4,
        ),
      ),
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
