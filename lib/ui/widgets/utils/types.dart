class RoomObject {
  final String id;
  final String name;
  final double crowdFactor;
  final int occupants;
  final double area;
  final double popularityFactor;

  RoomObject({
    required this.id,
    required this.name,
    required this.crowdFactor,
    required this.occupants,
    required this.area,
    required this.popularityFactor,
  });

  factory RoomObject.fromJson(Map<String, dynamic> json) {
    return RoomObject(
      id: json['id'],
      name: json['name'],
      crowdFactor: (json['crowd_factor'] as num).toDouble(),
      occupants: json['occupants'],
      area: (json['area'] as num).toDouble(),
      popularityFactor: (json['popularity_factor'] as num).toDouble(),
    );
  }
}

class DoorObject {
  final String id;
  final double longitude;
  final double latitude;
  final List<RoomObject> rooms;
  final bool isVertical;

  DoorObject({
    required this.longitude,
    required this.latitude,
    this.id = "",
    this.rooms = const [],
    this.isVertical = false,
  });

  factory DoorObject.fromJson(Map<String, dynamic> json) {
    return DoorObject(
      id: json['id'],
      longitude: (json['longitude'] as num).toDouble(),
      latitude: (json['latitude'] as num).toDouble(),
      rooms: (json['rooms'] as List<dynamic>)
          .map((roomJson) => RoomObject.fromJson(roomJson))
          .toList(),
      isVertical: json['is_vertical'],
    );
  }
}
