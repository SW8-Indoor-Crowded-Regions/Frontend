import 'package:flutter_test/flutter_test.dart';
import 'package:indoor_crowded_regions_frontend/ui/widgets/utils/path_beautify.dart';
import 'package:indoor_crowded_regions_frontend/ui/widgets/utils/types.dart';

void main() {
  test('beautifyPath adds intermediate points correctly', () {
    final roomA = RoomObject(
      id: 'A',
      name: 'Room A',
      crowdFactor: 0.3,
      occupants: 5,
      area: 25.0,
      popularityFactor: 0.6,
    );

    final roomB = RoomObject(
      id: 'B',
      name: 'Room B',
      crowdFactor: 0.7,
      occupants: 15,
      area: 30.0,
      popularityFactor: 0.9,
    );

    final initPath = [
      DoorObject(
        id: 'D1',
        latitude: 40.0,
        longitude: -74.0,
        isVertical: true,
        rooms: [roomA],
      ),
      DoorObject(
        id: 'D2',
        latitude: 40.0001,
        longitude: -74.0,
        isVertical: true,
        rooms: [roomA, roomB],
      ),
      DoorObject(
        id: 'D3',
        latitude: 40.0001,
        longitude: -73.9999,
        isVertical: false,
        rooms: [roomB],
      ),
    ];

    final result = beautifyPath(initPath);

    expect(result.length, greaterThan(initPath.length)); // Should add intermediate points
    expect(result.first.latitude, equals(40.0));
    expect(result.last.longitude, equals(-73.9999));
  });
}