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
      appBar: AppBar(
        title: const Text('Template Management'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.file_upload),
                    SizedBox(width: 8),
                    Text('Import Template'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'help',
                child: Row(
                  children: [
                    Icon(Icons.help_outline),
                    SizedBox(width: 8),
                    Text('Help'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter
          if (_categories.length > 1) ...[
            Container(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories.map((category) {
                    final isSelected = _selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          }
                        },
                        selectedColor: Colors.blue[100],
                        checkmarkColor: Colors.blue[800],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const Divider(height: 1),
          ],

          // Content
          Expanded(
            child: _isLoading ? const Center(child: CircularProgressIndicator()) : _buildContent(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showSaveCurrentTemplateDialog,
        icon: const Icon(Icons.add),
        label: const Text('Save Current'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
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
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredPresets.length,
        itemBuilder: (context, index) {
          return _buildPresetCard(filteredPresets[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_add_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _customPresets.isEmpty ? 'No Custom Templates' : 'No Templates in "$_selectedCategory"',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
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
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _showSaveCurrentTemplateDialog,
            icon: const Icon(Icons.add),
            label: const Text('Save Current Settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetCard(PresetModel preset) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Icon(
            _getIconData(preset.iconName),
            color: Colors.blue[800],
          ),
        ),
        title: Text(
          preset.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(preset.description),
            const SizedBox(height: 4),
            Text(
              '${preset.totalSets} sets • ${preset.formattedDuration} • ${preset.category}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (action) => _handlePresetAction(action, preset),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'load',
              child: Row(
                children: [
                  Icon(Icons.play_arrow),
                  SizedBox(width: 8),
                  Text('Load Template'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'export',
              child: Row(
                children: [
                  Icon(Icons.share),
                  SizedBox(width: 8),
                  Text('Export'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: () => _loadPreset(preset),
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'import':
        _importTemplate();
        break;
      case 'help':
        _showHelpDialog();
        break;
    }
  }

  void _handlePresetAction(String action, PresetModel preset) {
    switch (action) {
      case 'load':
        _loadPreset(preset);
        break;
      case 'edit':
        _editPreset(preset);
        break;
      case 'export':
        _exportPreset(preset);
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
    // TODO: Implement edit functionality in a future update
    _showInfoSnackBar('Edit functionality coming soon!');
  }

  Future<void> _exportPreset(PresetModel preset) async {
    try {
      await _presetService.exportPresetToFile(preset);
      _showSuccessSnackBar('Template exported successfully!');
    } catch (e) {
      _showErrorSnackBar('Failed to export template: $e');
    }
  }

  Future<void> _deletePreset(PresetModel preset) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Template'),
        content: Text('Are you sure you want to delete "${preset.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
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

  Future<void> _importTemplate() async {
    try {
      final preset = await _presetService.importPresetFromFile();
      if (preset != null) {
        // Check for name conflicts
        final nameExists = await _presetService.presetNameExists(preset.name);
        PresetModel finalPreset = preset;

        if (nameExists) {
          finalPreset = preset.copyWith(
            name: '${preset.name} (Imported)',
          );
        }

        await _presetService.saveCustomPreset(finalPreset);
        await _loadCustomPresets();
        _showSuccessSnackBar('Template imported successfully!');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to import template: $e');
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

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Template Management Help'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('• Tap a template to load it into the timer'),
              SizedBox(height: 8),
              Text('• Use the menu button (⋮) for more options'),
              SizedBox(height: 8),
              Text('• Export templates to share with friends'),
              SizedBox(height: 8),
              Text('• Import templates from JSON files'),
              SizedBox(height: 8),
              Text('• Create new templates by saving current timer settings'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
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
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
