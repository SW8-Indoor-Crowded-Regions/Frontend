import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:indoor_crowded_regions_frontend/ui/components/error_toast.dart';

class APIService {
  final dio = Dio(BaseOptions(
    baseUrl: dotenv.env['baseUrl'] ?? "http://localhost:8000",
  ));

  Future<Response> searchArtwork(String query) async {
    try {
      Response response;
      response = await dio.get("/search-artwork", queryParameters: {"keys": query});
      return response;
    } catch (e) {
      ErrorToast.show("Failed to fetch artwork");
      rethrow;
    }
  }

  Future<Response> getArtwork(String query, {int rows = 20, int offset = 0}) async {
    try {
      Response response;
      response = await dio.get("/artwork", queryParameters: {
        "keys": query,
        "rows": rows,
        "offset": offset,
      });
      return response;
    } catch (e) {
      ErrorToast.show("Failed to fetch artwork");
      rethrow;
    }
  }

}