import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'ui/screens/home_screen.dart';

class MyApp extends StatelessWidget {
  final bool isTestMode;

  const MyApp({super.key, this.isTestMode = false});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: MaterialApp(
        title: 'SMK Map',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
