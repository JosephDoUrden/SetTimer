import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/achievement_model.dart';
import '../services/achievement_service.dart';

class AchievementsView extends StatefulWidget {
  const AchievementsView({super.key});

  @override
  State<AchievementsView> createState() => _AchievementsViewState();
}

class _AchievementsViewState extends State<AchievementsView> with TickerProviderStateMixin {
  final AchievementService _achievementService = AchievementService();
  late TabController _tabController;

  List<Achievement> _allAchievements = [];
  Map<String, dynamic> _stats = {};
  Map<String, dynamic> _userLevel = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadAchievements();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAchievements() async {
    setState(() => _isLoading = true);

    try {
      final achievements = await _achievementService.getAllAchievements();
      final stats = await _achievementService.getAchievementStatistics();
      final userLevel = await _achievementService.getUserAchievementLevel();

      setState(() {
        _allAchievements = achievements;
        _stats = stats;
        _userLevel = userLevel;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading achievements: $e')),
        );
      }
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
          'Achievements',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadAchievements,
          ),
        ],
      ),
      body: _isLoading ? _buildLoadingScreen() : _buildAchievementsContent(),
    );
  }

  Widget _buildLoadingScreen() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D4AA)),
      ),
    );
  }

  Widget _buildAchievementsContent() {
    return Column(
      children: [
        // User level and stats summary
        _buildUserLevelCard(),

        // Achievement tabs
        Container(
          color: const Color(0xFF1A1A1A),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: const Color(0xFF00D4AA),
            labelColor: const Color(0xFF00D4AA),
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Streak'),
              Tab(text: 'Workouts'),
              Tab(text: 'Time'),
              Tab(text: 'Personal'),
            ],
          ),
        ),

        // Achievement content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildAllAchievements(),
              _buildAchievementsByType(AchievementType.streak),
              _buildAchievementsByType(AchievementType.totalWorkouts),
              _buildAchievementsByType(AchievementType.totalTime),
              _buildAchievementsByType(AchievementType.personal),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserLevelCard() {
    if (_userLevel.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00D4AA).withOpacity(0.2),
            const Color(0xFF00D4AA).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00D4AA).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF00D4AA),
                      const Color(0xFF00D4AA).withOpacity(0.7),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_userLevel['currentLevel']} Level',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_userLevel['currentPoints']} points',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${_stats['unlockedAchievements']}/${_stats['totalAchievements']}',
                    style: const TextStyle(
                      color: Color(0xFF00D4AA),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Unlocked',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (_userLevel['pointsForNext'] > 0) ...[
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress to ${_userLevel['nextLevel']}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${_userLevel['pointsForNext']} points needed',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _userLevel['progress'] / 100.0,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00D4AA)),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAllAchievements() {
    final sortedAchievements = List<Achievement>.from(_allAchievements)
      ..sort((a, b) {
        // Unlocked achievements first, then by progress percentage
        if (a.isUnlocked && !b.isUnlocked) return -1;
        if (!a.isUnlocked && b.isUnlocked) return 1;
        if (a.isUnlocked && b.isUnlocked) return 0;
        return b.progressPercentage.compareTo(a.progressPercentage);
      });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedAchievements.length,
      itemBuilder: (context, index) {
        return _buildAchievementCard(sortedAchievements[index]);
      },
    );
  }

  Widget _buildAchievementsByType(AchievementType type) {
    final typeAchievements = _allAchievements.where((a) => a.type == type).toList()
      ..sort((a, b) {
        if (a.isUnlocked && !b.isUnlocked) return -1;
        if (!a.isUnlocked && b.isUnlocked) return 1;
        return a.targetValue.compareTo(b.targetValue);
      });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: typeAchievements.length,
      itemBuilder: (context, index) {
        return _buildAchievementCard(typeAchievements[index]);
      },
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    final isUnlocked = achievement.isUnlocked;
    final progress = achievement.progressPercentage;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showAchievementDetails(achievement),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isUnlocked
                    ? [
                        achievement.color.withOpacity(0.2),
                        achievement.color.withOpacity(0.1),
                      ]
                    : [
                        Colors.white.withOpacity(0.05),
                        Colors.white.withOpacity(0.02),
                      ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isUnlocked ? achievement.color.withOpacity(0.3) : Colors.white.withOpacity(0.1),
              ),
            ),
            child: Row(
              children: [
                // Achievement icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isUnlocked ? achievement.color.withOpacity(0.2) : Colors.white.withOpacity(0.1),
                  ),
                  child: Icon(
                    achievement.icon,
                    color: isUnlocked ? achievement.color : Colors.white.withOpacity(0.5),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // Achievement details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              achievement.title,
                              style: TextStyle(
                                color: isUnlocked ? Colors.white : Colors.white.withOpacity(0.8),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _buildTierBadge(achievement.tier),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        achievement.description,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (isUnlocked) ...[
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: achievement.color,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Unlocked • +${AchievementDefinitions.getAchievementPoints(achievement)} points',
                              style: TextStyle(
                                color: achievement.color,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _achievementService.formatAchievementProgress(achievement),
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${progress.toInt()}%',
                                  style: const TextStyle(
                                    color: Color(0xFF00D4AA),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: progress / 100,
                                backgroundColor: Colors.white.withOpacity(0.1),
                                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00D4AA)),
                                minHeight: 3,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTierBadge(AchievementTier tier) {
    Color tierColor;
    String tierText;

    switch (tier) {
      case AchievementTier.bronze:
        tierColor = const Color(0xFFCD7F32);
        tierText = 'Bronze';
        break;
      case AchievementTier.silver:
        tierColor = const Color(0xFFC0C0C0);
        tierText = 'Silver';
        break;
      case AchievementTier.gold:
        tierColor = const Color(0xFFFFD700);
        tierText = 'Gold';
        break;
      case AchievementTier.platinum:
        tierColor = const Color(0xFFE5E4E2);
        tierText = 'Platinum';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: tierColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: tierColor.withOpacity(0.5)),
      ),
      child: Text(
        tierText.toUpperCase(),
        style: TextStyle(
          color: tierColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showAchievementDetails(Achievement achievement) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      achievement.color.withOpacity(0.3),
                      achievement.color.withOpacity(0.1),
                    ],
                  ),
                ),
                child: Icon(
                  achievement.icon,
                  size: 40,
                  color: achievement.color,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                achievement.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                achievement.description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (achievement.isUnlocked) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: achievement.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: achievement.color,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Unlocked',
                        style: TextStyle(
                          color: achievement.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Column(
                  children: [
                    Text(
                      _achievementService.formatAchievementProgress(achievement),
                      style: const TextStyle(
                        color: Color(0xFF00D4AA),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _achievementService.getMotivationMessage(achievement),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D4AA),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
