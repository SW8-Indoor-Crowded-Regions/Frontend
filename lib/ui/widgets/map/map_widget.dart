import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../models/polygon_area.dart';
import '../utils/polygon_utils.dart';
import '../../screens/home_screen.dart';
import '../../widgets/path/line_path.dart';
import '../../widgets/utils/types.dart';

class MapWidget extends StatefulWidget {
  final MapController mapController;
  final int currentFloor;
  final List<PolygonArea> polygons;
  final PolygonArea? selectedPolygon;
  final Animation<double> pulseAnimation;
  final bool isSelectingOnMap;
  final Function(TapPosition, LatLng) onTap;
  final List<DoorObject>? pathData;
  final Widget? userLocationWidget;
  final Function(MapEvent) onMapEvent;
  final Function(MapCamera, bool) onPositionChanged;
  final Room? fromRoom;
  final Room? toRoom;
  final String highlightedCategory;
  final Function(PolygonArea) simulateMapTap;

  const MapWidget({
    super.key,
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
    this.fromRoom,
    this.toRoom,
    required this.highlightedCategory,
    required this.simulateMapTap
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  double _currentZoom = 18.0; // Default zoom level
  static const double _labelVisibilityThreshold =
      19.0; // Show labels only when zoomed in more
  double _mapRotation = 0.0; // Track map rotation

  @override
  Widget build(BuildContext context) {
    final floorPolygons = widget.polygons
        .where((polygon) =>
            polygon.additionalData?['floor'] == widget.currentFloor)
        .toList();
    final typeCounts = <String, int>{};
    for (final polygon in floorPolygons) {
      typeCounts[polygon.type] = (typeCounts[polygon.type] ?? 0) + 1;
    }
    if (typeCounts[widget.highlightedCategory] == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final polygon = floorPolygons.firstWhere(
          (polygon) => polygon.type == widget.highlightedCategory,
        );
        widget.simulateMapTap(polygon);
      });
    }
    // Find the polygon objects for fromRoom and toRoom
    PolygonArea? fromRoomPolygon;
    PolygonArea? toRoomPolygon;

    if (widget.fromRoom != null) {
      fromRoomPolygon = widget.polygons.firstWhere(
        (polygon) => polygon.id == widget.fromRoom!.id
      );
    }

    if (widget.toRoom != null) {
      toRoomPolygon = widget.polygons.firstWhere(
        (polygon) => polygon.id == widget.toRoom!.id
      );
    }

    return FlutterMap(
      mapController: widget.mapController,
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
        onTap: widget.onTap,
        onMapEvent: widget.onMapEvent,
        onPositionChanged: _handlePositionChanged,
      ),
      children: [
        TileLayer(
          tileProvider: AssetTileProvider(),
          urlTemplate: 'assets/tiles/${widget.currentFloor}/{z}/{x}/{y}.png',
          errorImage: const AssetImage('assets/tiles/no_tile.png'),
          fallbackUrl: 'assets/tiles/no_tile.png',
          keepBuffer: 8,
        ),
        Stack(
          children: [
            PolygonLayer(
              polygons: floorPolygons
                  .where((polygon) =>
                      widget.selectedPolygon == null ||
                      polygon.id != widget.selectedPolygon!.id)
                  .map((polygon) {
                return Polygon(
                  points: polygon.points, 
                  color: widget.isSelectingOnMap || (polygon.type == widget.highlightedCategory && typeCounts[polygon.type]! > 1)
                      ? Colors.blue.withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.15),
                  borderColor: widget.isSelectingOnMap || (polygon.type == widget.highlightedCategory && typeCounts[polygon.type]! > 1)
                      ? Colors.blueAccent.withValues(alpha: 0.8)
                      : Colors.white.withValues(alpha: 0.6),
                  borderStrokeWidth: widget.isSelectingOnMap || (polygon.type == widget.highlightedCategory && typeCounts[polygon.type]! > 1) ? 2.0 : 1.0,
                );
              }).toList(),
            ),
            // Selected polygon with pulse animation
            if (widget.selectedPolygon != null && !widget.isSelectingOnMap)
              AnimatedBuilder(
                animation: widget.pulseAnimation,
                builder: (context, child) {
                  if (widget.selectedPolygon!.points.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return PolygonLayer(
                    polygons: [
                      Polygon(
                        points: widget.selectedPolygon!.points,
                        color: Colors.orange.withValues(
                            alpha: 0.4 + (widget.pulseAnimation.value * 0.3)),
                        borderColor: Colors.deepOrange.shade400,
                        borderStrokeWidth: 3.0,
                      ),
                    ],
                  );
                },
              ),

            // From room with enhanced pulsing animation (as an overlay)
            if (fromRoomPolygon != null && fromRoomPolygon.points.isNotEmpty)
              AnimatedBuilder(
                animation: widget.pulseAnimation,
                builder: (context, child) {
                  return Stack(
                    children: [
                      // Outer glow effect
                      PolygonLayer(
                        polygons: [
                          Polygon(
                            points: fromRoomPolygon!.points,
                            color: Colors.transparent,
                            borderColor: const Color.fromARGB(255, 0, 21, 138)
                                .withValues(
                                    alpha: 0.7 * widget.pulseAnimation.value),
                            borderStrokeWidth:
                                6.0 * widget.pulseAnimation.value,
                          ),
                        ],
                      ),
                      // Main polygon
                      PolygonLayer(
                        polygons: [
                          Polygon(
                            points: fromRoomPolygon.points,
                            color: const Color.fromARGB(255, 0, 21, 138)
                                .withValues(
                                    alpha: 0.2 +
                                        (widget.pulseAnimation.value * 0.6)),
                            borderColor:
                                const Color.fromARGB(255, 255, 255, 255),
                            borderStrokeWidth:
                                1.0 + (widget.pulseAnimation.value * 1.0),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),

            // To room with enhanced pulsing animation (as an overlay)
            if (toRoomPolygon != null && toRoomPolygon.points.isNotEmpty)
              AnimatedBuilder(
                animation: widget.pulseAnimation,
                builder: (context, child) {
                  // Magenta with stronger pulsing effect
                  return Stack(
                    children: [
                      // Outer glow effect
                      PolygonLayer(
                        polygons: [
                          Polygon(
                            points: toRoomPolygon!.points,
                            color: Colors.transparent,
                            borderColor: const Color.fromARGB(255, 0, 174, 255)
                                .withValues(
                                    alpha: 0.7 * widget.pulseAnimation.value),
                            borderStrokeWidth:
                                2.0 * widget.pulseAnimation.value,
                          ),
                        ],
                      ),
                      // Main polygon
                      PolygonLayer(
                        polygons: [
                          Polygon(
                            points: toRoomPolygon.points,
                            color: const Color.fromARGB(255, 0, 174, 255)
                                .withValues(
                                    alpha: 0.2 +
                                        (widget.pulseAnimation.value * 0.6)),
                            borderColor:
                                const Color.fromARGB(255, 255, 255, 255),
                            borderStrokeWidth:
                                1.0 + (widget.pulseAnimation.value * 1.0),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
        // Room name labels - only visible when zoomed in beyond threshold
        if (_currentZoom >= _labelVisibilityThreshold)
          MarkerLayer(
            markers: floorPolygons.map((polygon) {
              final center = calculatePolygonCenter(polygon.points);

              // Determine if this is a special room (from/to room)
              final bool isFromRoom =
                  widget.fromRoom != null && polygon.id == widget.fromRoom!.id;
              final bool isToRoom =
                  widget.toRoom != null && polygon.id == widget.toRoom!.id;

              // Adjust size based on zoom and importance
              const double baseSize = 12.0;
              final double zoomFactor =
                  (_currentZoom - _labelVisibilityThreshold) * 1.5;
              final double importanceFactor =
                  isFromRoom || isToRoom ? 1.5 : 1.0;
              final double fontSize =
                  baseSize + zoomFactor.clamp(0.0, 4.0) * importanceFactor;

              // Determine text color based on room type (all white for now)
              const Color textColor = Colors.white;

              return Marker(
                point: center,
                width: 120,
                height: 30,
                // Completely static text without background box
                child: Text(
                  polygon.name,
                  style: TextStyle(
                    color: textColor,
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: const Offset(1.0, 1.0),
                        blurRadius: 3.0,
                        color: Colors.black.withValues(alpha: 0.8),
                      ),
                      Shadow(
                        offset: const Offset(-0.5, -0.5),
                        blurRadius: 2.0,
                        color: Colors.black.withValues(alpha: 0.8),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
          ),
        if (widget.pathData != null && widget.pathData!.isNotEmpty)
          LinePath(pathCoordinates: widget.pathData!),
        if (widget.userLocationWidget != null) widget.userLocationWidget!,
      ],
    );
  }

  void _handlePositionChanged(MapCamera camera, bool hasGesture) {
    if (_currentZoom != camera.zoom || _mapRotation != camera.rotation) {
      setState(() {
        _currentZoom = camera.zoom;
        _mapRotation = camera.rotation;
      });
    }
    widget.onPositionChanged(camera, hasGesture);
  }
}
