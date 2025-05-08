import 'package:flutter/material.dart';

/// A widget that displays a row with a label and a value
class ExhibitDetailRow extends StatelessWidget {
  /// The label to display
  final String label;

  /// The value to display
  final String value;

  /// Constructor for the exhibit detail row
  const ExhibitDetailRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade500, // Brighter orange for dark mode
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70, // Light text for dark mode
              ),
            ),
          ),
        ],
      ),
    );
  }
}
