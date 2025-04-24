import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // Contains MapController, MapCamera, MapOptions, etc.
import 'package:latlong2/latlong.dart';

import '../../../models/polygon_area.dart';
import '../../widgets/path/line_path.dart';

class MapWidget extends StatelessWidget {
  final MapController mapController;
  final int currentFloor;
  final List<PolygonArea> polygons;
  final PolygonArea? selectedPolygon;
  final Animation<double> pulseAnimation;
  final bool isSelectingOnMap;
  final Function(TapPosition, LatLng) onTap;
  final List<Map<String, dynamic>>? pathData;
  final Widget? userLocationWidget;
  final Function(MapEvent) onMapEvent;
  final Function(MapCamera, bool) onPositionChanged;
  
  const MapWidget({
    Key? key,
    required this.mapController,
    required this.currentFloor,
    required this.polygons,
    this.selectedPolygon,
    required this.pulseAnimation,
    required this.isSelectingOnMap,
    required this.onTap,
    this.pathData,
    this.userLocationWidget,
    required this.onMapEvent,
    required this.onPositionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final floorPolygons = polygons
        .where((polygon) => polygon.additionalData?['floor'] == currentFloor)
        .toList();

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: const LatLng(55.68875, 12.5783),
        minZoom: 17.5,
        maxZoom: 20.0,
        initialZoom: 18.0,
        initialCameraFit: CameraFit.bounds(
          bounds: LatLngBounds(
            const LatLng(55.68838827, 12.576953),
            const LatLng(55.689119, 12.57972968),
          ),
          padding: const EdgeInsets.all(30),
        ),
        onTap: onTap,
        onMapEvent: onMapEvent,
        onPositionChanged: onPositionChanged,
      ),
      children: [
        TileLayer(
          tileProvider: AssetTileProvider(),
          urlTemplate: 'assets/tiles/$currentFloor/{z}/{x}/{y}.png',
          errorImage: const AssetImage('assets/tiles/no_tile.png'),
          fallbackUrl: 'assets/tiles/no_tile.png',
          keepBuffer: 8,
        ),
        
        Stack(
          children: [
            PolygonLayer(
              polygons: floorPolygons
                  .where((polygon) => selectedPolygon == null || polygon.id != selectedPolygon!.id)
                  .map((polygon) {
                    return Polygon(
                      points: polygon.points,
                      color: isSelectingOnMap
                          ? Colors.blue.withValues(alpha: 0.15)
                          : Colors.green.withValues(alpha: 0.1),
                      borderColor: isSelectingOnMap
                          ? Colors.blueAccent.withValues(alpha: 0.8)
                          : Colors.green.shade300.withValues(alpha: 0.7),
                      borderStrokeWidth: isSelectingOnMap ? 2.0 : 1.0,
                    );
                  }).toList(),
            ),
            if (selectedPolygon != null && !isSelectingOnMap)
              AnimatedBuilder(
                animation: pulseAnimation,
                builder: (context, child) {
                  if (selectedPolygon!.points.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return PolygonLayer(
                    polygons: [
                      Polygon(
                        points: selectedPolygon!.points,
                        color: Colors.orange.withValues(
                            alpha: 0.4 + (pulseAnimation.value * 0.3)),
                        borderColor: Colors.deepOrange.shade400,
                        borderStrokeWidth: 3.0,
                      ),
                    ],
                  );
                },
              ),
          ],
        ),

        if (pathData != null && pathData!.isNotEmpty)
          LinePath(pathCoordinates: pathData!),

        if (userLocationWidget != null) userLocationWidget!,
      ],
    );
  }

  LatLng calculatePolygonCenter(List<LatLng> points) {
    if (points.isEmpty) return const LatLng(0, 0);
    double lat = 0;
    double lng = 0;
    for (var point in points) {
      lat += point.latitude;
      lng += point.longitude;
    }
    return LatLng(lat / points.length, lng / points.length);
  }
}
