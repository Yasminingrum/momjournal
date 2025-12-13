import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// MoodSelector
/// Interactive mood selector with 5 emotion levels.
/// Provides visual and haptic feedback for mood selection.
///
/// Moods:
/// 1. Very Sad 😢
/// 2. Sad 😔
/// 3. Neutral 😐
/// 4. Happy 😊
/// 5. Very Happy 😄
///
/// Features:
/// - Animated selection
/// - Haptic feedback
/// - Color-coded moods
/// - Label display
/// - Customizable size
class MoodSelector extends StatefulWidget {

  const MoodSelector({
    required this.onMoodSelected, super.key,
    this.selectedMood,
    this.size = 56,
    this.showLabels = true,
    this.enableHaptics = true,
  });
  final MoodLevel? selectedMood;
  final Function(MoodLevel) onMoodSelected;
  final double size;
  final bool showLabels;
  final bool enableHaptics;

  @override
  State<MoodSelector> createState() => _MoodSelectorState();
}

class _MoodSelectorState extends State<MoodSelector>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  MoodLevel? _hoveredMood;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Mood buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: MoodLevel.values.map(_buildMoodButton).toList(),
        ),
        // Selected mood label
        if (widget.showLabels && widget.selectedMood != null) ...[
          const SizedBox(height: 16),
          Center(
            child: Text(
              widget.selectedMood!.label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: widget.selectedMood!.color,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ],
    );

  Widget _buildMoodButton(MoodLevel mood) {
    final isSelected = widget.selectedMood == mood;
    final isHovered = _hoveredMood == mood;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _hoveredMood = mood);
        _animationController.forward();
      },
      onTapUp: (_) {
        _animationController.reverse();
        _handleMoodSelection(mood);
      },
      onTapCancel: () {
        setState(() => _hoveredMood = null);
        _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          final scale = isHovered ? _scaleAnimation.value : 1.0;
          return Transform.scale(
            scale: scale,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? mood.color.withOpacity(0.2)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? mood.color
                      : Colors.grey.withOpacity(0.3),
                  width: isSelected ? 3 : 1,
                ),
              ),
              child: Center(
                child: Text(
                  mood.emoji,
                  style: TextStyle(
                    fontSize: widget.size * 0.5,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleMoodSelection(MoodLevel mood) {
    if (widget.enableHaptics) {
      HapticFeedback.mediumImpact();
    }
    setState(() => _hoveredMood = null);
    widget.onMoodSelected(mood);
  }
}

/// MoodLevel
/// Enum representing mood levels with associated properties
enum MoodLevel {
  verySad(
    emoji: '😢',
    label: 'Very Sad',
    color: Color(0xFFE53935),
    value: 1,
  ),
  sad(
    emoji: '😔',
    label: 'Sad',
    color: Color(0xFFFF9800),
    value: 2,
  ),
  neutral(
    emoji: '😐',
    label: 'Neutral',
    color: Color(0xFF9E9E9E),
    value: 3,
  ),
  happy(
    emoji: '😊',
    label: 'Happy',
    color: Color(0xFF66BB6A),
    value: 4,
  ),
  veryHappy(
    emoji: '😄',
    label: 'Very Happy',
    color: Color(0xFF4CAF50),
    value: 5,
  );

  final String emoji;
  final String label;
  final Color color;
  final int value;

  const MoodLevel({
    required this.emoji,
    required this.label,
    required this.color,
    required this.value,
  });

  /// Get mood level from value
  static MoodLevel? fromValue(int value) {
    try {
      return MoodLevel.values.firstWhere((mood) => mood.value == value);
    } catch (e) {
      return null;
    }
  }

  /// Get mood level from string
  static MoodLevel? fromString(String name) {
    try {
      return MoodLevel.values.firstWhere(
        (mood) => mood.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }
}

/// CompactMoodSelector
/// Smaller horizontal mood selector for forms
class CompactMoodSelector extends StatelessWidget {

  const CompactMoodSelector({
    required this.onMoodSelected, super.key,
    this.selectedMood,
  });
  final MoodLevel? selectedMood;
  final Function(MoodLevel) onMoodSelected;

  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: MoodLevel.values.map((mood) {
          final isSelected = selectedMood == mood;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onMoodSelected(mood);
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? mood.color.withOpacity(0.2)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? mood.color
                      : Colors.grey.withOpacity(0.3),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Center(
                child: Text(
                  mood.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
}

/// MoodIndicator
/// Read-only mood display
class MoodIndicator extends StatelessWidget {

  const MoodIndicator({
    required this.mood, super.key,
    this.size = 40,
    this.showLabel = true,
  });
  final MoodLevel mood;
  final double size;
  final bool showLabel;

  @override
  Widget build(BuildContext context) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: mood.color.withOpacity(0.1),
            border: Border.all(color: mood.color, width: 2),
          ),
          child: Center(
            child: Text(
              mood.emoji,
              style: TextStyle(fontSize: size * 0.5),
            ),
          ),
        ),
        if (showLabel) ...[
          const SizedBox(width: 8),
          Text(
            mood.label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: mood.color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ],
    );
}

/// MoodSelectorDialog
/// Full-screen dialog for mood selection
class MoodSelectorDialog extends StatefulWidget {

  const MoodSelectorDialog({
    super.key,
    this.initialMood,
    this.title,
    this.subtitle,
  });
  final MoodLevel? initialMood;
  final String? title;
  final String? subtitle;

  @override
  State<MoodSelectorDialog> createState() => _MoodSelectorDialogState();
}

class _MoodSelectorDialogState extends State<MoodSelectorDialog> {
  MoodLevel? _selectedMood;

  @override
  void initState() {
    super.initState();
    _selectedMood = widget.initialMood;
  }

  @override
  Widget build(BuildContext context) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            if (widget.title != null)
              Text(
                widget.title!,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            if (widget.subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                widget.subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            // Mood selector
            MoodSelector(
              selectedMood: _selectedMood,
              onMoodSelected: (mood) {
                setState(() => _selectedMood = mood);
              },
              size: 64,
            ),
            const SizedBox(height: 24),
            // Actions
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedMood == null
                        ? null
                        : () => Navigator.pop(context, _selectedMood),
                    child: const Text('Select'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

  static Future<MoodLevel?> show(
    BuildContext context, {
    MoodLevel? initialMood,
    String? title,
    String? subtitle,
  }) => showDialog<MoodLevel>(
      context: context,
      builder: (context) => MoodSelectorDialog(
        initialMood: initialMood,
        title: title ?? 'How are you feeling?',
        subtitle: subtitle,
      ),
    );
}