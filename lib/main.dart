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

  runApp(const WorkoutSetTimerApp());
}

class WorkoutSetTimerApp extends StatelessWidget {
  const WorkoutSetTimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TimerController(),
      child: MaterialApp(
        title: 'SetTimer',
        theme: ThemeData(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF00D4AA),
            secondary: Color(0xFFFF6B35),
            surface: Color(0xFF1A1A1A),
          ),
          useMaterial3: true,
          fontFamily: 'SF Pro Display',
        ),
        home: const TimerView(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
