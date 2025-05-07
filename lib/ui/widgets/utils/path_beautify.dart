import 'dart:math';
import 'package:indoor_crowded_regions_frontend/ui/widgets/utils/types.dart';
import 'package:latlong2/latlong.dart';

enum WallRelation { opposite, perpendicular, same }

List<DoorObject> beautifyPath(initPath) {
  List<DoorObject> path = [ initPath[0] ];
  for (int i = 0; i < initPath.length - 1; i++) {
    path.addAll(intermediatePoints(
      initPath,
      i,
      0.5,
    ));

    path.add(initPath[i + 1]);
  }

  return path;
}

List<DoorObject> intermediatePoints(
    List<DoorObject> path, int i, double toleranceMeters) {
  final WallRelation wallRelation = getWallRelation(
    p1: path[i],
    p2: path[i + 1],
    toleranceMeters: toleranceMeters,
  );

  if (wallRelation == WallRelation.same) {
    final int sign = getDeltaSign(path, i, toleranceMeters);
    return intermediateSame(path[i], path[i + 1], sign);
  }
  if (wallRelation == WallRelation.perpendicular) {
    return intermediatePerpendicular(path[i], path[i + 1]);
  }

  return intermediateOpposite(path[i], path[i + 1]);
}

List<DoorObject> intermediateSame(DoorObject p1, DoorObject p2, int sign) {
  if (p1.isVertical) {
    return [
      DoorObject(
        longitude: p1.longitude + sign * 0.00005,
        latitude: p1.latitude,
      ),
      DoorObject(
        longitude: p1.longitude + sign * 0.00005,
        latitude: p2.latitude,
      )
    ];
  }
  return [
    DoorObject(
      longitude: p1.longitude,
      latitude: p1.latitude + sign * 0.00002,
    ),
    DoorObject(
      longitude: p2.longitude,
      latitude: p1.longitude + sign * 0.00002,
    )
  ];
}

List<DoorObject> intermediatePerpendicular(DoorObject p1, DoorObject p2) {
  if (p1.isVertical) {
    return [DoorObject(longitude: p2.longitude, latitude: p1.latitude)];
  }
  return [
    DoorObject(
      longitude: p1.longitude,
      latitude: p2.latitude,
    )
  ];
}

List<DoorObject> intermediateOpposite(DoorObject p1, DoorObject p2) {
  if (p1.isVertical) {
    return [
      DoorObject(
        longitude: (p1.longitude + p2.longitude) / 2,
        latitude: p1.latitude,
      ),
      DoorObject(
        longitude: (p1.longitude + p2.longitude) / 2,
        latitude: p2.latitude,
      )
    ];
  }
  return [
    DoorObject(
      longitude: p1.longitude,
      latitude: (p1.latitude + p2.latitude) / 2,
    ),
    DoorObject(
      longitude: p2.longitude,
      latitude: (p1.latitude + p2.latitude) / 2,
    )
  ];
}

int getDeltaSign(List<DoorObject> path, int i, double toleranceMeters) {
  if (i == 0) {
    return getDeltaSign0(path, 0, toleranceMeters);
  }
  final int? x = sign(path[i], path[i + 1], toleranceMeters);

  if (x == null) {
    return getDeltaSign(path, i - 1, toleranceMeters);
  }
  return x;
}

int getDeltaSign0(List<DoorObject> path, int i, toleranceMeters) {
  if (i + 2 >= path.length) {
    return 1;
  }
  final int? x = sign(path[i], path[i + 2], toleranceMeters);

  if (x == null) {
    return getDeltaSign0(path, i + 1, toleranceMeters);
  }

  return x;
}

WallRelation getWallRelation(
    {required DoorObject p1,
    required DoorObject p2,
    double toleranceMeters = 0.5}) {
  final (sameLat, sameLon) = coordinateAlignment(
      p1: (p1.latitude, p1.longitude), p2: (p2.latitude, p2.longitude));

  if (p1.isVertical == p2.isVertical) {
    final bool isSame = p1.isVertical ? sameLon : sameLat;
    if (isSame) {
      return WallRelation.same;
    }
    return WallRelation.opposite;
  }
  return WallRelation.perpendicular;
}

(bool, bool) coordinateAlignment(
    {required (double, double) p1,
    required (double, double) p2,
    double toleranceMeters = 0.5}) {
  double R = 6378137; // Radius of the Earth in meters
  var (lat1, lon1) = p1;
  var (lat2, lon2) = p2;

  double degToRadian(double degrees) {
    return degrees * (pi / 180);
  }

  double dLat = R * degToRadian((lat2 - lat1).abs());
  double dLon = R * degToRadian((lon2 - lon1).abs()) * cos(degToRadian(lat1));

  return (dLat < toleranceMeters, dLon < toleranceMeters);
}

int? sign(DoorObject p1, DoorObject p2, double toleranceMeters) {
  if (p1.isVertical) {
    if (p2.latitude > p1.latitude + toleranceMeters) {
      return 1;
    } else if (p2.latitude < p1.latitude - toleranceMeters) {
      return -1;
    }
  }
  if (p2.longitude > p1.longitude + toleranceMeters) {
    return 1;
  } else if (p2.longitude < p1.longitude - toleranceMeters) {
    return -1;
  }
  return null;
}
