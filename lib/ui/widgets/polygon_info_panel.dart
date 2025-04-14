// widgets/polygon_info_panel.dart
import 'package:flutter/material.dart';
import '../../models/polygon_area.dart'; // Adjust import path if needed

class PolygonInfoPanel extends StatelessWidget {
  final PolygonArea polygon;
  final VoidCallback onClose; // Callback to close the panel

  const PolygonInfoPanel({
    super.key,
    required this.polygon,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for positioning and sizing
    final screenSize = MediaQuery.of(context).size;
    // Define panel height (e.g., 40% of screen height or a fixed value)
    final panelHeight =
        screenSize.height * 0.4 > 300 ? 300 : screenSize.height * 0.4;

    return Container(
      width: double.infinity, // Take full width
      height: panelHeight.toDouble(),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
        // Rounded corners on top only
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: SafeArea(
        // Use SafeArea to avoid system UI overlaps
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title for the panel
                  Text(
                    'Area Details',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  // Close Button
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: onClose,
                    tooltip: 'Close Panel',
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),
              _buildInfoRow('ID', polygon.id),
              _buildInfoRow('Name', polygon.name),
              _buildInfoRow('Type', polygon.type),
              // Add more details if needed from additionalData
              // if (polygon.additionalData != null) ...[
              //   _buildInfoRow('Occupants', polygon.additionalData!['occupants']?.toString() ?? 'N/A'),
              //   _buildInfoRow('Area', polygon.additionalData!['area']?.toString() ?? 'N/A'),
              // ]
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for consistent info row styling
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
              color: Colors.black87, fontSize: 16), // Default text style
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
