import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:indoor_crowded_regions_frontend/ui/widgets/utils/types.dart';
import 'package:latlong2/latlong.dart';
import 'package:indoor_crowded_regions_frontend/ui/widgets/utils/path_beautify.dart';

class LinePath extends StatelessWidget {
  final List<DoorObject> pathCoordinates;
  final Color lineColor;
  final double lineWidth;
  final int currentFloor;

  const LinePath({
    super.key,
    required this.pathCoordinates,
    required this.currentFloor,
    this.lineColor = Colors.blue,
    this.lineWidth = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    if (pathCoordinates.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<List<DoorObject>> segmentedPaths =
        _extractFloorPathSegments(pathCoordinates, currentFloor);
    return PolylineLayer(
      polylines: segmentedPaths.map((segment) {
        final latLngs = beautifyPath(segment)
            .map((door) => LatLng(door.latitude, door.longitude))
            .toList();
        return Polyline(
          points: latLngs,
          strokeWidth: 4.0,
          color: Colors.blueAccent,
        );
      }).toList(),
    );
  }
}

List<List<DoorObject>> _extractFloorPathSegments(
    List<DoorObject> fullPath, int currentFloor) {
  List<List<DoorObject>> floorSegments = [];
  List<DoorObject> currentSegment = [];

  for (final point in fullPath) {
    bool isOnCurrentFloor =
        point.rooms.any((room) => room.floor == currentFloor);

    if (isOnCurrentFloor) {
      currentSegment.add(point);
    } else {
      if (currentSegment.length > 1) {
        floorSegments.add(List.from(currentSegment));
      }
      currentSegment.clear();
    }
  }

  // Add any remaining valid segment
  if (currentSegment.length > 1) {
    floorSegments.add(currentSegment);
  }

  return floorSegments;
}
