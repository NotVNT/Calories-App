import 'package:flutter/material.dart';
import 'package:calories_app/features/onboarding/presentation/theme/onboarding_theme.dart';
import 'package:calories_app/features/onboarding/presentation/widgets/food_label.dart';
import 'package:calories_app/features/onboarding/presentation/widgets/mascot_laptop_widget.dart';

class CalorieTrackingScreen extends StatelessWidget {
  const CalorieTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            OnboardingTheme.backgroundColor,
            OnboardingTheme.backgroundColor.withOpacity(0.8),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // App Name
              Text(
                'Ăn Khoẻ',
                style: OnboardingTheme.appNameStyle,
              ),
              const SizedBox(height: 40),
              // Mascot with laptop
              SizedBox(
                height: 280,
                child: Stack(
                  children: [
                    // Mascot and laptop illustration
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: OnboardingTheme.secondaryColor.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const MascotLaptopWidget(size: 200),
                      ),
                    ),
                    // Food labels
                    FoodLabel(
                      text: 'cơm tấm',
                      position: const Offset(20, 80),
                    ),
                    FoodLabel(
                      text: 'phở gà',
                      position: const Offset(200, 40),
                    ),
                    FoodLabel(
                      text: 'bún bò',
                      position: const Offset(180, 220),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              // Main heading
              Text(
                'Tính calo và dinh dưỡng món Việt cực chuẩn',
                style: OnboardingTheme.headingStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // Sub-text
              Text(
                'Theo đúng cách nấu & khẩu phần bạn chọn',
                style: OnboardingTheme.subheadingStyle,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


