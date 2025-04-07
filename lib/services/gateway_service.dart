import 'package:dio/dio.dart';

class GatewayService {
  final dio = Dio();
  final String baseUrl = "http://127.0.0.1:8000";

  Future<List<Map<String, dynamic>>> getFastestRouteWithCoordinates(String source, String target) async {
    try {
      Response response = await dio.post(
        "$baseUrl/fastest-path",
        data: {
          "source": source,
          "target": target,
        },
      );

      List<Map<String, dynamic>> sensorsWithCoordinates =
          (response.data['fastest_path'] as List)
              .cast<Map<String, dynamic>>();
      
      return sensorsWithCoordinates;
    } catch (e) {
      throw Exception(
          "Failed to fetch fastest route with error: $e");
    }
  }
}