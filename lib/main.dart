import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/splash_screen.dart';

void main() {
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

  runApp(const JantarMantarApp());
}

class JantarMantarApp extends StatelessWidget {
  const JantarMantarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
