import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';


class ErrorToast {
  static void show(String message, {bool isError = true}) {
    toastification.show(
      style: ToastificationStyle.flat,
      type: isError ? ToastificationType.error : ToastificationType.success,
      autoCloseDuration: const Duration(seconds: 3),
      alignment: Alignment.bottomCenter,
      title: Text(message)
    );
  }
}