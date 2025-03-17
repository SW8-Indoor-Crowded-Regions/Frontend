class NodeModel {
  final int id;
  final double latitude;
  final double longitude;

  NodeModel({
    required this.id,
    required this.latitude,
    required this.longitude,
  });

  factory NodeModel.fromJson(Map<String, dynamic> json) {
    return NodeModel(
      id: json['id'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}

class EdgeModel {
  final int source;
  final int target;
  final int population;

  EdgeModel({
    required this.source,
    required this.target,
    required this.population,
  });

  factory EdgeModel.fromJson(Map<String, dynamic> json) {
    return EdgeModel(
      source: json['source'],
      target: json['target'],
      population: json['population'],
    );
  }
}