import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'controllers/timer_controller.dart';
import 'views/timer_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style for better visual experience
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0A0A0A),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const WorkoutSetTimerApp());
}

class WorkoutSetTimerApp extends StatelessWidget {
  const WorkoutSetTimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final controller = TimerController();
        controller.initialize(); // Initialize the controller and session service
        return controller;
      },
      child: MaterialApp(
        title: 'SetTimer',
        theme: ThemeData(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF00D4AA),
            secondary: Color(0xFFFF6B35),
            surface: Color(0xFF1A1A1A),
            onSurface: Colors.white,
          ),
          useMaterial3: true,
          fontFamily: 'SF Pro Display',

          // Improved input decoration theme
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: Color(0xFF00D4AA), width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),

          // Enhanced button themes
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00D4AA),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),

          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white70,
              side: BorderSide(color: Colors.white.withOpacity(0.3)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),

          // Dialog theme for better consistency
          dialogTheme: const DialogThemeData(
            backgroundColor: Color(0xFF1A1A1A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
          ),

          // Snackbar theme
          snackBarTheme: SnackBarThemeData(
            backgroundColor: const Color(0xFF1A1A1A),
            contentTextStyle: const TextStyle(color: Colors.white),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        ),
        home: const TimerView(),
        debugShowCheckedModeBanner: false,
        // Add keyboard handling
        builder: (context, child) {
          return GestureDetector(
            onTap: () {
              // Dismiss keyboard when tapping outside input fields
              FocusScope.of(context).unfocus();
            },
            child: child,
          );
        },
      ),
    );
  }
}
