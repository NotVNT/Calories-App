import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:calories_app/features/onboarding/presentation/theme/onboarding_theme.dart';
import 'package:calories_app/features/onboarding/presentation/screens/calorie_tracking_screen.dart';
import 'package:calories_app/features/onboarding/presentation/screens/community_screen.dart';
import 'package:calories_app/features/onboarding/presentation/screens/intro_screen.dart';
import 'package:calories_app/shared/state/intro_status_provider.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Widget> _screens = [
    const IntroScreen(),
    const CalorieTrackingScreen(),
    const CommunityScreen(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _screens.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    try {
      await ref.read(introStatusProvider.notifier).markAsSeen();
    } catch (e, stackTrace) {
      debugPrint('Failed to persist intro flag: $e\n$stackTrace');
    }
    if (!mounted) return;
    // Navigate to Auth (Sign in / Sign up) - use pushNamedAndRemoveUntil to clear stack
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/login',
      (route) => false, // Remove all previous routes
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Top-right skip button
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 16,
            child: SafeArea(
              child: TextButton(
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  try {
                    await ref.read(introStatusProvider.notifier).markAsSeen();
                  } catch (e) {
                    debugPrint('Failed to persist intro flag on skip: $e');
                  }
                  if (!navigator.mounted) return;
                  navigator.pushNamedAndRemoveUntil('/login', (r) => false);
                },
                child: const Text('Bỏ qua'),
              ),
            ),
          ),
          // PageView for screens
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _screens.length,
            itemBuilder: (context, index) => _screens[index],
          ),
          // Bottom section with dots and button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 30,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    OnboardingTheme.backgroundColor.withAlpha(
                      (0 * 255).round(),
                    ),
                    OnboardingTheme.backgroundColor,
                  ],
                ),
              ),
              child: Column(
                children: [
                  // Page indicator
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _screens.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: OnboardingTheme.primaryColor,
                      dotColor: OnboardingTheme.secondaryColor.withAlpha(
                        (0.5 * 255).round(),
                      ),
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 3,
                      spacing: 8,
                    ),
                  ),
                  const SizedBox(height: 30),
                  // CTA Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: OnboardingTheme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            OnboardingTheme.buttonBorderRadius,
                          ),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Bắt đầu ngay',
                        style: OnboardingTheme.buttonTextStyle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
