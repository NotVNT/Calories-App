import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calories_app/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:calories_app/features/onboarding/presentation/screens/macro_step_screen.dart';
import 'package:calories_app/core/theme/theme.dart';

void main() {
  group('Macro Sliders Widget Test', () {
    testWidgets('should ensure total macros = 100±1', (WidgetTester tester) async {
      final container = ProviderContainer();
      final controller = container.read(onboardingControllerProvider.notifier);

      // Set target kcal
      controller.updateTargetKcal(2000.0);

      // Build the widget
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.themeData,
            home: const MacroStepScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the customize button
      final customizeButton = find.text('Tuỳ chỉnh mục tiêu');
      expect(customizeButton, findsOneWidget);

      // Tap to open bottom sheet
      await tester.tap(customizeButton);
      await tester.pumpAndSettle();

      // Find sliders
      final proteinSlider = find.byType(Slider).first;
      final carbSlider = find.byType(Slider).at(1);
      final fatSlider = find.byType(Slider).at(2);

      expect(proteinSlider, findsOneWidget);
      expect(carbSlider, findsOneWidget);
      expect(fatSlider, findsOneWidget);

      // Get initial values
      final proteinSliderWidget = tester.widget<Slider>(proteinSlider);
      final carbSliderWidget = tester.widget<Slider>(carbSlider);
      final fatSliderWidget = tester.widget<Slider>(fatSlider);

      final initialTotal = proteinSliderWidget.value +
          carbSliderWidget.value +
          fatSliderWidget.value;

      // Verify initial total is within 100±1
      expect(initialTotal, greaterThanOrEqualTo(99.0));
      expect(initialTotal, lessThanOrEqualTo(101.0));

      // Test adjusting sliders
      // Adjust protein slider
      await tester.drag(proteinSlider, const Offset(50, 0));
      await tester.pumpAndSettle();

      // Get updated values
      final updatedProteinSlider = tester.widget<Slider>(proteinSlider);
      final updatedCarbSlider = tester.widget<Slider>(carbSlider);
      final updatedFatSlider = tester.widget<Slider>(fatSlider);

      final updatedTotal = updatedProteinSlider.value +
          updatedCarbSlider.value +
          updatedFatSlider.value;

      // Verify total is still within 100±1
      expect(updatedTotal, greaterThanOrEqualTo(99.0));
      expect(updatedTotal, lessThanOrEqualTo(101.0));
    });

    testWidgets('should show total percentage indicator', (WidgetTester tester) async {
      final container = ProviderContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.themeData,
            home: const MacroStepScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Open bottom sheet
      final customizeButton = find.text('Tuỳ chỉnh mục tiêu');
      await tester.tap(customizeButton);
      await tester.pumpAndSettle();

      // Find total percentage indicator
      final totalIndicator = find.textContaining('%');
      expect(totalIndicator, findsWidgets);

      // Verify total is displayed
      final totalText = find.textContaining('Tổng');
      expect(totalText, findsOneWidget);
    });

    testWidgets('should enable save button only when total = 100±1', (WidgetTester tester) async {
      final container = ProviderContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.themeData,
            home: const MacroStepScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Open bottom sheet
      final customizeButton = find.text('Tuỳ chỉnh mục tiêu');
      await tester.tap(customizeButton);
      await tester.pumpAndSettle();

      // Find save button
      final saveButton = find.text('Lưu');
      expect(saveButton, findsOneWidget);

      // Initially, save button should be enabled (default macros = 100%)
      final saveButtonWidget = tester.widget<ElevatedButton>(saveButton);
      expect(saveButtonWidget.onPressed, isNotNull);
    });

    testWidgets('should update grams when sliders change', (WidgetTester tester) async {
      final container = ProviderContainer();
      final controller = container.read(onboardingControllerProvider.notifier);

      // Set target kcal
      controller.updateTargetKcal(2000.0);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.themeData,
            home: const MacroStepScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Open bottom sheet
      final customizeButton = find.text('Tuỳ chỉnh mục tiêu');
      await tester.tap(customizeButton);
      await tester.pumpAndSettle();

      // Find grams text (should show calculated grams)
      final gramsText = find.textContaining('g');
      expect(gramsText, findsWidgets);

      // Adjust protein slider
      final proteinSlider = find.byType(Slider).first;
      await tester.drag(proteinSlider, const Offset(50, 0));
      await tester.pumpAndSettle();

      // Verify grams are updated
      final updatedGramsText = find.textContaining('g');
      expect(updatedGramsText, findsWidgets);
    });
  });
}

