import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../models/polygon_area.dart';

class PolygonLayerWidget extends StatelessWidget {
  final List<PolygonArea> polygons;
  final Function(PolygonArea) onPolygonTap;
  final Color fillColor;
  final Color strokeColor;
  final double strokeWidth;

  const PolygonLayerWidget({
    super.key,
    required this.polygons,
    required this.onPolygonTap,
    this.fillColor = const Color.fromRGBO(255, 0, 0, 0.3),
    this.strokeColor = Colors.red,
    this.strokeWidth = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    return PolygonLayer(
      polygons: polygons.map((polygon) {
        return Polygon(
          points: polygon.points,
          color: fillColor,
          borderColor: strokeColor,
          borderStrokeWidth: strokeWidth,
          isFilled: true,
          label: polygon.name,
        );
      }).toList(),
    );
  }
}

class InteractivePolygonLayer extends StatelessWidget {
  final List<PolygonArea> polygons;
  final Function(PolygonArea) onPolygonTap;
  final Color fillColor;
  final Color strokeColor;
  final double strokeWidth;

  const InteractivePolygonLayer({
    super.key,
    required this.polygons,
    required this.onPolygonTap,
    this.fillColor = const Color.fromRGBO(255, 0, 0, 0.3),
    this.strokeColor = Colors.red,
    this.strokeWidth = 2.0,
  });

  bool isPointInPolygon(LatLng point, List<LatLng> polygon) {
    bool isInside = false;
    int i = 0;
    int j = polygon.length - 1;
    // ray-casting algorithm
    for (i = 0; i < polygon.length; i++) {
      if (((polygon[i].latitude > point.latitude) != (polygon[j].latitude > point.latitude)) &&
          (point.longitude < (polygon[j].longitude - polygon[i].longitude) * 
          (point.latitude - polygon[i].latitude) / 
          (polygon[j].latitude - polygon[i].latitude) + polygon[i].longitude)) {
        isInside = !isInside;
      }
      j = i;
    }
    return isInside;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PolygonLayerWidget(
          polygons: polygons,
          onPolygonTap: onPolygonTap,
          fillColor: fillColor,
          strokeColor: strokeColor,
          strokeWidth: strokeWidth,
        ),
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTapUp: (TapUpDetails details) {
            final RenderBox box = context.findRenderObject() as RenderBox;
            final point = box.globalToLocal(details.globalPosition);
            
            // TODO: JACK NEEDS TO IMPLEMENT CONVERSION BASED ON MAP CURRENT VIEWPORT AND ZOOM LEVEL
            final latLng = LatLng(0, 0); // Replace with actual conversion

            for (var polygon in polygons) {
              if (isPointInPolygon(latLng, polygon.points)) {
                onPolygonTap(polygon);
                break;
              }
            }
          },
        ),
      ],
    );
  }
}
