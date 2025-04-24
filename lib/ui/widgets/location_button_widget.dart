import 'package:flutter/material.dart';

class LocationButton extends StatelessWidget {
  final VoidCallback onPressed;

  const LocationButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        shape: const CircleBorder(),
        color: Colors.black.withValues(alpha: 0.5),
        shadows: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))]
      ),
      child: IconButton(
        icon: const Icon(Icons.my_location, size: 28, color: Colors.white),
        padding: const EdgeInsets.all(14),
        onPressed: onPressed,
        tooltip: 'Center on my location',
      ),
    );
  }
}
