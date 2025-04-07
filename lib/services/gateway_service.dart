import 'package:dio/dio.dart';

class GatewayService {
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));
  final String baseUrl = "http://127.0.0.1:8000";

  // Flag to control whether to use mock data
  bool useMockData = false;

  Future<List<Map<String, dynamic>>> getFastestRouteWithCoordinates(
      String source, String target) async {
    if (useMockData) {
      return _getMockFastestRoute();
    } else {
      try {
        Response response = await dio.post(
          "$baseUrl/fastest-path",
          data: {
            "source": "67efbb210b23f5290bff704b",
            "target": "67efbb210b23f5290bff704c"
          },
        );

        List<Map<String, dynamic>> sensorsWithCoordinates =
            (response.data['fastest_path'] as List)
                .cast<Map<String, dynamic>>();
        return sensorsWithCoordinates;
      } catch (e) {
        print("URL: $baseUrl/fastest-path");
        print("Error: $e");
        throw Exception(
            "Failed to fetch fastest route with error: $e");
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