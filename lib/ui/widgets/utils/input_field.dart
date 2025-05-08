import 'package:flutter/material.dart';

Widget buildInputField({
  required TextEditingController controller,
  required String hint,
  required IconData icon,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    decoration: BoxDecoration(
      color: const Color(0xFF2D2D2D), // Dark background for input field
      borderRadius: BorderRadius.circular(8),
    ),
    child: TextField(
      controller: controller,
      readOnly: true,
      enableInteractiveSelection: false,
      style: TextStyle(
        color: controller.text.startsWith("Select")
            ? Colors.grey.shade400
            : Colors.white, // Light text for dark mode
        fontWeight: controller.text.startsWith("Select")
            ? FontWeight.normal
            : FontWeight.w500,
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(icon,
            color: const Color(0xFFFF7D00),
            size: 20), // Brighter orange for dark mode
        hintText: hint,
        hintStyle: TextStyle(
            color: Colors.grey.shade400), // Lighter gray for visibility
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
      ),
    ),
  );
}
