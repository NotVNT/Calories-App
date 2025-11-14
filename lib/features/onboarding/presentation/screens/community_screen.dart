import 'package:flutter/material.dart';
import 'package:calories_app/features/onboarding/presentation/theme/onboarding_theme.dart';
import 'package:calories_app/features/onboarding/presentation/widgets/membership_card_widget.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

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
              const SizedBox(height: 60),
              // Membership card
              const MembershipCardWidget(),
              const SizedBox(height: 60),
              // Main heading
              Text(
                'Có cộng đồng & chuyên gia dinh dưỡng',
                style: OnboardingTheme.headingStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // Sub-text
              Text(
                'Đồng hành cùng bạn mỗi ngày',
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


