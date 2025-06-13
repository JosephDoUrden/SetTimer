import 'package:flutter/material.dart';
import '../models/preset_model.dart';
import '../services/preset_service.dart';

class SaveTemplateDialog extends StatefulWidget {
  final PresetModel currentSettings;
  final VoidCallback? onSaved;

  const SaveTemplateDialog({
    super.key,
    required this.currentSettings,
    this.onSaved,
  });

  @override
  State<SaveTemplateDialog> createState() => _SaveTemplateDialogState();
}

class _SaveTemplateDialogState extends State<SaveTemplateDialog> {
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
    _selectedIcon = _iconOptions.first['name'];
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
      final template = PresetModel.createCustom(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        totalSets: widget.currentSettings.totalSets,
        setDurationSeconds: widget.currentSettings.setDurationSeconds,
        restDurationSeconds: widget.currentSettings.restDurationSeconds,
        restAfterSets: widget.currentSettings.restAfterSets,
        category: _selectedCategory,
        iconName: _selectedIcon,
      );

      await _presetService.saveCustomPreset(template);

      if (mounted) {
        Navigator.of(context).pop(true);
        widget.onSaved?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Template "${template.name}" saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save template: $e'),
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
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 400;
    final maxWidth = isSmallScreen ? screenSize.width * 0.95 : 400.0;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 16 : 32,
        vertical: 24,
      ),
      child: Container(
        width: maxWidth,
        constraints: BoxConstraints(
          maxHeight: screenSize.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF00D4AA).withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00D4AA).withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF00D4AA).withOpacity(0.1),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00D4AA).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.bookmark_add,
                      color: Color(0xFF00D4AA),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Save as Template',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Current Settings Preview
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF00D4AA).withOpacity(0.1),
                              const Color(0xFF00D4AA).withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF00D4AA).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  color: Color(0xFF00D4AA),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Current Workout Settings',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              runSpacing: 8,
                              children: [
                                _buildSettingChip('${widget.currentSettings.totalSets} sets', Icons.repeat),
                                _buildSettingChip('${widget.currentSettings.setDurationSeconds}s work', Icons.play_arrow),
                                _buildSettingChip('${widget.currentSettings.restDurationSeconds}s rest', Icons.pause),
                                _buildSettingChip('Rest after ${widget.currentSettings.restAfterSets}', Icons.schedule),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Template Name
                      _buildInputSection(
                        'Template Name',
                        TextFormField(
                          controller: _nameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: _buildInputDecoration(
                            'e.g., My Custom HIIT',
                            Icons.edit,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a template name';
                            }
                            if (value.trim().length < 3) {
                              return 'Name must be at least 3 characters';
                            }
                            if (value.trim().length > 50) {
                              return 'Name must be less than 50 characters';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            if (value.trim().isNotEmpty) {
                              _checkNameConflict(value.trim());
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Description
                      _buildInputSection(
                        'Description',
                        TextFormField(
                          controller: _descriptionController,
                          style: const TextStyle(color: Colors.white),
                          maxLines: 3,
                          decoration: _buildInputDecoration(
                            'Describe your workout routine...',
                            Icons.description,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a description';
                            }
                            if (value.trim().length < 10) {
                              return 'Description must be at least 10 characters';
                            }
                            if (value.trim().length > 200) {
                              return 'Description must be less than 200 characters';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Category and Icon Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category Selection
                          Expanded(
                            flex: 2,
                            child: _buildInputSection(
                              'Category',
                              DropdownButtonFormField<String>(
                                value: _selectedCategory,
                                style: const TextStyle(color: Colors.white),
                                dropdownColor: const Color(0xFF2A2A2A),
                                decoration: _buildInputDecoration(
                                  'Select category',
                                  Icons.category,
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
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Icon Selection
                      _buildInputSection(
                        'Choose Icon',
                        Column(
                          children: [
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: isSmallScreen ? 4 : 5,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                childAspectRatio: 1,
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
                                      borderRadius: BorderRadius.circular(12),
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
                                          size: isSmallScreen ? 20 : 24,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          iconData['label']!,
                                          style: TextStyle(
                                            fontSize: isSmallScreen ? 8 : 10,
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
                    ],
                  ),
                ),
              ),
            ),

            // Action Buttons
            Container(
              padding: const EdgeInsets.all(24),
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
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveTemplate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00D4AA),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        shadowColor: const Color(0xFF00D4AA).withOpacity(0.3),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.save, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Save Template',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
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
  }

  Widget _buildSettingChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.white70,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.white.withOpacity(0.5),
        fontSize: 14,
      ),
      prefixIcon: Icon(
        icon,
        color: const Color(0xFF00D4AA),
        size: 20,
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF00D4AA),
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.all(16),
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

  Future<void> _checkNameConflict(String name) async {
    try {
      final exists = await _presetService.presetNameExists(name);
      if (exists && mounted) {
        // Show a subtle warning (you could implement this if needed)
        // For now, we'll handle it in the validator
      }
    } catch (e) {
      // Handle error silently for real-time validation
    }
  }
}
