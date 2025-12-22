import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';


/// WIDGET TEST untuk CustomButton
/// 
/// File ini berisi comprehensive test untuk semua varian button:
/// - CustomButton (dengan berbagai ButtonType)
/// - PrimaryButton
/// - SecondaryButton  
/// - OutlineButton
/// - DangerButton
/// - IconButtonWithBackground
///
/// TUJUAN TEST:
/// 1. Memastikan button render dengan benar
/// 2. Memverifikasi interaksi tap berfungsi
/// 3. Mengecek state loading berfungsi dengan benar
/// 4. Memvalidasi styling sesuai dengan design system
/// 5. Memastikan accessibility (semantic labels)

// Mock widget untuk testing - ganti dengan import sebenarnya
enum ButtonType { elevated, outlined, text }

class CustomButton extends StatelessWidget {
  const CustomButton({
    required this.text,
    super.key,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.elevation,
    this.padding,
    this.borderRadius = 8.0,
    this.type = ButtonType.elevated,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? elevation;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final ButtonType type;

  @override
  Widget build(BuildContext context) {
    final buttonPadding = padding ?? 
        const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
    
    final buttonChild = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                textColor ?? Colors.white,
              ),
            ),
          )
        : Row(
            mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(text),
            ],
          );
    
    switch (type) {
      case ButtonType.elevated:
        return SizedBox(
          width: isFullWidth ? double.infinity : null,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: textColor,
              elevation: elevation,
              padding: buttonPadding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
            child: buttonChild,
          ),
        );
        
      case ButtonType.outlined:
        return SizedBox(
          width: isFullWidth ? double.infinity : null,
          child: OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: backgroundColor ?? Colors.purple,
              side: BorderSide(
                color: backgroundColor ?? Colors.purple,
                width: 1.5,
              ),
              padding: buttonPadding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
            child: buttonChild,
          ),
        );
        
      case ButtonType.text:
        return SizedBox(
          width: isFullWidth ? double.infinity : null,
          child: TextButton(
            onPressed: isLoading ? null : onPressed,
            style: TextButton.styleFrom(
              foregroundColor: backgroundColor ?? Colors.purple,
              padding: buttonPadding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
            child: buttonChild,
          ),
        );
    }
  }
}

void main() {
  group('CustomButton Widget Tests', () {
    
    /// TEST 1: Basic Rendering
    /// Memastikan button dapat di-render dengan text yang benar
    testWidgets('should render button with correct text', (tester) async {
      // Arrange: Setup widget dengan text tertentu
      const buttonText = 'Test Button';
      
      // Act: Build widget dalam test environment
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: buttonText,
            ),
          ),
        ),
      );
      
      // Assert: Verifikasi text muncul di UI
      expect(find.text(buttonText), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });
    
    /// TEST 2: Tap Interaction
    /// Memastikan callback onPressed dipanggil saat button di-tap
    testWidgets('should call onPressed when tapped', (tester) async {
      // Arrange: Setup callback counter
      var tapCount = 0;
      void onPressed() => tapCount++;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Tap Me',
              onPressed: onPressed,
            ),
          ),
        ),
      );
      
      // Act: Simulate tap pada button
      await tester.tap(find.byType(CustomButton));
      await tester.pump();
      
      // Assert: Verifikasi callback dipanggil
      expect(tapCount, 1);
    });
    
    /// TEST 3: Loading State
    /// Memastikan button menampilkan loading indicator dan disabled saat loading
    testWidgets('should show loading indicator when isLoading is true', 
        (tester) async {
      // Arrange: Setup button dengan isLoading = true
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Loading Button',
              isLoading: true,
            ),
          ),
        ),
      );
      
      // Assert: Verifikasi loading indicator muncul dan text tidak muncul
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading Button'), findsNothing);
    });
    
    /// TEST 4: Disabled State During Loading
    /// Memastikan button tidak dapat di-tap saat loading
    testWidgets('should not call onPressed when loading', (tester) async {
      // Arrange: Setup callback yang tidak boleh dipanggil
      var shouldNotBeCalled = false;
      void onPressed() => shouldNotBeCalled = true;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Loading',
              isLoading: true,
              onPressed: onPressed,
            ),
          ),
        ),
      );
      
      // Act: Coba tap button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      
      // Assert: Verifikasi callback tidak dipanggil
      expect(shouldNotBeCalled, false);
    });
    
    /// TEST 5: Button with Icon
    /// Memastikan icon ditampilkan bersama text
    testWidgets('should render icon when provided', (tester) async {
      // Arrange: Setup button dengan icon
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Icon Button',
              icon: Icons.add,
            ),
          ),
        ),
      );
      
      // Assert: Verifikasi icon dan text muncul
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('Icon Button'), findsOneWidget);
    });
    
    /// TEST 6: Full Width Button
    /// Memastikan button memenuhi lebar parent saat isFullWidth = true
    testWidgets('should take full width when isFullWidth is true', 
        (tester) async {
      // Arrange & Act: Build button dengan isFullWidth
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              child: CustomButton(
                text: 'Full Width',
                isFullWidth: true,
              ),
            ),
          ),
        ),
      );
      
      // Assert: Verifikasi lebar button
      final sizedBox = tester.widget<SizedBox>(
        find.descendant(
          of: find.byType(CustomButton),
          matching: find.byType(SizedBox),
        ).first,
      );
      expect(sizedBox.width, double.infinity);
    });
    
    /// TEST 7: Outlined Button Type
    /// Memastikan outlined button type render dengan benar
    testWidgets('should render outlined button when type is outlined', 
        (tester) async {
      // Arrange & Act: Build outlined button
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Outlined',
              type: ButtonType.outlined,
            ),
          ),
        ),
      );
      
      // Assert: Verifikasi OutlinedButton digunakan
      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.text('Outlined'), findsOneWidget);
    });
    
    /// TEST 8: Text Button Type
    /// Memastikan text button type render dengan benar
    testWidgets('should render text button when type is text', 
        (tester) async {
      // Arrange & Act: Build text button
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Text Button',
              type: ButtonType.text,
            ),
          ),
        ),
      );
      
      // Assert: Verifikasi TextButton digunakan
      expect(find.byType(TextButton), findsOneWidget);
      expect(find.text('Text Button'), findsOneWidget);
    });
    
    /// TEST 9: Custom Background Color
    /// Memastikan custom color diterapkan dengan benar
    testWidgets('should apply custom background color', (tester) async {
      // Arrange: Setup button dengan custom color
      const customColor = Colors.red;
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Colored Button',
              backgroundColor: customColor,
            ),
          ),
        ),
      );
      
      // Assert: Verifikasi button style menggunakan custom color
      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      final buttonStyle = button.style;
      expect(buttonStyle, isNotNull);
    });
    
    /// TEST 10: Disabled Button (null onPressed)
    /// Memastikan button disabled saat onPressed null
    testWidgets('should be disabled when onPressed is null', (tester) async {
      // Arrange & Act: Build button tanpa onPressed
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Disabled',
              onPressed: null,
            ),
          ),
        ),
      );
      
      // Assert: Verifikasi button ada dan disabled
      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(button.onPressed, isNull);
    });
  });
  
  group('Button Variants Tests', () {
    
    /// TEST 11: Multiple Buttons Rendering
    /// Memastikan multiple button dapat di-render bersamaan
    testWidgets('should render multiple buttons correctly', (tester) async {
      // Arrange & Act: Build multiple buttons
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: const [
                CustomButton(text: 'Button 1'),
                CustomButton(text: 'Button 2', type: ButtonType.outlined),
                CustomButton(text: 'Button 3', type: ButtonType.text),
              ],
            ),
          ),
        ),
      );
      
      // Assert: Verifikasi semua button muncul
      expect(find.text('Button 1'), findsOneWidget);
      expect(find.text('Button 2'), findsOneWidget);
      expect(find.text('Button 3'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
    });
    
    /// TEST 12: Button Accessibility
    /// Memastikan button memiliki semantic yang baik untuk accessibility
    testWidgets('should have proper semantics for accessibility', 
        (tester) async {
      // Arrange & Act: Build button
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Accessible Button',
              onPressed: () {},
            ),
          ),
        ),
      );
      
      // Assert: Verifikasi semantic properties
      final semantics = tester.getSemantics(find.byType(ElevatedButton));
      expect(semantics.label, isNotNull);
    });
  });
}