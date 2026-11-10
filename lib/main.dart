import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'firebase_config/auth_service.dart';
import 'firebase_config/firebase_analytics_service.dart';
import 'firebase_config/firebase_notification_service.dart';
import 'firebase_config/firebase_remote_config.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Full-screen immersive style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0F172A),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  try {
    await Firebase.initializeApp();

    // Anonymous Firebase Authentication
    try {
      await AuthService.instance.signInAnonymously();
    } catch (e) {
      debugPrint("[Auth] Init error: $e");
    }

    try {
      await FirebaseAnalyticsService.initialize();
    } catch (e) {
      debugPrint("[Analytics] Init error: $e");
    }

    try {
      await FirebaseNotificationService.initialize();
    } catch (e) {
      debugPrint("[Notification] Init error: $e");
    }

    try {
      await FirebaseRemoteConfigService.fetchAndApplyConfig().timeout(
        const Duration(seconds: 4),
        onTimeout: () {
          debugPrint("[RemoteConfig] Config fetch timed out. Proceeding with cached/default.");
        },
      );
    } catch (e) {
      debugPrint("[RemoteConfig] Init error: $e");
    }
  } catch (e) {
    debugPrint("[Firebase] Initialization error: $e");
  }

  runApp(const JantarMantarApp());
}

class JantarMantarApp extends StatelessWidget {
  const JantarMantarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: FirebaseNotificationService.navigatorKey,
      navigatorObservers: [
        FirebaseAnalyticsService.instance.observer,
      ],
      title: 'Jantar Mantar 2.0',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B1120),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFF59E0B),
          secondary: Color(0xFFEA580C),
          surface: Color(0xFF0F172A),
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
