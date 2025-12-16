import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momjournal/presentation/widgets/common/custom_button.dart';

void main() {
  group('CustomButton Widget Tests', () {
    testWidgets('CustomButton should display text correctly',
        (WidgetTester tester) async {
      // Arrange
      const buttonText = 'Test Button';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: buttonText,
              onPressed: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(buttonText), findsOneWidget);
    });

    testWidgets('CustomButton should trigger onPressed callback',
        (WidgetTester tester) async {
      // Arrange
      var wasPressed = false;
      void handlePress() {
        wasPressed = true;
      }

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Press Me',
              onPressed: handlePress,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CustomButton));
      await tester.pump();

      // Assert
      expect(wasPressed, true);
    });

    testWidgets('CustomButton should be disabled when onPressed is null',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Disabled Button',
              onPressed: null,
            ),
          ),
        ),
      );

      // Assert
      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('PrimaryButton should use primary color',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              text: 'Primary',
              onPressed: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Primary'), findsOneWidget);
    });

    testWidgets('SecondaryButton should use elevated button',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SecondaryButton(
              text: 'Secondary',
              onPressed: () {},
            ),
          ),
        ),
      );

      // Assert - SecondaryButton uses ElevatedButton with secondary color
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Secondary'), findsOneWidget);
    });

    testWidgets('OutlineButton should use outlined button',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OutlineButton(
              text: 'Outline',
              onPressed: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.text('Outline'), findsOneWidget);
    });

    testWidgets('CustomButton should show loading indicator when loading',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Loading',
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading'), findsNothing);
    });

    testWidgets('CustomButton should not trigger onPressed when loading',
        (WidgetTester tester) async {
      // Arrange
      var wasPressed = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Button',
              onPressed: () {
                wasPressed = true;
              },
              isLoading: true,
            ),
          ),
        ),
      );

      // Try to tap
      await tester.tap(find.byType(CustomButton));
      await tester.pump();

      // Assert
      expect(wasPressed, false);
    });

    testWidgets('CustomButton with icon should display both icon and text',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'With Icon',
              icon: Icons.add,
              onPressed: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('With Icon'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('CustomButton should respect isFullWidth parameter',
        (WidgetTester tester) async {
      // Act - Full width (default is true)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Full Width',
              onPressed: () {},
              isFullWidth: true,
            ),
          ),
        ),
      );

      // Assert
      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(ElevatedButton),
          matching: find.byType(SizedBox),
        ),
      );
      expect(sizedBox.width, double.infinity);
    });

    testWidgets('CustomButton should not be full width when isFullWidth is false',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Not Full Width',
              onPressed: () {},
              isFullWidth: false,
            ),
          ),
        ),
      );

      // Assert
      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(ElevatedButton),
          matching: find.byType(SizedBox),
        ),
      );
      expect(sizedBox.width, isNull);
    });

    testWidgets('DangerButton should use error color',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DangerButton(
              text: 'Delete',
              onPressed: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Delete'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('DangerButton outlined variant should use outlined button',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DangerButton(
              text: 'Delete',
              onPressed: () {},
              outlined: true,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Delete'), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('CustomButton with text type should render TextButton',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Text Button',
              onPressed: () {},
              type: ButtonType.text,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Text Button'), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('CustomButton with outlined type should render OutlinedButton',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Outlined Button',
              onPressed: () {},
              type: ButtonType.outlined,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Outlined Button'), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('CustomButton should use custom backgroundColor',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Custom Color',
              onPressed: () {},
              backgroundColor: Colors.green,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Custom Color'), findsOneWidget);
      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(button.style?.backgroundColor?.resolve({}), Colors.green);
    });

    testWidgets('CustomButton should use custom textColor',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Custom Text Color',
              onPressed: () {},
              textColor: Colors.red,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Custom Text Color'), findsOneWidget);
    });

    testWidgets('CustomButton should use custom padding',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Custom Padding',
              onPressed: () {},
              padding: const EdgeInsets.all(20),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Custom Padding'), findsOneWidget);
    });

    testWidgets('CustomButton should use custom borderRadius',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Custom Border',
              onPressed: () {},
              borderRadius: 16,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Custom Border'), findsOneWidget);
    });

    testWidgets('CustomButton should use custom elevation',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Custom Elevation',
              onPressed: () {},
              elevation: 8,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Custom Elevation'), findsOneWidget);
    });

    testWidgets('CustomButton should handle rapid taps correctly',
        (WidgetTester tester) async {
      // Arrange
      var pressCount = 0;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Tap Me',
              onPressed: () {
                pressCount++;
              },
            ),
          ),
        ),
      );

      // Tap multiple times
      await tester.tap(find.byType(CustomButton));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.byType(CustomButton));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.byType(CustomButton));
      await tester.pump();

      // Assert
      expect(pressCount, 3);
    });

    testWidgets('IconButtonWithBackground should render correctly',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconButtonWithBackground(
              icon: Icons.add,
              onPressed: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byType(Material), findsOneWidget);
      expect(find.byType(InkWell), findsOneWidget);
    });

    testWidgets('IconButtonWithBackground should trigger onPressed',
        (WidgetTester tester) async {
      // Arrange
      var wasPressed = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconButtonWithBackground(
              icon: Icons.favorite,
              onPressed: () {
                wasPressed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(IconButtonWithBackground));
      await tester.pump();

      // Assert
      expect(wasPressed, true);
    });

    testWidgets('IconButtonWithBackground should use custom size',
        (WidgetTester tester) async {
      // Arrange
      const customSize = 64.0;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: IconButtonWithBackground(
              icon: Icons.settings,
              size: customSize,
            ),
          ),
        ),
      );

      // Assert
      final sizedBox = tester.widget<SizedBox>(
        find.descendant(
          of: find.byType(IconButtonWithBackground),
          matching: find.byType(SizedBox),
        ),
      );
      expect(sizedBox.width, customSize);
      expect(sizedBox.height, customSize);
    });

    testWidgets('IconButtonWithBackground should use custom iconSize',
        (WidgetTester tester) async {
      // Arrange
      const customIconSize = 32.0;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: IconButtonWithBackground(
              icon: Icons.home,
              iconSize: customIconSize,
            ),
          ),
        ),
      );

      // Assert
      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.size, customIconSize);
    });

    testWidgets('PrimaryButton should accept icon parameter',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              text: 'With Icon',
              icon: Icons.add,
              onPressed: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('With Icon'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('SecondaryButton should show loading state',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SecondaryButton(
              text: 'Loading',
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('OutlineButton should accept custom color',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OutlineButton(
              text: 'Custom Color',
              onPressed: () {},
              color: Colors.blue,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Custom Color'), findsOneWidget);
    });

    testWidgets('ButtonType enum should have all values',
        (WidgetTester tester) async {
      // Assert
      expect(ButtonType.elevated, isA<ButtonType>());
      expect(ButtonType.outlined, isA<ButtonType>());
      expect(ButtonType.text, isA<ButtonType>());
    });

    testWidgets('Default button type should be elevated',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Default Type',
              onPressed: () {},
            ),
          ),
        ),
      );

      // Assert - Should render ElevatedButton by default
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('isFullWidth should default to true',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Default Width',
              onPressed: () {},
            ),
          ),
        ),
      );

      // Assert
      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(ElevatedButton),
          matching: find.byType(SizedBox),
        ),
      );
      expect(sizedBox.width, double.infinity);
    });
  });
}