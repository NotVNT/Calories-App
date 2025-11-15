import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'package:calories_app/app/routing/intro_gate.dart';
import 'package:calories_app/core/theme/theme.dart';
import 'package:calories_app/features/auth/presentation/pages/auth_page.dart';
import 'package:calories_app/services/profile_service.dart';
import 'package:calories_app/providers/profile_provider.dart';
import 'package:calories_app/providers/foods_provider.dart';
import 'package:calories_app/providers/notifications_provider.dart';
import 'package:calories_app/services/firebase_service.dart';
import 'package:calories_app/providers/recipes_provider.dart';
import 'package:calories_app/providers/compare_journey_provider.dart';
import 'package:calories_app/providers/health_connect_provider.dart';

// Account screens (routes)
import 'package:calories_app/ui/screens/account/edit_nickname.dart';
import 'package:calories_app/ui/screens/account/edit_profile_screen.dart';
import 'package:calories_app/ui/screens/account/settings_screen.dart';
import 'package:calories_app/ui/screens/account/edit_height.dart';
import 'package:calories_app/ui/screens/account/edit_email.dart';
import 'package:calories_app/ui/screens/account/terms_screen.dart';
import 'package:calories_app/ui/screens/account/privacy_screen.dart';
import 'package:calories_app/ui/screens/account/community_screen.dart';
import 'package:calories_app/ui/screens/account/physical_profile_screen.dart';
import 'package:calories_app/ui/screens/account/targets_screen.dart';
import 'package:calories_app/ui/screens/account/report_screen.dart';
import 'package:calories_app/ui/screens/account/share_journey_screen.dart';
import 'package:calories_app/ui/screens/account/setup_goal_intro.dart';
import 'package:calories_app/ui/screens/account/setup_goal/choose_goal.dart';
import 'package:calories_app/ui/screens/account/setup_goal/activity_level.dart';
import 'package:calories_app/ui/screens/account/setup_goal/weight_picker.dart';
import 'package:calories_app/ui/screens/account/setup_goal/summary.dart';
import 'package:calories_app/ui/screens/account/steps_target_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = 'vi_VN';
  await initializeDateFormatting('vi');
  final firebaseStarted = await FirebaseService.initFirebaseIfAvailable();
  if (firebaseStarted) {
    debugPrint('[Firebase] Initialized (emulator if available)');
  } else {
    debugPrint('[Firebase] Running in MOCK mode (Firebase not initialized)');
  }
  // Create ProfileService and providers that rely on it before launching.
  final profileService = await ProfileService.create();
  final uid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';

  runApp(
    ProviderScope(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<ProfileProvider>(
            create: (_) {
              final p = ProfileProvider(uid: uid, service: profileService);
              // Only load profile automatically when a real user is signed-in.
              // Guard against anonymous 'guest' uid to avoid fetching empty doc.
              if (FirebaseAuth.instance.currentUser != null) {
                p.load();
              }
              return p;
            },
          ),
          ChangeNotifierProvider<FoodsProvider>(
            create: (_) {
              final p = FoodsProvider();
              p.seedSampleData();
              return p;
            },
          ),
          ChangeNotifierProvider<NotificationsProvider>(
            create: (_) => NotificationsProvider(),
          ),
          ChangeNotifierProxyProvider<FoodsProvider, RecipesProvider>(
            create: (_) => RecipesProvider(foodsProvider: FoodsProvider()),
            update: (_, foods, previous) =>
                previous ?? RecipesProvider(foodsProvider: foods),
          ),
          ChangeNotifierProvider<CompareJourneyProvider>(
            create: (_) => CompareJourneyProvider(),
          ),
          ChangeNotifierProvider<HealthConnectProvider>(
            create: (_) => HealthConnectProvider(),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ăn Khỏe - Healthy Choice',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      locale: const Locale('vi'),
      supportedLocales: const [Locale('vi'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home:
          const IntroGate(), // Root: checks auth → shows intro or auth/onboarding flow
      routes: {
        '/intro': (context) =>
            const IntroGate(), // Intro route for logout navigation
        '/login': (context) => const AuthPage(), // Login route
        // Account routes
        '/settings': (context) => const SettingsScreen(),
        '/edit_profile': (context) => const EditProfileScreen(),
        '/edit_nickname': (context) => const EditNicknameScreen(),
        '/edit_height': (context) => const EditHeightScreen(),
        '/edit_email': (context) => const EditEmailScreen(),
        '/terms': (context) => const TermsScreen(),
        '/privacy': (context) => const PrivacyScreen(),
        '/community': (context) => const CommunityScreen(),
        '/physical_profile': (context) => const PhysicalProfileScreen(),
        '/targets': (context) => const TargetsScreen(),
        '/report/nutrition': (context) =>
            const ReportScreen(title: 'Dinh dưỡng'),
        '/report/workout': (context) => const ReportScreen(title: 'Tập luyện'),
        '/report/steps': (context) => const ReportScreen(title: 'Số bước'),
        '/report/weight': (context) => const ReportScreen(title: 'Cân nặng'),
        '/report/share': (context) => const ShareJourneyScreen(),
        '/setup_goal': (context) => const SetupGoalIntroScreen(),
        '/setup_goal/choose_goal': (context) => const ChooseGoalScreen(),
        '/setup_goal/activity': (context) => const ActivityLevelScreen(),
        '/setup_goal/weight': (context) => const WeightPickerScreen(),
        '/setup_goal/summary': (context) => const SetupSummaryScreen(),
        '/steps_target': (context) => const StepsTargetScreen(),
      },
    );
  }
}
