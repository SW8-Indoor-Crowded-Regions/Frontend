import 'package:flutter/material.dart';

class FilterToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final void Function(bool)? onChanged;

  const FilterToggleRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 1, // Reduce overall size
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        title: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        value: value,
        onChanged: onChanged,
        visualDensity: VisualDensity.compact,
        activeTrackColor: Colors.orange,
        inactiveTrackColor: Colors.white,
        thumbColor: const WidgetStatePropertyAll(Colors.grey),
      ),
    );
  }
}