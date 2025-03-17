import 'package:flutter/material.dart';
import 'app_initializer.dart';
import 'my_app.dart';

void main() async {
  await AppInitializer.initialize();
  runApp(const MyApp());
}
