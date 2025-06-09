import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/timer_controller.dart';
import '../models/timer_model.dart';

class TimerView extends StatelessWidget {
  const TimerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SetTimer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to settings screen
            },
          ),
        ],
      ),
      body: Consumer<TimerController>(
        builder: (context, controller, child) {
          final timer = controller.timer;

          // Show completion message
          if (timer.state == TimerState.completed) {
            return Center(
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
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: controller.resetTimer,
                    child: const Text('Start New Workout'),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Progress indicator
                LinearProgressIndicator(
                  value: timer.progress,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    timer.isInRestPeriod ? Colors.orange : Colors.blue,
                  ),
                ),
                const SizedBox(height: 20),

                // Set counter
                Text(
                  'Set ${timer.currentSet} of ${timer.totalSets}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 10),

                // Current phase
                Text(
                  timer.isInRestPeriod ? 'REST' : 'WORK',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: timer.isInRestPeriod ? Colors.orange : Colors.blue,
                  ),
                ),
                const SizedBox(height: 20),

                // Timer display
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: timer.isInRestPeriod ? Colors.orange : Colors.blue,
                      width: 4,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _formatTime(timer.remainingSeconds),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Control buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: timer.state == TimerState.running || timer.state == TimerState.resting
                          ? controller.pauseTimer
                          : controller.startTimer,
                      icon: Icon(
                        timer.state == TimerState.running || timer.state == TimerState.resting ? Icons.pause : Icons.play_arrow,
                      ),
                      label: Text(
                        timer.state == TimerState.running || timer.state == TimerState.resting ? 'Pause' : 'Start',
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: controller.resetTimer,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
