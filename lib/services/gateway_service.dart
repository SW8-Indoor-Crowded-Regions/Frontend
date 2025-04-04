import 'package:dio/dio.dart';

class GatewayService {
  final dio = Dio();
  final String baseUrl = "http://localhost:8000/";

  // Flag to control whether to use mock data
  bool useMockData = true;

  Future<List<Map<String, dynamic>>> getFastestRouteWithCoordinates(
      String source, String target) async {
    if (useMockData) {
      return _getMockFastestRoute();
    } else {
      try {
        Response response = await dio.post(
          "${baseUrl}pathfinding/fastest-path",
          data: {
            "source_sensor": source,
            "target_sensor": target,
          },
        );

        List<Map<String, dynamic>> sensorsWithCoordinates =
            (response.data['fastest_path'] as List)
                .cast<Map<String, dynamic>>();
        return sensorsWithCoordinates;
      } catch (e) {
        throw Exception(
            "Failed to fetch fastest route with coordinates: $e");
      }
    }
  }

  Future<List<Map<String, dynamic>>> _getMockFastestRoute() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      {"id": "sensor2", "longitude": 12.577545, "latitude": 55.688732},
      {"id": "sensor3", "longitude": 12.577640, "latitude": 55.688732},
      {"id": "sensor4", "longitude": 12.577728, "latitude": 55.688732},
    ];
  }
}