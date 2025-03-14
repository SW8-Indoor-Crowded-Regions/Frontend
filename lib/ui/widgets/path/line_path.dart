import 'edge_segment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class LinePath extends StatelessWidget {
  final List<EdgeSegment> segments;

  const LinePath({
    super.key,
    required this.segments,
  });

  @override
  Widget build(BuildContext context) {
    // Build a Polyline for each segment, combining them into a single PolylineLayer.
    final List<Polyline> polylines = segments.map((segment) {
      return Polyline(
        points: [segment.from, segment.to],
        strokeWidth: 4.0,
        color: segment.color,
        borderStrokeWidth: 3.0,
        borderColor: Colors.black,
      );
    }).toList();

    return PolylineLayer(polylines: polylines);
  }
}
