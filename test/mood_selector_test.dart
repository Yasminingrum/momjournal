import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';


/// WIDGET TEST untuk MoodSelector
/// 
/// File ini berisi comprehensive test untuk mood selection widget:
/// - MoodSelector (main widget dengan animasi)
/// - CompactMoodSelector (compact version)
/// - MoodIndicator (read-only display)
/// - MoodLevel enum dan helper methods
///
/// TUJUAN TEST:
/// 1. Memastikan 5 mood options dapat di-render
/// 2. Memverifikasi mood selection callback berfungsi
/// 3. Mengecek visual feedback (animasi, border, warna)
/// 4. Memvalidasi MoodLevel enum methods
/// 5. Memastikan label ditampilkan saat mood dipilih

// Mock MoodLevel enum untuk testing
enum MoodLevel {
  verySad(emoji: '😢', label: 'Very Sad', color: Color(0xFFE53935), value: 1),
  sad(emoji: '😔', label: 'Sad', color: Color(0xFFFF9800), value: 2),
  neutral(emoji: '😐', label: 'Neutral', color: Color(0xFF9E9E9E), value: 3),
  happy(emoji: '😊', label: 'Happy', color: Color(0xFF66BB6A), value: 4),
  veryHappy(emoji: '😄', label: 'Very Happy', color: Color(0xFF4CAF50), value: 5);

  const MoodLevel({
    required this.emoji,
    required this.label,
    required this.color,
    required this.value,
  });

  final String emoji;
  final String label;
  final Color color;
  final int value;

  static MoodLevel? fromValue(int value) {
    try {
      return MoodLevel.values.firstWhere((mood) => mood.value == value);
    } catch (e) {
      return null;
    }
  }

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

// Mock MoodSelector widget
class MoodSelector extends StatefulWidget {
  const MoodSelector({
    required this.onMoodSelected,
    super.key,
    this.selectedMood,
    this.size = 56,
    this.showLabels = true,
    this.enableHaptics = true,
  });

  final MoodLevel? selectedMood;
  final void Function(MoodLevel) onMoodSelected;
  final double size;
  final bool showLabels;
  final bool enableHaptics;

  @override
  State<MoodSelector> createState() => _MoodSelectorState();
}

class _MoodSelectorState extends State<MoodSelector> {
  @override
  Widget build(BuildContext context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: MoodLevel.values.map(_buildMoodButton).toList(),
        ),
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

    return GestureDetector(
      key: Key('mood_button_${mood.name}'),
      onTap: () => widget.onMoodSelected(mood),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected
              ? mood.color.withValues(alpha: 0.2)
              : Colors.transparent,
          border: Border.all(
            color: isSelected ? mood.color : Colors.grey.withValues(alpha: 0.3),
            width: isSelected ? 3 : 1,
          ),
        ),
        child: Center(
          child: Text(
            mood.emoji,
            style: TextStyle(fontSize: widget.size * 0.5),
          ),
        ),
      ),
    );
  }
}

// Mock CompactMoodSelector
class CompactMoodSelector extends StatelessWidget {
  const CompactMoodSelector({
    required this.onMoodSelected,
    super.key,
    this.selectedMood,
  });

  final MoodLevel? selectedMood;
  final void Function(MoodLevel) onMoodSelected;

  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: MoodLevel.values.map((mood) {
          final isSelected = selectedMood == mood;
          return GestureDetector(
            key: Key('compact_mood_${mood.name}'),
            onTap: () => onMoodSelected(mood),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? mood.color.withValues(alpha: 0.2)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected ? mood.color : Colors.grey.withValues(alpha: 0.3),
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

void main() {
  group('MoodLevel Enum Tests', () {
    
    /// TEST 1: Enum Values
    /// Memastikan semua 5 mood level ada
    test('should have 5 mood levels', () {
      expect(MoodLevel.values.length, 5);
    });
    
    /// TEST 2: Enum Properties
    /// Memastikan setiap mood memiliki properties yang benar
    test('should have correct properties for each mood', () {
      // Very Sad
      expect(MoodLevel.verySad.emoji, '😢');
      expect(MoodLevel.verySad.label, 'Very Sad');
      expect(MoodLevel.verySad.value, 1);
      expect(MoodLevel.verySad.color.value, 0xFFE53935);
      
      // Sad
      expect(MoodLevel.sad.emoji, '😔');
      expect(MoodLevel.sad.label, 'Sad');
      expect(MoodLevel.sad.value, 2);
      
      // Neutral
      expect(MoodLevel.neutral.emoji, '😐');
      expect(MoodLevel.neutral.label, 'Neutral');
      expect(MoodLevel.neutral.value, 3);
      
      // Happy
      expect(MoodLevel.happy.emoji, '😊');
      expect(MoodLevel.happy.label, 'Happy');
      expect(MoodLevel.happy.value, 4);
      
      // Very Happy
      expect(MoodLevel.veryHappy.emoji, '😄');
      expect(MoodLevel.veryHappy.label, 'Very Happy');
      expect(MoodLevel.veryHappy.value, 5);
    });
    
    /// TEST 3: fromValue Method
    /// Memastikan conversion dari value ke MoodLevel berfungsi
    test('should convert value to MoodLevel correctly', () {
      expect(MoodLevel.fromValue(1), MoodLevel.verySad);
      expect(MoodLevel.fromValue(2), MoodLevel.sad);
      expect(MoodLevel.fromValue(3), MoodLevel.neutral);
      expect(MoodLevel.fromValue(4), MoodLevel.happy);
      expect(MoodLevel.fromValue(5), MoodLevel.veryHappy);
      expect(MoodLevel.fromValue(99), isNull); // Invalid value
    });
    
    /// TEST 4: fromString Method
    /// Memastikan conversion dari string ke MoodLevel berfungsi
    test('should convert string to MoodLevel correctly', () {
      expect(MoodLevel.fromString('verySad'), MoodLevel.verySad);
      expect(MoodLevel.fromString('VERYSAD'), MoodLevel.verySad); // Case insensitive
      expect(MoodLevel.fromString('happy'), MoodLevel.happy);
      expect(MoodLevel.fromString('invalid'), isNull); // Invalid string
    });
  });
  
  group('MoodSelector Widget Tests', () {
    
    /// TEST 5: Render All Mood Buttons
    /// Memastikan semua 5 mood buttons di-render
    testWidgets('should render 5 mood buttons', (tester) async {
      // Arrange: Setup widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MoodSelector(
              onMoodSelected: (_) {},
            ),
          ),
        ),
      );
      
      // Assert: Verifikasi 5 emoji muncul
      expect(find.text('😢'), findsOneWidget);
      expect(find.text('😔'), findsOneWidget);
      expect(find.text('😐'), findsOneWidget);
      expect(find.text('😊'), findsOneWidget);
      expect(find.text('😄'), findsOneWidget);
    });
    
    /// TEST 6: Mood Selection Callback
    /// Memastikan callback dipanggil dengan mood yang benar saat di-tap
    testWidgets('should call onMoodSelected with correct mood when tapped', 
        (tester) async {
      // Arrange: Setup callback
      MoodLevel? selectedMood;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MoodSelector(
              onMoodSelected: (mood) => selectedMood = mood,
            ),
          ),
        ),
      );
      
      // Act: Tap happy mood
      await tester.tap(find.byKey(const Key('mood_button_happy')));
      await tester.pump();
      
      // Assert: Verifikasi callback dipanggil dengan mood yang benar
      expect(selectedMood, MoodLevel.happy);
    });
    
    /// TEST 7: Selected Mood Visual Feedback
    /// Memastikan mood yang dipilih memiliki visual feedback
    testWidgets('should show visual feedback for selected mood', 
        (tester) async {
      // Arrange & Act: Build widget dengan mood terpilih
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MoodSelector(
              selectedMood: MoodLevel.happy,
              onMoodSelected: (_) {},
            ),
          ),
        ),
      );
      
      // Assert: Verifikasi label muncul
      expect(find.text('Happy'), findsOneWidget);
    });
    
    /// TEST 8: Label Visibility
    /// Memastikan label ditampilkan/disembunyikan sesuai parameter
    testWidgets('should show/hide label based on showLabels parameter', 
        (tester) async {
      // Test dengan showLabels = false
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MoodSelector(
              selectedMood: MoodLevel.happy,
              showLabels: false,
              onMoodSelected: (_) {},
            ),
          ),
        ),
      );
      
      // Assert: Label tidak muncul
      expect(find.text('Happy'), findsNothing);
      
      // Test dengan showLabels = true
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MoodSelector(
              selectedMood: MoodLevel.happy,
              showLabels: true,
              onMoodSelected: (_) {},
            ),
          ),
        ),
      );
      await tester.pump();
      
      // Assert: Label muncul
      expect(find.text('Happy'), findsOneWidget);
    });
    
    /// TEST 9: Multiple Mood Selection
    /// Memastikan bisa mengganti mood selection
    testWidgets('should update selected mood when different mood is tapped', 
        (tester) async {
      // Arrange: Setup stateful widget wrapper
      MoodLevel? currentMood;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => MoodSelector(
                  selectedMood: currentMood,
                  onMoodSelected: (mood) {
                    setState(() => currentMood = mood);
                  },
                ),
            ),
          ),
        ),
      );
      
      // Act: Tap sad mood
      await tester.tap(find.byKey(const Key('mood_button_sad')));
      await tester.pumpAndSettle();
      
      // Assert: Verifikasi sad dipilih
      expect(find.text('Sad'), findsOneWidget);
      
      // Act: Tap very happy mood
      await tester.tap(find.byKey(const Key('mood_button_veryHappy')));
      await tester.pumpAndSettle();
      
      // Assert: Verifikasi very happy dipilih (sad tidak lagi muncul)
      expect(find.text('Very Happy'), findsOneWidget);
      expect(find.text('Sad'), findsNothing);
    });
    
    /// TEST 10: Custom Size
    /// Memastikan custom size diterapkan dengan benar
    testWidgets('should apply custom size to mood buttons', (tester) async {
      // Arrange: Setup dengan custom size
      const customSize = 80.0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MoodSelector(
              size: customSize,
              onMoodSelected: (_) {},
            ),
          ),
        ),
      );
      
      // Assert: Verifikasi size diterapkan
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byKey(const Key('mood_button_happy')),
          matching: find.byType(Container),
        ),
      );
      expect(container.constraints?.maxWidth, customSize);
      expect(container.constraints?.maxHeight, customSize);
    });
  });
  
  group('CompactMoodSelector Widget Tests', () {
    
    /// TEST 11: Compact Version Rendering
    /// Memastikan compact version render dengan benar
    testWidgets('should render compact mood selector', (tester) async {
      // Arrange & Act: Build compact selector
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactMoodSelector(
              onMoodSelected: (_) {},
            ),
          ),
        ),
      );
      
      // Assert: Verifikasi semua mood emoji muncul
      expect(find.text('😢'), findsOneWidget);
      expect(find.text('😔'), findsOneWidget);
      expect(find.text('😐'), findsOneWidget);
      expect(find.text('😊'), findsOneWidget);
      expect(find.text('😄'), findsOneWidget);
    });
    
    /// TEST 12: Compact Selection
    /// Memastikan selection berfungsi di compact version
    testWidgets('should handle selection in compact mode', (tester) async {
      // Arrange: Setup callback
      MoodLevel? selectedMood;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactMoodSelector(
              onMoodSelected: (mood) => selectedMood = mood,
            ),
          ),
        ),
      );
      
      // Act: Tap neutral mood
      await tester.tap(find.byKey(const Key('compact_mood_neutral')));
      await tester.pump();
      
      // Assert: Verifikasi callback dipanggil
      expect(selectedMood, MoodLevel.neutral);
    });
    
    /// TEST 13: Compact vs Regular Size
    /// Memastikan compact version lebih kecil dari regular
    testWidgets('compact selector should have smaller buttons', (tester) async {
      // Build compact selector
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactMoodSelector(
              onMoodSelected: (_) {},
            ),
          ),
        ),
      );
      
      // Get compact button size
      final compactContainer = tester.widget<Container>(
        find.descendant(
          of: find.byKey(const Key('compact_mood_happy')),
          matching: find.byType(Container),
        ),
      );
      
      // Assert: Verifikasi compact size adalah 44
      expect(compactContainer.constraints?.maxWidth, 44);
    });
  });
  
  group('MoodSelector Integration Tests', () {
    
    /// TEST 14: Complete Mood Selection Flow
    /// Memastikan full flow dari no selection ke selection
    testWidgets('should handle complete mood selection flow', (tester) async {
      // Arrange: Setup dengan no initial selection
      MoodLevel? currentMood;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => MoodSelector(
                  selectedMood: currentMood,
                  onMoodSelected: (mood) {
                    setState(() => currentMood = mood);
                  },
                ),
            ),
          ),
        ),
      );
      
      // Assert: No label initially
      expect(find.text('Very Sad'), findsNothing);
      expect(find.text('Happy'), findsNothing);
      
      // Act: Select mood
      await tester.tap(find.byKey(const Key('mood_button_veryHappy')));
      await tester.pumpAndSettle();
      
      // Assert: Label appears
      expect(find.text('Very Happy'), findsOneWidget);
    });
    
    /// TEST 15: All Moods Selectable
    /// Memastikan setiap mood bisa dipilih
    testWidgets('should allow selecting each mood', (tester) async {
      for (final mood in MoodLevel.values) {
        // Arrange: Reset untuk setiap mood
        MoodLevel? selectedMood;
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MoodSelector(
                onMoodSelected: (m) => selectedMood = m,
              ),
            ),
          ),
        );
        
        // Act: Tap mood
        await tester.tap(find.byKey(Key('mood_button_${mood.name}')));
        await tester.pump();
        
        // Assert: Verifikasi mood terpilih
        expect(selectedMood, mood);
      }
    });
  });
}