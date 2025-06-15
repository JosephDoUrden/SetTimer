import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/workout_session_model.dart';
import '../services/workout_session_service.dart';
import 'workout_session_detail_view.dart';

class WorkoutHistoryView extends StatefulWidget {
  const WorkoutHistoryView({super.key});

  @override
  State<WorkoutHistoryView> createState() => _WorkoutHistoryViewState();
}

class _WorkoutHistoryViewState extends State<WorkoutHistoryView> with SingleTickerProviderStateMixin {
  final WorkoutSessionService _sessionService = WorkoutSessionService();
  late TabController _tabController;

  List<WorkoutSession> _sessions = [];
  Map<String, dynamic> _stats = {};
  Map<String, dynamic>? _advancedAnalytics;
  bool _isLoading = true;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final sessions = await _sessionService.getWorkoutHistory();
      final stats = await _sessionService.getWorkoutStatistics();
      final analytics = await _sessionService.getAdvancedAnalytics();

      setState(() {
        _sessions = sessions;
        _stats = stats;
        _advancedAnalytics = analytics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading workout history: $e')),
        );
      }
    }
  }

  Future<void> _filterSessions(String filter) async {
    setState(() {
      _selectedFilter = filter;
      _isLoading = true;
    });

    try {
      List<WorkoutSession> filteredSessions;
      Map<String, dynamic> filteredStats;

      switch (filter) {
        case 'Today':
          filteredSessions = await _sessionService.getTodaysWorkouts();
          filteredStats = await _sessionService.getWorkoutStatistics(
            startDate: DateTime.now().subtract(const Duration(days: 1)),
            endDate: DateTime.now(),
          );
          break;
        case 'This Week':
          filteredSessions = await _sessionService.getThisWeeksWorkouts();
          final now = DateTime.now();
          final startOfWeek = DateTime(now.year, now.month, now.day - now.weekday + 1);
          filteredStats = await _sessionService.getWorkoutStatistics(
            startDate: startOfWeek,
            endDate: now,
          );
          break;
        case 'This Month':
          filteredSessions = await _sessionService.getThisMonthsWorkouts();
          final now = DateTime.now();
          final startOfMonth = DateTime(now.year, now.month, 1);
          filteredStats = await _sessionService.getWorkoutStatistics(
            startDate: startOfMonth,
            endDate: now,
          );
          break;
        default:
          filteredSessions = await _sessionService.getWorkoutHistory();
          filteredStats = await _sessionService.getWorkoutStatistics();
      }

      setState(() {
        _sessions = filteredSessions;
        _stats = filteredStats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error filtering sessions: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text(
          'Workout History',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF00D4AA),
          labelColor: const Color(0xFF00D4AA),
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Sessions'),
            Tab(text: 'Statistics'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSessionsTab(),
          _buildStatisticsTab(),
        ],
      ),
    );
  }

  Widget _buildSessionsTab() {
    return Column(
      children: [
        _buildFilterChips(),
        _buildStreakWidget(),
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF00D4AA),
                  ),
                )
              : _sessions.isEmpty
                  ? _buildEmptyState()
                  : _buildSessionsList(),
        ),
      ],
    );
  }

  Widget _buildStreakWidget() {
    return FutureBuilder<int>(
      future: _sessionService.getWorkoutStreak(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data! <= 1) {
          return const SizedBox.shrink();
        }

        final streak = snapshot.data!;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFFF6B35).withOpacity(0.15),
                const Color(0xFFFF8E53).withOpacity(0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFFF6B35).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  '🔥',
                  style: TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Streak',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$streak Day${streak != 1 ? 's' : ''}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (streak >= 7)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFFD700).withOpacity(0.5),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '🏆',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Hot!',
                        style: TextStyle(
                          color: Color(0xFFFFD700),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Today', 'This Week', 'This Month'];

    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final isSelected = _selectedFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(filter),
                selected: isSelected,
                onSelected: (_) => _filterSessions(filter),
                backgroundColor: const Color(0xFF2A2A2A),
                selectedColor: const Color(0xFF00D4AA).withOpacity(0.2),
                labelStyle: TextStyle(
                  color: isSelected ? const Color(0xFF00D4AA) : Colors.white70,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                side: BorderSide(
                  color: isSelected ? const Color(0xFF00D4AA) : Colors.transparent,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSessionsList() {
    return RefreshIndicator(
      color: const Color(0xFF00D4AA),
      backgroundColor: const Color(0xFF2A2A2A),
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _sessions.length,
        itemBuilder: (context, index) {
          final session = _sessions[index];
          return _buildSessionCard(session);
        },
      ),
    );
  }

  Widget _buildSessionCard(WorkoutSession session) {
    return Card(
      color: const Color(0xFF1A1A1A),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getStatusColor(session.status).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => WorkoutSessionDetailView(session: session),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusChip(session.status),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: Colors.white54,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDateTime(session.startTime),
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(
                    Icons.fitness_center,
                    '${session.completedSets}/${session.totalSets}',
                    'Sets',
                  ),
                  const SizedBox(width: 12),
                  _buildInfoChip(
                    Icons.timer,
                    session.formattedDuration,
                    'Duration',
                  ),
                  const SizedBox(width: 12),
                  _buildInfoChip(
                    Icons.trending_up,
                    '${session.completionPercentage.toStringAsFixed(0)}%',
                    'Complete',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF00D4AA), size: 14),
          const SizedBox(width: 4),
          Column(
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(SessionStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(status),
          width: 1,
        ),
      ),
      child: Text(
        _getStatusText(status),
        style: TextStyle(
          color: _getStatusColor(status),
          fontSize: 12,
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

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 64,
            color: Colors.white24,
          ),
          SizedBox(height: 16),
          Text(
            'No workout sessions yet',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Start your first workout to see it here',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF00D4AA),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterChips(),
          const SizedBox(height: 16),
          _buildStatsOverview(),
          const SizedBox(height: 24),
          if (_advancedAnalytics != null) ...[
            _buildWorkoutFrequencyChart(),
            const SizedBox(height: 24),
            _buildConsistencyChart(),
            const SizedBox(height: 24),
          ],
          _buildDetailedStats(),
        ],
      ),
    );
  }

  Widget _buildStatsOverview() {
    final totalSessions = _stats['totalSessions'] ?? 0;
    final completedSessions = _stats['completedSessions'] ?? 0;
    final totalWorkoutTime = _stats['totalWorkoutTimeSeconds'] ?? 0;
    final completionRate = _stats['completionRate'] ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overview',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            _buildStatCard(
              'Total Sessions',
              totalSessions.toString(),
              Icons.fitness_center,
              const Color(0xFF00D4AA),
            ),
            _buildStatCard(
              'Completed',
              completedSessions.toString(),
              Icons.check_circle,
              const Color(0xFF4CAF50),
            ),
            _buildStatCard(
              'Total Time',
              _formatDuration(totalWorkoutTime),
              Icons.timer,
              const Color(0xFF2196F3),
            ),
            _buildStatCard(
              'Success Rate',
              '${completionRate.toStringAsFixed(0)}%',
              Icons.trending_up,
              const Color(0xFFFF6B35),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
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

  Widget _buildDetailedStats() {
    final avgWorkoutTime = _stats['averageWorkoutTimeSeconds'] ?? 0;
    final totalSetsCompleted = _stats['totalSetsCompleted'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detailed Statistics',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildDetailedStatRow(
          'Average Workout Time',
          _formatDuration(avgWorkoutTime),
          Icons.av_timer,
        ),
        _buildDetailedStatRow(
          'Total Sets Completed',
          totalSetsCompleted.toString(),
          Icons.format_list_numbered,
        ),
        _buildDetailedStatRow(
          'Filter Period',
          _selectedFilter,
          Icons.filter_list,
        ),
      ],
    );
  }

  Widget _buildDetailedStatRow(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF00D4AA), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF00D4AA),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year} • ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(int seconds) {
    if (seconds == 0) return '0s';

    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${remainingSeconds}s';
    } else {
      return '${remainingSeconds}s';
    }
  }

  Widget _buildWorkoutFrequencyChart() {
    final frequency = _advancedAnalytics!['workoutFrequency'] as Map<String, int>;
    if (frequency.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00D4AA).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Workout Frequency by Day',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: frequency.values.isNotEmpty ? frequency.values.reduce((a, b) => a > b ? a : b).toDouble() * 1.2 : 10,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: const Color(0xFF2A2A2A),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                      return BarTooltipItem(
                        '${days[group.x]}: ${rod.toY.round()} workouts',
                        const TextStyle(color: Colors.white, fontSize: 14),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        if (value.toInt() >= 0 && value.toInt() < days.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              days[value.toInt()],
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: _buildBarGroups(frequency),
                gridData: const FlGridData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(Map<String, int> frequency) {
    const dayOrder = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return dayOrder.asMap().entries.map((entry) {
      final index = entry.key;
      final day = entry.value;
      final count = frequency[day] ?? 0;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: count.toDouble(),
            color: const Color(0xFF00D4AA),
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildConsistencyChart() {
    final consistency = _advancedAnalytics!['workoutConsistency'] as double;
    final activeDays = (consistency * 30 / 100).toInt();
    const totalDays = 30;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1A1A),
            Color(0xFF2A2A2A),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00D4AA).withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D4AA).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D4AA).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: Color(0xFF00D4AA),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Workout Consistency',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Modern progress ring
          Center(
            child: SizedBox(
              width: 140,
              height: 140,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background circle
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.05),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 2,
                      ),
                    ),
                  ),
                  // Progress circle - properly sized and positioned
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: CircularProgressIndicator(
                      value: consistency / 100,
                      strokeWidth: 8,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        consistency >= 70
                            ? const Color(0xFF00D4AA)
                            : consistency >= 40
                                ? const Color(0xFFFF9800)
                                : const Color(0xFFFF6B35),
                      ),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  // Center content
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${consistency.toInt()}%',
                        style: TextStyle(
                          color: consistency >= 70
                              ? const Color(0xFF00D4AA)
                              : consistency >= 40
                                  ? const Color(0xFFFF9800)
                                  : const Color(0xFFFF6B35),
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Consistent',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Stats row
          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: _buildConsistencyStatItem(
                    'Active Days',
                    activeDays.toString(),
                    Icons.check_circle,
                    const Color(0xFF00D4AA),
                  ),
                ),
                Container(
                  width: 1,
                  color: Colors.white.withOpacity(0.1),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                ),
                Expanded(
                  child: _buildConsistencyStatItem(
                    'Total Days',
                    totalDays.toString(),
                    Icons.calendar_today,
                    Colors.white.withOpacity(0.7),
                  ),
                ),
                Container(
                  width: 1,
                  color: Colors.white.withOpacity(0.1),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                ),
                Expanded(
                  child: _buildConsistencyStatItem(
                    'Streak',
                    '${_getCurrentStreak()}',
                    Icons.local_fire_department,
                    const Color(0xFFFF6B35),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Consistency message
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getConsistencyMessageColor(consistency).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getConsistencyMessageColor(consistency).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getConsistencyIcon(consistency),
                  color: _getConsistencyMessageColor(consistency),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getConsistencyMessage(consistency),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsistencyStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  int _getCurrentStreak() {
    // Streak değerini stats'dan al, yoksa 0 döndür
    return _stats['currentStreak'] ?? 0;
  }

  Color _getConsistencyMessageColor(double consistency) {
    if (consistency >= 70) {
      return const Color(0xFF00D4AA);
    } else if (consistency >= 40) {
      return const Color(0xFFFF9800);
    } else {
      return const Color(0xFFFF6B35);
    }
  }

  IconData _getConsistencyIcon(double consistency) {
    if (consistency >= 70) {
      return Icons.emoji_events;
    } else if (consistency >= 40) {
      return Icons.trending_up;
    } else {
      return Icons.fitness_center;
    }
  }

  String _getConsistencyMessage(double consistency) {
    if (consistency >= 80) {
      return "Excellent consistency! You're crushing your fitness goals! 🔥";
    } else if (consistency >= 60) {
      return "Great job! You're building a strong workout habit. Keep it up! 💪";
    } else if (consistency >= 40) {
      return "Good progress! Try to be more consistent to see better results. 📈";
    } else if (consistency >= 20) {
      return "You're getting started! Small steps lead to big changes. 🌱";
    } else {
      return "Let's build that workout habit! Every workout counts. 🚀";
    }
  }

  Widget _buildLegendItem(String label, Color color, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}
