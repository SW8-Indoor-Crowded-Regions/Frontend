import 'package:latlong2/latlong.dart';

class PolygonArea {
  final String id;
  final String name;
  final List<LatLng> points;
  final Map<String, dynamic>? additionalData;

  PolygonArea({
    required this.id,
    required this.name,
    required this.points,
    this.additionalData,
  });

  factory PolygonArea.fromJson(Map<String, dynamic> json) {
    return PolygonArea(
      id: json['id'] as String,
      name: json['name'] as String,
      points: (json['coordinates'] as List).map((point) {
        return LatLng(
          (point['lat'] as num).toDouble(),
          (point['lng'] as num).toDouble(),
        );
      }).toList(),
      additionalData: json['additionalData'] as Map<String, dynamic>?,
    );
  }
}
