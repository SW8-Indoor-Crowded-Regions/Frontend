import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class EdgeSegment {
  final LatLng from;
  final LatLng to;
  final int population;
  
  Color get color {
    if (population <= 500) {
      return Colors.green;
    } else if (population <= 1500) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }

  const EdgeSegment({
    required this.from,
    required this.to,
    required this.population,
  });
}