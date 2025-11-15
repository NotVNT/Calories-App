import 'package:flutter/material.dart';
import 'package:calories_app/features/onboarding/presentation/theme/onboarding_theme.dart';
import 'package:calories_app/features/onboarding/presentation/widgets/mascot_widget.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            OnboardingTheme.backgroundColor,
            OnboardingTheme.backgroundColor.withAlpha((0.8 * 255).round()),
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
              const SizedBox(height: 60),
              // Mascot with badge
              Stack(
                alignment: Alignment.center,
                children: [
                  // Background glow effect
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: OnboardingTheme.primaryColor.withAlpha((0.3 * 255).round()),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  // Mascot
                  const MascotWidget(size: 200),
                  // Badge
                  Positioned(
                    bottom: 60,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF32CD32),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha((0.2 * 255).round()),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '1',
                          style: OnboardingTheme.appNameStyle.copyWith(
                            fontSize: 24,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),
              // Main heading
              Text(
                'Ứng dụng dinh dưỡng top #1 App Store',
                style: OnboardingTheme.headingStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // Sub-text
              Text(
                'Ứng dụng cá nhân hoá món ăn, thói quen và lối sống dành cho người Việt.',
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



