import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/timer_controller.dart';
import '../models/preset_model.dart';
import '../services/preset_service.dart';
import 'template_management_view.dart';

class PresetSelectionView extends StatefulWidget {
  const PresetSelectionView({super.key});

  @override
  State<PresetSelectionView> createState() => _PresetSelectionViewState();
}

class _PresetSelectionViewState extends State<PresetSelectionView> {
  final PresetService _presetService = PresetService();
  List<PresetModel> _presets = [];
  List<String> _categories = [];
  String _selectedCategory = 'All';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPresets();
  }

  Future<void> _loadPresets() async {
    try {
      final presets = await _presetService.getAllPresets();
      final categories = await _presetService.getCategories();

      setState(() {
        _presets = presets;
        _categories = ['All', ...categories];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading presets: $e')),
      );
    }
  }

  List<PresetModel> get _filteredPresets {
    if (_selectedCategory == 'All') return _presets;
    return _presets.where((preset) => preset.category == _selectedCategory).toList();
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
          child: Column(
            children: [
              _buildHeader(),
              if (_isLoading)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else ...[
                _buildCategoryFilter(),
                Expanded(child: _buildPresetGrid()),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
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
                  'Workout Presets',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Quick start with proven routines',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Template Management Button
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.withOpacity(0.2),
              border: Border.all(
                color: Colors.blue.withOpacity(0.4),
                width: 1,
              ),
            ),
            child: IconButton(
              onPressed: _navigateToTemplateManagement,
              icon: const Icon(
                Icons.library_books,
                color: Colors.blue,
                size: 24,
              ),
              tooltip: 'Manage Templates',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              backgroundColor: Colors.white.withOpacity(0.1),
              selectedColor: const Color(0xFF00D4AA).withOpacity(0.3),
              labelStyle: TextStyle(
                color: isSelected ? const Color(0xFF00D4AA) : Colors.white70,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? const Color(0xFF00D4AA) : Colors.white.withOpacity(0.2),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPresetGrid() {
    final filteredPresets = _filteredPresets;

    if (filteredPresets.isEmpty) {
      return Center(
        child: Text(
          'No presets found',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 16,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: filteredPresets.length,
        itemBuilder: (context, index) {
          return _buildPresetCard(filteredPresets[index]);
        },
      ),
    );
  }

  Widget _buildPresetCard(PresetModel preset) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _loadPreset(preset),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: _getCategoryColor(preset.category).withOpacity(0.2),
                      ),
                      child: Icon(
                        _getCategoryIcon(preset.iconName ?? 'timer'),
                        color: _getCategoryColor(preset.category),
                        size: 20,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: _getCategoryColor(preset.category).withOpacity(0.2),
                      ),
                      child: Text(
                        preset.category,
                        style: TextStyle(
                          color: _getCategoryColor(preset.category),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  preset.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Flexible(
                  child: Text(
                    preset.description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 8),
                _buildPresetDetails(preset),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPresetDetails(PresetModel preset) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(
              Icons.fitness_center,
              size: 12,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(width: 4),
            Text(
              '${preset.totalSets} sets',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Icon(
              Icons.schedule,
              size: 12,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                preset.formattedDuration,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Icon(
              Icons.timer,
              size: 12,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(width: 4),
            Text(
              preset.estimatedDuration,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'HIIT':
        return const Color(0xFFFF6B35);
      case 'Core':
        return const Color(0xFF00D4AA);
      case 'Endurance':
        return const Color(0xFF6B73FF);
      case 'Strength':
        return const Color(0xFFFF9500);
      case 'Quick':
        return const Color(0xFFFF3B30);
      default:
        return const Color(0xFF00D4AA);
    }
  }

  IconData _getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'flash_on':
        return Icons.flash_on;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'timer':
        return Icons.timer;
      case 'trending_up':
        return Icons.trending_up;
      case 'bolt':
        return Icons.bolt;
      default:
        return Icons.timer;
    }
  }

  void _loadPreset(PresetModel preset) {
    final controller = Provider.of<TimerController>(context, listen: false);

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D4AA)),
        ),
      ),
    );

    // Simulate loading delay for better UX
    Future.delayed(const Duration(milliseconds: 500), () {
      try {
        // Use loadPreset method instead of updateTimerSettings to preserve preset info
        controller.loadPreset(preset);

        Navigator.pop(context); // Close loading dialog
        Navigator.pop(context); // Go back to timer view

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Loaded "${preset.name}" preset'),
            backgroundColor: const Color(0xFF00D4AA),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      } catch (e) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading preset: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  void _navigateToTemplateManagement() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TemplateManagementView(),
      ),
    );

    // Reload presets if templates were modified
    if (result == true || mounted) {
      _loadPresets();
    }
  }
}
