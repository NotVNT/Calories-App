import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:calories_app/app/config/firebase_options.dart';
import 'package:calories_app/app/routing/intro_gate.dart';
import 'package:calories_app/core/theme/theme.dart';
import 'package:calories_app/features/auth/presentation/pages/auth_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = 'vi_VN';
  await initializeDateFormatting('vi');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint('[Firebase] Running in CLOUD mode (no emulator configured)');
  runApp(
    const ProviderScope(
      child: MyApp(),
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
      supportedLocales: const [
        Locale('vi'),
        Locale('en'),
      ],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: const IntroGate(), // Root: checks auth → shows intro or auth/onboarding flow
      routes: {
        '/intro': (context) => const IntroGate(), // Intro route for logout navigation
        '/login': (context) => const AuthPage(), // Login route
      },
    );
  }
}
