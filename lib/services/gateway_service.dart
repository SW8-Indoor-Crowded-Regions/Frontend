import 'package:dio/dio.dart';

class GatewayService {
  final dio = Dio();
  final String baseUrl = "http://localhost:8000/";

  Future<List<String>> getFastestRouteIds(String source, String target) async {
    try {
      Response response = await dio.post(
        "${baseUrl}fastest-path",
        data: {
          "source": source,
          "target": target,
        },
      );

      List<String> ids = List<String>.from(response.data['fastest_path']);
      return ids;

    } catch (e) {
      throw Exception("Failed to fetch fastest route IDs: $e");
    }
  }
}