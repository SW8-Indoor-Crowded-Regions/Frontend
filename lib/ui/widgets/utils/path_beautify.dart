import 'dart:math';

List<Map<String, dynamic>> beautifyPath(initPath) {
  List<Map<String, dynamic>> path = [
    {
      'latitude': initPath[0]['latitude'],
      'longitude': initPath[0]['longitude'],
    }
  ];
  for (int i = 0; i < initPath.length - 1; i++) {
    double lat1 = initPath[i]['latitude'];
    double lon1 = initPath[i]['longitude'];
    double lat2 = initPath[i + 1]['latitude'];
    double lon2 = initPath[i + 1]['longitude'];
    double lat0 = i > 0 ? initPath[i - 1]['latitude'] : lat1;

    if (coordinatesAreEqual(
      coord1: lon1,
      coord2: lon2,
      isLatitude: false,
      referenceLatitude: lat1,
    )) {
      path.add({
        'latitude': lat1,
        'longitude': lon1 + 0.00003,
      });
      path.add({
        'latitude': lat2,
        'longitude': lon1 + 0.00003,
      });
    } else if (coordinatesAreEqual(
        coord1: lat1, coord2: lat0, isLatitude: true)) {
      path.add({
        'latitude': lat1,
        'longitude': lon2,
      });
    } else {
      path.add({
        'latitude': lat2,
        'longitude': lon1,
      });
    }

    path.add({
      'latitude': lat2,
      'longitude': lon2,
    });
  }

  return path;
}

bool coordinatesAreEqual({
  required double coord1,
  required double coord2,
  required bool isLatitude,
  double referenceLatitude = 0.0, // Required only for longitude comparison
  double toleranceMeters = 1.0,
}) {
  // Approximate meters per degree
  final double metersPerDegree =
      isLatitude ? 111320.0 : 111320.0 * cos(referenceLatitude * pi / 180);

  final double toleranceDegrees = toleranceMeters / metersPerDegree;

  return (coord1 - coord2).abs() < toleranceDegrees;
}
