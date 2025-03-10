import 'edge_segment.dart';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class LinePath extends StatelessWidget {
  /// All edges combined into one layer
  final List<EdgeSegment> segments;

  const LinePath({
    super.key,
    required this.segments
  });

  @override
  Widget build(BuildContext context) {
    // Build a Polyline for each segment, but keep them
    // all in a single PolylineLayer
    final List<Polyline> polylines = [];

    for (var segment in segments) {
      // Red line
      polylines.add(
        Polyline(
          points: [segment.from, segment.to],
          strokeWidth: 4.0,
          color: segment.color,
        ),
      );
    }

    return PolylineLayer(polylines: polylines);
  }
}
