import 'package:flutter/material.dart';

class AppInitializer {
  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    // Add other initialization tasks here, e.g., loading environment variables, initializing services, etc.
  }
}
