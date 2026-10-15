import 'package:flutter/material.dart';
import 'main_navigation.dart';

void main() {
  runApp(const DigiGymApp());
}

class DigiGymApp extends StatelessWidget {
  const DigiGymApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DigiGym',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF080D0C),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00FF66),
          brightness: Brightness.dark,
        ),
      ),
      home: const MainNavigation(),
    );
  }
}