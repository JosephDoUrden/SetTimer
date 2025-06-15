import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/workout_session_service.dart';
import '../services/achievement_service.dart';
import '../models/achievement_model.dart';

class AnalyticsDashboardView extends StatefulWidget {
  const AnalyticsDashboardView({super.key});

  @override
  State<AnalyticsDashboardView> createState() => _AnalyticsDashboardViewState();
}

class _AnalyticsDashboardViewState extends State<AnalyticsDashboardView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final WorkoutSessionService _sessionService = WorkoutSessionService();
  final AchievementService _achievementService = AchievementService();

  Map<String, dynamic>? _analytics;
  Map<String, dynamic>? _intensityAnalysis;
  int _currentStreak = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
      final analytics = await _sessionService.getAdvancedAnalytics();
      final intensityAnalysis = await _sessionService.getWorkoutIntensityAnalysis();
      final streak = await _sessionService.getWorkoutStreak();

      setState(() {
        _analytics = analytics;
        _intensityAnalysis = intensityAnalysis;
        _currentStreak = streak;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Analytics Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF00D4AA),
          labelColor: const Color(0xFF00D4AA),
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Progress'),
            Tab(text: 'Achievements'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF00D4AA),
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildProgressTab(),
                _buildAchievementsTab(),
              ],
            ),
    );
  }

  Widget _buildOverviewTab() {
    if (_analytics == null) return const Center(child: Text('No data available'));

    return RefreshIndicator(
      onRefresh: _loadData,
      color: const Color(0xFF00D4AA),
      backgroundColor: const Color(0xFF1A1A1A),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Streak Card - Featured at top
            _buildStreakCard(),
            const SizedBox(height: 24),

            // Quick Stats Cards
            _buildQuickStatsGrid(),
            const SizedBox(height: 24),

            // Workout Frequency Chart
            _buildWorkoutFrequencyChart(),
            const SizedBox(height: 24),

            // Time of Day Distribution
            _buildTimeOfDayChart(),
            const SizedBox(height: 24),

            // Most Used Presets
            _buildMostUsedPresets(),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFF6B35).withOpacity(0.8),
            const Color(0xFFFF8E53).withOpacity(0.6),
            const Color(0xFFFFB366).withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B35).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Fire emoji with glow effect
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Text(
                  '🔥',
                  style: TextStyle(fontSize: 32),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Streak',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '$_currentStreak ${_currentStreak == 1 ? 'Day' : 'Days'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStreakMotivationText(),
        ],
      ),
    );
  }

  Widget _buildStreakMotivationText() {
    String motivationText;
    String emoji;

    if (_currentStreak == 0) {
      motivationText = "Start your streak today! 💪";
      emoji = "🚀";
    } else if (_currentStreak < 3) {
      motivationText = "Great start! Keep it going!";
      emoji = "⭐";
    } else if (_currentStreak < 7) {
      motivationText = "You're on fire! Don't break the chain!";
      emoji = "🔥";
    } else if (_currentStreak < 30) {
      motivationText = "Amazing consistency! You're unstoppable!";
      emoji = "🏆";
    } else {
      motivationText = "Legendary dedication! You're an inspiration!";
      emoji = "👑";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 8),
          Text(
            motivationText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsGrid() {
    final totalWorkouts = _analytics!['totalWorkouts'] as int;
    final totalTime = _analytics!['totalWorkoutTime'] as int;
    final avgCompletion = _analytics!['averageCompletionRate'] as double;
    final consistency = _analytics!['workoutConsistency'] as double;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildStatCard('Total Workouts', '$totalWorkouts', Icons.fitness_center, const Color(0xFF00D4AA)),
        _buildStatCard('Total Time', _formatDuration(totalTime), Icons.timer, const Color(0xFF2196F3)),
        _buildStatCard('Avg Completion', '${avgCompletion.toInt()}%', Icons.check_circle, const Color(0xFF4CAF50)),
        _buildStatCard('Consistency', '${consistency.toInt()}%', Icons.trending_up, const Color(0xFFFF9800)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1A1A),
            Color(0xFF2A2A2A),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.trending_up, color: color, size: 16),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutFrequencyChart() {
    final frequency = _analytics!['workoutFrequency'] as Map<String, int>;
    if (frequency.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1A1A),
            Color(0xFF2A2A2A),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
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
                barTouchData: BarTouchData(enabled: true),
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

  Widget _buildTimeOfDayChart() {
    final timeDistribution = _analytics!['timeOfDayDistribution'] as Map<String, int>;
    if (timeDistribution.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1A1A),
            Color(0xFF2A2A2A),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Workout Time Distribution',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: _buildPieSections(timeDistribution),
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildTimeDistributionLegend(timeDistribution),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(Map<String, int> distribution) {
    final total = distribution.values.fold(0, (sum, value) => sum + value);
    if (total == 0) return [];

    final colors = [
      const Color(0xFF00D4AA),
      const Color(0xFF2196F3),
      const Color(0xFFFF9800),
      const Color(0xFF9C27B0),
    ];

    return distribution.entries.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final percentage = (data.value / total * 100);

      return PieChartSectionData(
        color: colors[index % colors.length],
        value: data.value.toDouble(),
        title: '${percentage.toInt()}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildTimeDistributionLegend(Map<String, int> distribution) {
    final colors = [
      const Color(0xFF00D4AA),
      const Color(0xFF2196F3),
      const Color(0xFFFF9800),
      const Color(0xFF9C27B0),
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: distribution.entries.toList().asMap().entries.map((entry) {
        final index = entry.key;
        final data = entry.value;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: colors[index % colors.length],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${data.key}: ${data.value}',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildMostUsedPresets() {
    final presets = _analytics!['mostUsedPresets'] as Map<String, int>;
    if (presets.isEmpty) return const SizedBox();

    final sortedPresets = presets.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1A1A),
            Color(0xFF2A2A2A),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Most Used Presets',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...sortedPresets.take(5).map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.key,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                    Text(
                      '${entry.value} uses',
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildMonthlyProgressChart() {
    final monthlyProgress = _analytics!['monthlyProgress'] as Map<String, Map<String, dynamic>>;
    if (monthlyProgress.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1A1A),
            Color(0xFF2A2A2A),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Monthly Progress',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final months = monthlyProgress.keys.toList();
                        if (value.toInt() >= 0 && value.toInt() < months.length) {
                          final monthKey = months[value.toInt()];
                          final parts = monthKey.split('-');
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '${parts[1]}/${parts[0].substring(2)}',
                              style: const TextStyle(color: Colors.white70, fontSize: 10),
                            ),
                          );
                        }
                        return const Text('');
                      },
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
                lineBarsData: [
                  LineChartBarData(
                    spots: _buildMonthlySpots(monthlyProgress),
                    isCurved: true,
                    color: const Color(0xFF00D4AA),
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF00D4AA).withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _buildMonthlySpots(Map<String, Map<String, dynamic>> monthlyProgress) {
    final sortedEntries = monthlyProgress.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

    return sortedEntries.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value.value;
      final workouts = data['workouts'] as int;

      return FlSpot(index.toDouble(), workouts.toDouble());
    }).toList();
  }

  Widget _buildWeeklyProgressChart() {
    // Similar implementation to monthly but for weekly data
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1A1A),
            Color(0xFF2A2A2A),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Progress (Last 12 Weeks)',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Chart implementation for weekly data...',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildIntensityChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1A1A),
            Color(0xFF2A2A2A),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Workout Intensity Analysis',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Intensity tracking implementation...',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildConsistencyMeter() {
    final consistency = _analytics!['workoutConsistency'] as double;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1A1A),
            Color(0xFF2A2A2A),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Workout Consistency',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: consistency / 100,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00D4AA)),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '${consistency.toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Worked out ${(consistency * 30 / 100).toInt()} out of 30 days',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementProgress() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1A1A),
            Color(0xFF2A2A2A),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Achievement Progress',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Achievement system integration coming...',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAchievements() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1A1A),
            Color(0xFF2A2A2A),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Achievements',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'No recent achievements',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildNextAchievement() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1A1A),
            Color(0xFF2A2A2A),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Next Achievement',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Complete 3 more workouts to unlock "Getting Started"',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressTab() {
    if (_analytics == null) return const Center(child: Text('No data available'));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Streak Progress Widget
          _buildStreakProgressWidget(),
          const SizedBox(height: 24),

          // Monthly Progress Chart
          _buildMonthlyProgressChart(),
          const SizedBox(height: 24),

          // Weekly Progress Chart
          _buildWeeklyProgressChart(),
          const SizedBox(height: 24),

          // Intensity Analysis
          if (_intensityAnalysis != null) _buildIntensityChart(),
          const SizedBox(height: 24),

          // Consistency Meter
          _buildConsistencyMeter(),
        ],
      ),
    );
  }

  Widget _buildStreakProgressWidget() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1A1A),
            Color(0xFF2A2A2A),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                '🔥',
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(width: 12),
              Text(
                'Streak Progress',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildStreakMilestones(),
        ],
      ),
    );
  }

  Widget _buildStreakMilestones() {
    final milestones = [3, 7, 14, 30, 50, 100];

    return Column(
      children: milestones.map((milestone) {
        final isCompleted = _currentStreak >= milestone;
        final isNext = !isCompleted &&
            (_currentStreak < milestone) &&
            (milestones.indexOf(milestone) == 0 || _currentStreak >= milestones[milestones.indexOf(milestone) - 1]);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(0xFFFF6B35)
                      : isNext
                          ? const Color(0xFFFF6B35).withOpacity(0.3)
                          : Colors.grey.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: isNext ? Border.all(color: const Color(0xFFFF6B35), width: 2) : null,
                ),
                child: Center(
                  child: isCompleted
                      ? const Text('🔥', style: TextStyle(fontSize: 16))
                      : Text(
                          '$milestone',
                          style: TextStyle(
                            color: isNext ? const Color(0xFFFF6B35) : Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$milestone Day${milestone > 1 ? 's' : ''} Streak',
                      style: TextStyle(
                        color: isCompleted ? Colors.white : Colors.white70,
                        fontSize: 16,
                        fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    if (isNext)
                      Text(
                        '${milestone - _currentStreak} more day${(milestone - _currentStreak) > 1 ? 's' : ''} to go!',
                        style: const TextStyle(
                          color: Color(0xFFFF6B35),
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              if (isCompleted)
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF4CAF50),
                  size: 20,
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAchievementsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Streak Achievements Section
          _buildStreakAchievementsSection(),
          const SizedBox(height: 24),

          // Achievement Progress Overview
          _buildAchievementProgress(),
          const SizedBox(height: 24),

          // Recent Achievements
          _buildRecentAchievements(),
          const SizedBox(height: 24),

          // Next Achievement Preview
          _buildNextAchievement(),
        ],
      ),
    );
  }

  Widget _buildStreakAchievementsSection() {
    return FutureBuilder<List<Achievement>>(
      future: _achievementService.getAchievementsByType(AchievementType.streak),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF00D4AA)));
        }

        final streakAchievements = snapshot.data!;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFFF6B35).withOpacity(0.1),
                const Color(0xFFFF8E53).withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFF6B35).withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Text(
                    '🔥',
                    style: TextStyle(fontSize: 24),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Streak Achievements',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...streakAchievements.map((achievement) => _buildStreakAchievementCard(achievement)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStreakAchievementCard(Achievement achievement) {
    final isUnlocked = achievement.isUnlocked;
    final progress = achievement.currentProgress;
    final target = achievement.targetValue;
    final progressPercentage = (progress / target * 100).clamp(0.0, 100.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnlocked ? const Color(0xFFFF6B35).withOpacity(0.2) : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: isUnlocked ? Border.all(color: const Color(0xFFFF6B35).withOpacity(0.5)) : Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isUnlocked ? achievement.color : Colors.grey.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isUnlocked
                  ? const Text('🔥', style: TextStyle(fontSize: 20))
                  : Icon(
                      achievement.icon,
                      color: Colors.grey,
                      size: 24,
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: TextStyle(
                    color: isUnlocked ? Colors.white : Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  achievement.description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                if (!isUnlocked) ...[
                  LinearProgressIndicator(
                    value: progressPercentage / 100,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFFF6B35),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$progress / $target days (${progressPercentage.toInt()}%)',
                    style: const TextStyle(
                      color: Color(0xFFFF6B35),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isUnlocked)
            const Icon(
              Icons.check_circle,
              color: Color(0xFF4CAF50),
              size: 24,
            ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}
