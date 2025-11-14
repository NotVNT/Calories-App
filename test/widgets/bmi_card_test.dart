import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calories_app/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:calories_app/features/onboarding/presentation/screens/current_weight_step_screen.dart';
import 'package:calories_app/core/theme/theme.dart';

void main() {
  group('BMI Card Widget Test', () {
    testWidgets('should display BMI card with calculated BMI', (WidgetTester tester) async {
      // Create a ProviderScope with OnboardingController
      final container = ProviderContainer();
      final controller = container.read(onboardingControllerProvider.notifier);

      // Set up test data
      controller.updateHeight(175); // 175 cm
      controller.updateWeight(70.0); // 70 kg
      // BMI should be: 70 / (1.75 * 1.75) = 22.86

      // Build the widget
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.themeData,
            home: const CurrentWeightStepScreen(),
          ),
        ),
      );

      // Wait for widget to build
      await tester.pumpAndSettle();

      // Find BMI text (should show calculated BMI)
      final bmiText = find.textContaining('22.86');
      expect(bmiText, findsOneWidget);

      // Verify BMI category badge is displayed
      final bmiBadge = find.byType(Chip);
      expect(bmiBadge, findsWidgets);
    });

    testWidgets('should update BMI when weight changes', (WidgetTester tester) async {
      final container = ProviderContainer();
      final controller = container.read(onboardingControllerProvider.notifier);

      // Set initial height
      controller.updateHeight(175);

      // Build the widget
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.themeData,
            home: const CurrentWeightStepScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Update weight
      controller.updateWeight(80.0);
      await tester.pumpAndSettle();

      // BMI should be: 80 / (1.75 * 1.75) = 26.12
      final bmiText = find.textContaining('26.12');
      expect(bmiText, findsOneWidget);
    });

    testWidgets('should show correct BMI category badge', (WidgetTester tester) async {
      final container = ProviderContainer();
      final controller = container.read(onboardingControllerProvider.notifier);

      // Test underweight BMI (< 18.5)
      controller.updateHeight(180);
      controller.updateWeight(50.0); // BMI = 15.43

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.themeData,
            home: const CurrentWeightStepScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show warning badge for underweight
      final warningBadge = find.textContaining('Thiếu cân');
      expect(warningBadge, findsOneWidget);
    });
  });
}

