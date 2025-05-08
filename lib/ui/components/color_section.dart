import 'package:flutter/material.dart';
import '../../utils/color_utils.dart';

/// A widget that displays a section with color circles and their names
class ColorSection extends StatelessWidget {
  /// The label for the section
  final String label;

  /// The list of color strings to display
  final List<String> colors;

  /// Constructor for the color section
  const ColorSection({
    super.key,
    required this.label,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade500, // Brighter orange for dark mode
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: colors.map((colorString) {
              Color displayColor;
              try {
                displayColor = ColorUtils.parseColorString(colorString);
              } catch (e) {
                displayColor = Colors.grey; // fallback if parsing fails
              }
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(
                      0xFF2D2D2D), // Dark background for color chips
                  border: Border.all(
                      color: Colors.grey.shade600,
                      width: 0.5), // Darker border for visibility
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: displayColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        colorString,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70, // Light text for dark mode
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
