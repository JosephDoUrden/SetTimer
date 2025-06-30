import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/voice_coaching_service.dart';

class VoiceCoachingSettingsView extends StatefulWidget {
  const VoiceCoachingSettingsView({super.key});

  @override
  State<VoiceCoachingSettingsView> createState() => _VoiceCoachingSettingsViewState();
}

class _VoiceCoachingSettingsViewState extends State<VoiceCoachingSettingsView> with TickerProviderStateMixin {
  final VoiceCoachingService _voiceService = VoiceCoachingService();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Container(
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
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildVoiceOptionsSection(),
                        const SizedBox(height: 32),
                        _buildCoachingStyleSection(),
                        const SizedBox(height: 32),
                        _buildVoiceControlsSection(),
                        const SizedBox(height: 32),
                        _buildAnnouncementOptionsSection(),
                        const SizedBox(height: 32),
                        _buildTestSection(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.12),
                  Colors.white.withOpacity(0.06),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white70,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Voice Coaching',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Personalize your workout voice coach',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF9C27B0).withOpacity(0.2),
                  const Color(0xFF9C27B0).withOpacity(0.1),
                ],
              ),
            ),
            child: const Icon(
              Icons.record_voice_over,
              color: Color(0xFF9C27B0),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceOptionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Voice Options',
          'Enable and configure voice coaching',
          Icons.settings_voice,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
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
          ),
          child: Column(
            children: [
              _buildToggleOption(
                'Voice Coaching',
                'Enable voice announcements during workouts',
                Icons.record_voice_over,
                _voiceService.isEnabled,
                (value) async => await _voiceService.setEnabled(value),
                const Color(0xFF9C27B0),
              ),
              const SizedBox(height: 16),
              _buildVoiceGenderSelector(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Voice Gender',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildGenderOption(
                'Female',
                Icons.person,
                VoiceGender.female,
                _voiceService.voiceGender == VoiceGender.female,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGenderOption(
                'Male',
                Icons.person_outline,
                VoiceGender.male,
                _voiceService.voiceGender == VoiceGender.male,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption(String label, IconData icon, VoiceGender gender, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: isSelected
            ? LinearGradient(
                colors: [
                  const Color(0xFF9C27B0).withOpacity(0.2),
                  const Color(0xFF9C27B0).withOpacity(0.1),
                ],
              )
            : null,
        color: isSelected ? null : Colors.white.withOpacity(0.05),
        border: Border.all(
          color: isSelected ? const Color(0xFF9C27B0) : Colors.white.withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            // Save voice gender setting first
            await _voiceService.setVoiceGender(gender);
            // Then update UI state
            setState(() {});
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isSelected ? const Color(0xFF9C27B0) : Colors.white70,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFF9C27B0) : Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoachingStyleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Coaching Style',
          'Choose your preferred coaching personality',
          Icons.psychology,
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.1,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: CoachingStyle.values.length,
          itemBuilder: (context, index) {
            final style = CoachingStyle.values[index];
            final isSelected = _voiceService.coachingStyle == style;
            return _buildCoachingStyleCard(style, isSelected);
          },
        ),
      ],
    );
  }

  Widget _buildCoachingStyleCard(CoachingStyle style, bool isSelected) {
    final styleInfo = _getCoachingStyleInfo(style);
    final color = styleInfo['color'] as Color;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isSelected
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
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        border: Border.all(
          color: isSelected ? color.withOpacity(0.5) : Colors.white.withOpacity(0.12),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            // Save coaching style setting first
            await _voiceService.setCoachingStyle(style);
            // Then update UI state
            setState(() {});
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.7)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    styleInfo['icon'] as IconData,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  styleInfo['name'] as String,
                  style: TextStyle(
                    color: isSelected ? color : Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  styleInfo['description'] as String,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceControlsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Voice Controls',
          'Adjust speech rate, volume, and pitch',
          Icons.tune,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
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
          ),
          child: Column(
            children: [
              _buildVoiceSlider(
                'Speech Rate',
                _voiceService.speechRate,
                Icons.speed,
                (value) => _voiceService.setSpeechRate(value),
                const Color(0xFF9C27B0),
                0.1,
                1.0,
              ),
              const SizedBox(height: 20),
              _buildVoiceSlider(
                'Volume',
                _voiceService.volume,
                Icons.volume_up,
                (value) => _voiceService.setVolume(value),
                const Color(0xFF00D4AA),
                0.0,
                1.0,
              ),
              const SizedBox(height: 20),
              _buildVoiceSlider(
                'Pitch',
                _voiceService.pitch,
                Icons.graphic_eq,
                (value) => _voiceService.setPitch(value),
                const Color(0xFFFF6B35),
                0.5,
                2.0,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceSlider(
    String label,
    double value,
    IconData icon,
    Function(double) onChanged,
    Color color,
    double min,
    double max,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.2),
              ),
              child: Icon(
                icon,
                color: color,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: color.withOpacity(0.2),
              ),
              child: Text(
                _formatSliderValue(label, value),
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            inactiveTrackColor: Colors.white.withOpacity(0.2),
            thumbColor: color,
            overlayColor: color.withOpacity(0.2),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: (newValue) async {
              // Call the async save method first
              await onChanged(newValue);
              // Then update UI state
              setState(() {});
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAnnouncementOptionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Announcement Options',
          'Choose which announcements to enable',
          Icons.campaign,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
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
          ),
          child: Column(
            children: [
              _buildToggleOption(
                'Countdown Announcements',
                'Voice countdown for last 3 seconds',
                Icons.timer,
                _voiceService.isCountdownEnabled,
                (value) => _voiceService.setCountdownEnabled(value),
                const Color(0xFF00D4AA),
              ),
              const SizedBox(height: 16),
              _buildToggleOption(
                'Progress Announcements',
                'Announce set completion progress',
                Icons.trending_up,
                _voiceService.isProgressEnabled,
                (value) => _voiceService.setProgressEnabled(value),
                const Color(0xFFFF6B35),
              ),
              const SizedBox(height: 16),
              _buildToggleOption(
                'Encouragement',
                'Motivational phrases during workout',
                Icons.favorite,
                _voiceService.isEncouragementEnabled,
                (value) => _voiceService.setEncouragementEnabled(value),
                const Color(0xFF4CAF50),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTestSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Test Voice',
          'Preview your voice coaching settings',
          Icons.play_circle,
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                const Color(0xFF9C27B0).withOpacity(0.2),
                const Color(0xFF9C27B0).withOpacity(0.1),
              ],
            ),
            border: Border.all(
              color: const Color(0xFF9C27B0).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                _voiceService.testVoice();
                HapticFeedback.lightImpact();
              },
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.play_arrow,
                      color: Color(0xFF9C27B0),
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Test Voice Coaching',
                      style: TextStyle(
                        color: Color(0xFF9C27B0),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleOption(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.2),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
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
                  fontWeight: FontWeight.w600,
                ),
              ),
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
        Switch(
          value: value,
          onChanged: (newValue) async {
            // Call the async save method first
            await onChanged(newValue);
            // Then update UI state
            setState(() {});
          },
          activeColor: color,
          activeTrackColor: color.withOpacity(0.3),
          inactiveThumbColor: Colors.white.withOpacity(0.5),
          inactiveTrackColor: Colors.white.withOpacity(0.2),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, IconData icon) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                const Color(0xFF9C27B0).withOpacity(0.2),
                const Color(0xFF9C27B0).withOpacity(0.1),
              ],
            ),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF9C27B0),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
      ],
    );
  }

  Map<String, dynamic> _getCoachingStyleInfo(CoachingStyle style) {
    switch (style) {
      case CoachingStyle.motivational:
        return {
          'name': 'Motivational',
          'description': 'Energetic and encouraging',
          'icon': Icons.emoji_events,
          'color': const Color(0xFFFF6B35),
        };
      case CoachingStyle.calm:
        return {
          'name': 'Calm',
          'description': 'Peaceful and mindful',
          'icon': Icons.self_improvement,
          'color': const Color(0xFF4CAF50),
        };
      case CoachingStyle.professional:
        return {
          'name': 'Professional',
          'description': 'Clear and focused',
          'icon': Icons.business_center,
          'color': const Color(0xFF2196F3),
        };
      case CoachingStyle.energetic:
        return {
          'name': 'Energetic',
          'description': 'High-energy and intense',
          'icon': Icons.flash_on,
          'color': const Color(0xFFFF9800),
        };
    }
  }

  String _formatSliderValue(String label, double value) {
    switch (label) {
      case 'Speech Rate':
        return '${(value * 100).round()}%';
      case 'Volume':
        return '${(value * 100).round()}%';
      case 'Pitch':
        return '${value.toStringAsFixed(1)}x';
      default:
        return value.toStringAsFixed(1);
    }
  }
}
