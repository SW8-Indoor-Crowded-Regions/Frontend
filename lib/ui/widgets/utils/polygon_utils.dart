import 'package:latlong2/latlong.dart';

/// Calculate a point inside the polygon for placing the room name
LatLng calculatePolygonCenter(List<LatLng> points) {
  if (points.isEmpty) return const LatLng(0, 0);

  // First try: Calculate the centroid (average of all points)
  double lat = 0;
  double lng = 0;
  for (var point in points) {
    lat += point.latitude;
    lng += point.longitude;
  }
  LatLng centroid = LatLng(lat / points.length, lng / points.length);

  // Check if the centroid is inside the polygon
  if (isPointInPolygon(centroid, points)) {
    return centroid;
  }

  // Second try: Find the visual center using a simple grid approach
  return findVisualCenter(points);
}

/// Check if a point is inside a polygon using ray casting algorithm
bool isPointInPolygon(LatLng point, List<LatLng> polygon) {
  if (polygon.length < 3) return false;

  bool isInside = false;
  int i = 0, j = polygon.length - 1;

  for (i = 0; i < polygon.length; i++) {
    if ((polygon[i].longitude > point.longitude) !=
            (polygon[j].longitude > point.longitude) &&
        (point.latitude <
            (polygon[j].latitude - polygon[i].latitude) *
                    (point.longitude - polygon[i].longitude) /
                    (polygon[j].longitude - polygon[i].longitude) +
                polygon[i].latitude)) {
      isInside = !isInside;
    }
    j = i;
  }

  return isInside;
}

/// Find a point inside the polygon using a grid-based approach
LatLng findVisualCenter(List<LatLng> polygon) {
  if (polygon.isEmpty) return const LatLng(0, 0);

  // Find the bounding box of the polygon
  double minLat = polygon[0].latitude;
  double maxLat = polygon[0].latitude;
  double minLng = polygon[0].longitude;
  double maxLng = polygon[0].longitude;

  for (var point in polygon) {
    if (point.latitude < minLat) minLat = point.latitude;
    if (point.latitude > maxLat) maxLat = point.latitude;
    if (point.longitude < minLng) minLng = point.longitude;
    if (point.longitude > maxLng) maxLng = point.longitude;
  }

  // Calculate the center of the bounding box
  LatLng boundingBoxCenter =
      LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2);

  // Check if the bounding box center is inside the polygon
  if (isPointInPolygon(boundingBoxCenter, polygon)) {
    return boundingBoxCenter;
  }

  // Create a grid of points inside the bounding box
  const int gridSize = 10;
  double latStep = (maxLat - minLat) / gridSize;
  double lngStep = (maxLng - minLng) / gridSize;

  List<LatLng> insidePoints = [];

  // Check each grid point
  for (int i = 0; i <= gridSize; i++) {
    for (int j = 0; j <= gridSize; j++) {
      double lat = minLat + (i * latStep);
      double lng = minLng + (j * lngStep);
      LatLng gridPoint = LatLng(lat, lng);

      if (isPointInPolygon(gridPoint, polygon)) {
        insidePoints.add(gridPoint);
      }
    }
  }

  // If we found points inside the polygon, find the one closest to the center
  if (insidePoints.isNotEmpty) {
    LatLng bestPoint = insidePoints[0];
    double minDistance = calculateDistance(bestPoint, boundingBoxCenter);

    for (var point in insidePoints) {
      double distance = calculateDistance(point, boundingBoxCenter);
      if (distance < minDistance) {
        minDistance = distance;
        bestPoint = point;
      }
    }

    return bestPoint;
  }

  // Fallback: return the first point of the polygon
  return polygon[0];
}

/// Calculate distance between two points (squared distance is enough for comparison)
double calculateDistance(LatLng p1, LatLng p2) {
  double latDiff = p1.latitude - p2.latitude;
  double lngDiff = p1.longitude - p2.longitude;
  return (latDiff * latDiff) + (lngDiff * lngDiff);
}
