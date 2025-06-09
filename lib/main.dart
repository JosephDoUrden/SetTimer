import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/timer_controller.dart';
import 'views/timer_view.dart';

void main() {
  runApp(const SetTimerApp());
}

class SetTimerApp extends StatelessWidget {
  const SetTimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TimerController(),
      child: MaterialApp(
        title: 'SetTimer',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const TimerView(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
