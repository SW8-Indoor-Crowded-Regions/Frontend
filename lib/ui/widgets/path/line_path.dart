import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LinePath extends StatelessWidget {
  final List<Map<String, dynamic>> pathCoordinates;
  final Color lineColor;
  final double lineWidth;

  const LinePath({
    super.key,
    required this.pathCoordinates,
    this.lineColor = Colors.blue,
    this.lineWidth = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    final List<LatLng> points = pathCoordinates.map((coord) {
      return LatLng(coord['latitude'], coord['longitude']);
    }).toList();

    return PolylineLayer(
      polylines: [
        Polyline(
          points: points,
          strokeWidth: lineWidth,
          color: lineColor,
          borderStrokeWidth: 3.0,
          borderColor: Colors.black,
        ),
      ],
    );
  }
}