import 'package:flutter_test/flutter_test.dart';
import 'package:indoor_crowded_regions_frontend/ui/widgets/utils/path_beautify.dart';
import 'package:indoor_crowded_regions_frontend/ui/widgets/utils/types.dart';


List<DoorObject> createInitRoute(List<(double, double, bool)> coordinates) {
  RoomObject room = RoomObject(
    id: 'room1',
    name: 'Room 1',
    crowdFactor: 0.5,
    occupants: 10,
    area: 20.0,
    popularityFactor: 0.7,
    floor: 1,
  );

  return coordinates
      .map((coord) => DoorObject(
            latitude: coord.$1,
            longitude: coord.$2,
            isVertical: coord.$3,
            rooms: [room],
          ))
      .toList();
}
void main() {
  test('beautifyPath adds intermediate points correctly (opposite)', () {
    final List<DoorObject> initPath = createInitRoute([
      (40.0, -74.0, true),
      (40.5, -76.0, true),
    ]);

    final result = beautifyPath(initPath);

    final expectedPathCoords = [
      (40.0, -74.0),
      (40.0, -75.0),
      (40.5, -75.0),
      (40.5, -76.0),
    ];

    expect(result.length, equals(4)); // Should add two intermediate points

    for (int i = 0; i < result.length; i++) {
      expect(result[i].latitude, equals(expectedPathCoords[i].$1),
          reason:
              "Latitude mismatch at index $i: expected ${expectedPathCoords[i].$1}, got ${result[i].latitude}");
      expect(result[i].longitude, equals(expectedPathCoords[i].$2),
          reason:
              "Longitude mismatch at index $i: expected ${expectedPathCoords[i].$2}, got ${result[i].longitude}");
    }
  });

  test('beautifyPath handles empty path', () {
    final result = beautifyPath([]);
    expect(result, isEmpty);
  });

  test('beautifyPath adds intermediate points correctly (perpendicular)', () {
    final List<DoorObject> initPath = createInitRoute([
      (40.0, -74.0, false),
      (45.0, -71.0, true),
    ]);

    final result = beautifyPath(initPath);

    final expectedPathCoords = [
      (40.0, -74.0),
      (45.0, -74.0),
      (45.0, -71.0),
    ];

    expect(result.length, equals(3)); // Should add two intermediate points
    for (int i = 0; i < result.length; i++) {
      expect(result[i].latitude, equals(expectedPathCoords[i].$1),
          reason:
              "Latitude mismatch at index $i: expected ${expectedPathCoords[i].$1}, got ${result[i].latitude}");
      expect(result[i].longitude, equals(expectedPathCoords[i].$2),
          reason:
              "Longitude mismatch at index $i: expected ${expectedPathCoords[i].$2}, got ${result[i].longitude}");
    }
  });

  test('beautifyPath adds intermediate points correctly (same)', () {
    final List<DoorObject> initPath = createInitRoute([
      (40.0, -74.0, true),
      (45.0, -74.0, true),
    ]);

    final result = beautifyPath(initPath);

    final expectedPathCoords = [
      (40.0, -74.0),
      (40.0, -73.99995),
      (45.0, -73.99995),
      (45.0, -74.0),
    ];

    expect(result.length, equals(4)); // Should add two intermediate points

    for(int i = 0; i < result.length; i++) {
      expect(result[i].latitude, equals(expectedPathCoords[i].$1),
          reason:
              "Latitude mismatch at index $i: expected ${expectedPathCoords[i].$1}, got ${result[i].latitude}");
      expect(result[i].longitude, equals(expectedPathCoords[i].$2),
          reason:
              "Longitude mismatch at index $i: expected ${expectedPathCoords[i].$2}, got ${result[i].longitude}");
    }
  });
}