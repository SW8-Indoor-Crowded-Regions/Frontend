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
          label: polygon.name,
        );
      }).toList(),
    );
  }
}

class InteractivePolygonLayer extends StatelessWidget {
  final List<PolygonArea> polygons;
  final Color fillColor;
  final Color strokeColor;
  final double strokeWidth;

  const InteractivePolygonLayer({
    super.key,
    required this.polygons,
    this.fillColor = const Color.fromRGBO(0, 0, 255, 0.1),
    this.strokeColor = Colors.blue,
    this.strokeWidth = 1.0,
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
          label: polygon.name,
        );
      }).toList(),
    );
  }
}
