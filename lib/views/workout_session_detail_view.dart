import 'package:flutter/material.dart';
import '../models/workout_session_model.dart';

class WorkoutSessionDetailView extends StatelessWidget {
  final WorkoutSession session;

  const WorkoutSessionDetailView({
    super.key,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text(
          'Session Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildWorkoutInfo(),
            const SizedBox(height: 24),
            _buildTimingInfo(),
            const SizedBox(height: 24),
            _buildProgressInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getStatusColor(session.status).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  session.workoutTypeDescription,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildStatusChip(session.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Started: ${_formatDateTime(session.startTime)}',
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 14,
            ),
          ),
          if (session.endTime != null)
            Text(
              'Ended: ${_formatDateTime(session.endTime!)}',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWorkoutInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Workout Configuration',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                'Total Sets',
                session.totalSets.toString(),
                Icons.fitness_center,
                const Color(0xFF00D4AA),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoCard(
                'Set Duration',
                '${session.setDurationSeconds}s',
                Icons.timer,
                const Color(0xFF2196F3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                'Rest Duration',
                '${session.restDurationSeconds}s',
                Icons.pause,
                const Color(0xFFFF9800),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoCard(
                'Rest Interval',
                'Every ${session.restAfterSets} sets',
                Icons.repeat,
                const Color(0xFF9C27B0),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimingInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Timing Information',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                'Total Duration',
                session.formattedDuration,
                Icons.schedule,
                const Color(0xFF00D4AA),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoCard(
                'Workout Time',
                _formatDuration(session.actualWorkoutDurationSeconds),
                Icons.play_arrow,
                const Color(0xFF4CAF50),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          'Paused Time',
          _formatDuration(session.totalPausedDurationSeconds),
          Icons.pause_circle,
          const Color(0xFFFF6B35),
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _buildProgressInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Progress',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Sets Completed',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${session.completedSets} / ${session.totalSets}',
                    style: const TextStyle(
                      color: Color(0xFF00D4AA),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: session.completionPercentage / 100,
                backgroundColor: const Color(0xFF2A2A2A),
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getStatusColor(session.status),
                ),
                minHeight: 8,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Completion Rate',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${session.completionPercentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: _getStatusColor(session.status),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(SessionStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getStatusColor(status),
          width: 1,
        ),
      ),
      child: Text(
        _getStatusText(status),
        style: TextStyle(
          color: _getStatusColor(status),
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getStatusColor(SessionStatus status) {
    switch (status) {
      case SessionStatus.completed:
        return const Color(0xFF00D4AA);
      case SessionStatus.inProgress:
        return const Color(0xFF2196F3);
      case SessionStatus.paused:
        return const Color(0xFFFF9800);
      case SessionStatus.abandoned:
        return const Color(0xFFF44336);
    }
  }

  String _getStatusText(SessionStatus status) {
    switch (status) {
      case SessionStatus.completed:
        return 'Completed';
      case SessionStatus.inProgress:
        return 'In Progress';
      case SessionStatus.paused:
        return 'Paused';
      case SessionStatus.abandoned:
        return 'Abandoned';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(int seconds) {
    if (seconds == 0) return '0s';

    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${remainingSeconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${remainingSeconds}s';
    } else {
      return '${remainingSeconds}s';
    }
  }
}
