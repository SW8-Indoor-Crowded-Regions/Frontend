import 'package:dio/dio.dart';

class APIService {
  final dio = Dio();
  final String baseUrl = "http://localhost:8000/";

  Future<Response> searchArtwork(String query) async {
    try {
      Response response;
      response = await dio.get("${baseUrl}smk/search-artwork", queryParameters: {"keys": query});
      return response;
    } catch (e) {
      throw Exception("Failed to fetch artwork");
    }
  }

  Future<Response> getArtwork(String query) async {
    try {
      Response response;
      response = await dio.get("${baseUrl}smk/get-artwork", queryParameters: {"keys": query});
      return response;
    } catch (e) {
      throw Exception("Failed to fetch artwork");
    }
  }

}