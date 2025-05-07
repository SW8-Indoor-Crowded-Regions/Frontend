import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:indoor_crowded_regions_frontend/ui/widgets/utils/types.dart';
import 'package:latlong2/latlong.dart';
import 'package:indoor_crowded_regions_frontend/ui/widgets/utils/path_beautify.dart';

class LinePath extends StatelessWidget {
  final List<DoorObject> pathCoordinates;
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
    final List<DoorObject> beautifiedCoordinates = beautifyPath(pathCoordinates);
    final List<LatLng> points = beautifiedCoordinates.map((coord) {
      return LatLng(coord.latitude, coord.longitude);
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