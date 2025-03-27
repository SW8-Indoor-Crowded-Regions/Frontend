import 'package:dio/dio.dart';

class GatewayService {
  final dio = Dio();
  final String baseUrl = "http://localhost:8000/";

  Future<Response> getFastestRoute(String source, String target) async {
    try {
      Response response;
      response = await dio.post(
        "${baseUrl}fastest-path",
        data: {
          "source": source,
          "target": target,
        },
      );
      print(response.data);
      return response;
    } catch (e) {
      throw Exception("Failed to fetch fastest route: $e");
    }
  }
}