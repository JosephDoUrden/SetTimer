import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/timer_controller.dart';
import '../models/preset_model.dart';
import '../services/preset_service.dart';
import '../widgets/save_template_dialog.dart';

class TemplateManagementView extends StatefulWidget {
  const TemplateManagementView({super.key});

  @override
  State<TemplateManagementView> createState() => _TemplateManagementViewState();
}

class _TemplateManagementViewState extends State<TemplateManagementView> {
  final PresetService _presetService = PresetService();
  List<PresetModel> _customPresets = [];
  List<String> _categories = [];
  String _selectedCategory = 'All';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomPresets();
  }

  Future<void> _loadCustomPresets() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final allPresets = await _presetService.getAllPresets();
      final customPresets = allPresets.where((preset) => !preset.isDefault).toList();
      final categories = await _presetService.getCategories();

      setState(() {
        _customPresets = customPresets;
        _categories = ['All', ...categories];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Error loading templates: $e');
    }
  }

  List<PresetModel> get _filteredPresets {
    if (_selectedCategory == 'All') return _customPresets;
    return _customPresets.where((preset) => preset.category == _selectedCategory).toList();
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
              _buildModernHeader(),
              if (_isLoading)
                const Expanded(child: Center(child: CircularProgressIndicator(color: Color(0xFF00D4AA))))
              else ...[
                if (_categories.length > 1) _buildCategoryFilter(),
                Expanded(child: _buildContent()),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildModernHeader() {
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
                  'My Templates',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Manage your custom workout templates',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
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

  Widget _buildContent() {
    final filteredPresets = _filteredPresets;

    if (filteredPresets.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadCustomPresets,
      color: const Color(0xFF00D4AA),
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: filteredPresets.length,
        itemBuilder: (context, index) {
          return _buildModernPresetCard(filteredPresets[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF00D4AA).withOpacity(0.2),
                  const Color(0xFF00D4AA).withOpacity(0.1),
                ],
              ),
            ),
            child: Icon(
              Icons.library_add_outlined,
              size: 40,
              color: const Color(0xFF00D4AA).withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _customPresets.isEmpty ? 'No Custom Templates' : 'No Templates in "$_selectedCategory"',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _customPresets.isEmpty
                ? 'Create your first custom template by saving your current timer settings.'
                : 'Try selecting a different category or create a new template.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernPresetCard(PresetModel preset) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _loadPreset(preset),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: [
                            _getCategoryColor(preset.category),
                            _getCategoryColor(preset.category).withOpacity(0.7),
                          ],
                        ),
                      ),
                      child: Icon(
                        _getIconData(preset.iconName),
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            preset.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            preset.description,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (action) => _handlePresetAction(action, preset),
                      color: const Color(0xFF2A2A2A),
                      icon: Icon(
                        Icons.more_vert,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, color: Color(0xFF00D4AA), size: 20),
                              SizedBox(width: 12),
                              Text('Edit', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red, size: 20),
                              SizedBox(width: 12),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black.withOpacity(0.3),
                  ),
                  child: Row(
                    children: [
                      _buildStatChip('${preset.totalSets} sets', Icons.repeat),
                      const SizedBox(width: 8),
                      _buildStatChip('${preset.setDurationSeconds}s work', Icons.play_arrow),
                      const SizedBox(width: 8),
                      _buildStatChip('${preset.restDurationSeconds}s rest', Icons.pause),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: _getCategoryColor(preset.category).withOpacity(0.2),
                      ),
                      child: Text(
                        preset.category,
                        style: TextStyle(
                          color: _getCategoryColor(preset.category),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      preset.estimatedDuration,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
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
      ),
    );
  }

  Widget _buildStatChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white70),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _showSaveCurrentTemplateDialog,
      backgroundColor: const Color(0xFF00D4AA),
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add),
      label: const Text('Save Current'),
    );
  }

  void _handlePresetAction(String action, PresetModel preset) {
    switch (action) {
      case 'edit':
        _editPreset(preset);
        break;
      case 'delete':
        _deletePreset(preset);
        break;
    }
  }

  void _loadPreset(PresetModel preset) {
    final timerController = Provider.of<TimerController>(context, listen: false);

    timerController.updateTimerSettings(
      totalSets: preset.totalSets,
      setDurationSeconds: preset.setDurationSeconds,
      restDurationSeconds: preset.restDurationSeconds,
      restAfterSets: preset.restAfterSets,
    );

    Navigator.of(context).pop();
    _showSuccessSnackBar('Template "${preset.name}" loaded successfully!');
  }

  void _editPreset(PresetModel preset) {
    showDialog(
      context: context,
      builder: (context) => _EditTemplateDialog(
        preset: preset,
        onSaved: _loadCustomPresets,
      ),
    );
  }

  Future<void> _deletePreset(PresetModel preset) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Delete Template', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "${preset.name}"? This action cannot be undone.',
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _presetService.deleteCustomPreset(preset.id);
        await _loadCustomPresets();
        _showSuccessSnackBar('Template "${preset.name}" deleted successfully!');
      } catch (e) {
        _showErrorSnackBar('Failed to delete template: $e');
      }
    }
  }

  void _showSaveCurrentTemplateDialog() {
    final timerController = Provider.of<TimerController>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => SaveTemplateDialog(
        currentSettings: timerController.getCurrentSettingsAsPreset(
          name: '',
          description: '',
        ),
        onSaved: _loadCustomPresets,
      ),
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

  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'timer':
        return Icons.timer;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'flash_on':
        return Icons.flash_on;
      case 'trending_up':
        return Icons.trending_up;
      case 'bolt':
        return Icons.bolt;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'sports_gymnastics':
        return Icons.sports_gymnastics;
      case 'directions_run':
        return Icons.directions_run;
      default:
        return Icons.timer;
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF00D4AA),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class _EditTemplateDialog extends StatefulWidget {
  final PresetModel preset;
  final VoidCallback? onSaved;

  const _EditTemplateDialog({
    required this.preset,
    this.onSaved,
  });

  @override
  State<_EditTemplateDialog> createState() => _EditTemplateDialogState();
}

class _EditTemplateDialogState extends State<_EditTemplateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final PresetService _presetService = PresetService();

  String _selectedCategory = 'Custom';
  String? _selectedIcon;
  bool _isLoading = false;

  final List<String> _predefinedCategories = [
    'Custom',
    'HIIT',
    'Core',
    'Endurance',
    'Strength',
    'Quick',
    'Cardio',
    'Recovery',
  ];

  final List<Map<String, String>> _iconOptions = [
    {'name': 'timer', 'label': 'Timer'},
    {'name': 'fitness_center', 'label': 'Fitness'},
    {'name': 'flash_on', 'label': 'Lightning'},
    {'name': 'trending_up', 'label': 'Trending Up'},
    {'name': 'bolt', 'label': 'Bolt'},
    {'name': 'local_fire_department', 'label': 'Fire'},
    {'name': 'sports_gymnastics', 'label': 'Gymnastics'},
    {'name': 'directions_run', 'label': 'Running'},
  ];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.preset.name;
    _descriptionController.text = widget.preset.description;
    _selectedCategory = widget.preset.category;
    _selectedIcon = widget.preset.iconName ?? _iconOptions.first['name'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveTemplate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedTemplate = widget.preset.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        iconName: _selectedIcon,
        updatedAt: DateTime.now(),
      );

      await _presetService.updateCustomPreset(updatedTemplate);

      if (mounted) {
        Navigator.of(context).pop(true);
        widget.onSaved?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Template "${updatedTemplate.name}" updated successfully!'),
            backgroundColor: const Color(0xFF00D4AA),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update template: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 600),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF00D4AA).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF00D4AA).withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00D4AA).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Color(0xFF00D4AA),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Edit Template',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    icon: const Icon(Icons.close, color: Colors.white70),
                    iconSize: 18,
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Template Name
                      const Text(
                        'Template Name',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Enter template name',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(color: Color(0xFF00D4AA), width: 2),
                          ),
                          contentPadding: const EdgeInsets.all(14),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a template name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Description
                      const Text(
                        'Description',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _descriptionController,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'Describe your workout routine...',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(color: Color(0xFF00D4AA), width: 2),
                          ),
                          contentPadding: const EdgeInsets.all(14),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Category
                      const Text(
                        'Category',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        dropdownColor: const Color(0xFF2A2A2A),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(color: Color(0xFF00D4AA), width: 2),
                          ),
                          contentPadding: const EdgeInsets.all(14),
                        ),
                        items: _predefinedCategories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 14),

                      // Icon Selection
                      const Text(
                        'Choose Icon',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 6,
                          mainAxisSpacing: 6,
                          childAspectRatio: 1.1,
                        ),
                        itemCount: _iconOptions.length,
                        itemBuilder: (context, index) {
                          final iconData = _iconOptions[index];
                          final isSelected = _selectedIcon == iconData['name'];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedIcon = iconData['name'];
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? const LinearGradient(
                                        colors: [Color(0xFF00D4AA), Color(0xFF00B4AA)],
                                      )
                                    : null,
                                color: isSelected ? null : Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF00D4AA) : Colors.white.withOpacity(0.2),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _getIconData(iconData['name']!),
                                    color: isSelected ? Colors.white : Colors.white70,
                                    size: 16,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    iconData['label']!,
                                    style: TextStyle(
                                      fontSize: 7,
                                      color: isSelected ? Colors.white : Colors.white70,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Action Buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: BorderSide(color: Colors.white.withOpacity(0.3)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveTemplate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00D4AA),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Update Template'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'timer':
        return Icons.timer;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'flash_on':
        return Icons.flash_on;
      case 'trending_up':
        return Icons.trending_up;
      case 'bolt':
        return Icons.bolt;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'sports_gymnastics':
        return Icons.sports_gymnastics;
      case 'directions_run':
        return Icons.directions_run;
      default:
        return Icons.timer;
    }
  }
}
