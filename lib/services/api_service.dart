import 'package:dio/dio.dart';

class APIService {
  final dio = Dio();
  final String baseUrl = "http://localhost:8000/";

  Future<Response> searchArtwork(String query) async {
    try {
      Response response;
      response = await dio.get("${baseUrl}search-artwork", queryParameters: {"keys": query});
      return response;
    } catch (e) {
      throw Exception("Failed to fetch artwork");
    }
  }

  Future<Response> getArtwork(String query, {int rows = 20, int offset = 0}) async {
    try {
      Response response;
      response = await dio.get("${baseUrl}artwork", queryParameters: {
        "keys": query,
        "rows": rows,
        "offset": offset,
      });
      return response;
    } catch (e) {
      throw Exception("Failed to fetch artwork");
    }
  }

}