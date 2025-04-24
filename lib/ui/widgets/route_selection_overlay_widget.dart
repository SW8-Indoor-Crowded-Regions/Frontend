import 'package:flutter/material.dart';

class RouteSelectionOverlay extends StatelessWidget {
  final bool selectingFromRoom;
  final VoidCallback onCancel;

  const RouteSelectionOverlay({
    super.key,
    required this.selectingFromRoom,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IgnorePointer(
          ignoring: true,
          child: Container(
            color: Colors.black.withValues(alpha: 0.35),
          ),
        ),

        Positioned(
          top: MediaQuery.of(context).padding.top + 140,
          left: 16,
          right: 16,
          child: IgnorePointer(
            child: Center(
              child: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        selectingFromRoom ? Icons.my_location : Icons.location_on,
                        color: Colors.orange.shade700,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          selectingFromRoom
                              ? "Tap your starting room on the map"
                              : "Tap your destination room on the map",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        Positioned(
          bottom: 40,
          right: 16,
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(30),
            color: Colors.white,
            child: InkWell(
              onTap: onCancel,
              borderRadius: BorderRadius.circular(30),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cancel_outlined, color: Colors.red.shade700, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "Cancel Selection",
                      style: TextStyle(
                        color: Colors.red.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
