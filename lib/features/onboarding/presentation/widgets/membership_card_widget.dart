import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:calories_app/features/onboarding/presentation/theme/onboarding_theme.dart';

class MembershipCardWidget extends StatelessWidget {
  const MembershipCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.1, // Slight tilt
      child: Container(
        width: 280,
        height: 180,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              OnboardingTheme.primaryColor,
              OnboardingTheme.secondaryColor,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: OnboardingTheme.primaryColor.withAlpha((0.3 * 255).round()),
              blurRadius: 20,
              spreadRadius: 5,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Clip at top
            Positioned(
              top: 0,
              left: 20,
              child: Container(
                width: 40,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFF636E72),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                ),
              ),
            ),
            // Card content
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  // Mascot avatar
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xFF9B59B6),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                    ),
                    child: const Icon(
                      Icons.pets,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(width: 15),
                  // Text content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Họ tên: Ăn Khoẻ',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: OnboardingTheme.textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Chức vụ:',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: OnboardingTheme.lightTextColor,
                          ),
                        ),
                        Text(
                          'CHUYÊN GIA DINH DƯỠNG',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: OnboardingTheme.textColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Stars
                        Row(
                          children: List.generate(
                            5,
                            (index) => const Icon(
                              Icons.star,
                              color: Color(0xFF32CD32),
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


