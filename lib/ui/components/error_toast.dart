import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:toastification/toastification.dart';


class ErrorToast {

  static void show(String message, {bool isError = true}) {

    if (const bool.fromEnvironment('FLUTTER_TEST') || dotenv.env['FLUTTER_TEST'] == "true") {
      return;
    }

    toastification.show(
      style: ToastificationStyle.flat,
      type: isError ? ToastificationType.error : ToastificationType.success,
      autoCloseDuration: const Duration(seconds: 3),
      alignment: Alignment.bottomCenter,
      title: Text(message)
    );
  }
}