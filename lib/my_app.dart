import 'package:flutter/material.dart';
import 'ui/screens/home_screen.dart';

class MyApp extends StatelessWidget {
  final bool isTestMode;

  const MyApp({super.key, this.isTestMode = false});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SMK Map',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: HomeScreen(skipUserLocation: true, isTestMode: isTestMode),
    );
  }
}
