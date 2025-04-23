import 'package:latlong2/latlong.dart';

class PolygonArea {
  final String id;
  final String name;
  final String type;
  final List<LatLng> points;
  final Map<String, dynamic>? additionalData;

  PolygonArea({
    required this.id,
    required this.name,
    required this.type,
    required this.points,
    this.additionalData,
  });

  factory PolygonArea.fromJson(Map<String, dynamic> json) {
    return PolygonArea(
      id: json['id'] as String? ?? '', // Access nested ID and handle null
      name: json['name'] as String? ??
          'unnamed area', // Handle potential null for name
      type: json['type'] as String? ?? 'unknown type',
      points: (json['borders'] as List?)?.map((point) {
            return LatLng(
              (point[0] as num).toDouble(),
              (point[1] as num).toDouble(),
            );
          }).toList() ??
          [], // Handle potential null for borders
      additionalData: {
        'crowd_factor': json['crowd_factor'],
        'popularity_factor': json['popularity_factor'],
        'occupants': json['occupants'],
        'area': json['area'],
        'longitude': json['longitude'],
        'latitude': json['latitude'],
        'floor': json['floor'],
      },
    );
  }
}
