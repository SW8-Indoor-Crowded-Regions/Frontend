import 'package:flutter/material.dart';

class FloorSelector extends StatelessWidget {
  final int currentFloor;
  final Function(int) onFloorChanged;

  const FloorSelector({
    super.key,
    required this.currentFloor,
    required this.onFloorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [1, 2, 3]
          .map((floor) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: TextButton(
                  onPressed: () {
                    if (currentFloor != floor) {
                      onFloorChanged(floor);
                    }
                  },
                  style: TextButton.styleFrom(
                    shape: const CircleBorder(),
                    backgroundColor: currentFloor == floor
                        ? Colors.orange.shade600
                        : Colors.black.withValues(alpha: 0.5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                    minimumSize: const Size(48, 48),
                    elevation: currentFloor == floor ? 6 : 2,
                  ),
                  child: Text("$floor", style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ))
          .toList()
          .reversed
          .toList(),
    );
  }
}
