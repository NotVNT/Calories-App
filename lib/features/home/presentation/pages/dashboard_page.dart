import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:calories_app/core/theme/theme.dart';
import '../widgets/home_activity_section.dart';
import '../widgets/home_calorie_card.dart';
import '../widgets/home_header_section.dart';
import '../widgets/home_macro_section.dart';
import '../widgets/home_recent_diary_section.dart';
import '../widgets/home_water_weight_section.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.palePink,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              HomeHeaderSection(),
              SizedBox(height: 24),
              HomeCalorieCard(),
              SizedBox(height: 20),
              HomeMacroSection(),
              SizedBox(height: 24),
              HomeRecentDiarySection(),
              SizedBox(height: 24),
              HomeActivitySection(),
              SizedBox(height: 24),
              HomeWaterWeightSection(),
              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

