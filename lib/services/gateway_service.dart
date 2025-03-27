import 'package:dio/dio.dart';

class APIService {
  final dio = Dio();
  final String baseUrl = "http://localhost:8000/";

  Future<Response> getFastestRoute(String query) async {
    try {
      Response response;
      response = await dio.get("${baseUrl}Jackskalfindeudafhvadderskalståher", queryParameters: {"keys": query});
      return response;
    } catch (e) {
      throw Exception("Failed to fetch artwork");
    }
  }

}