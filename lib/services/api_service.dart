import 'package:dio/dio.dart';
import 'package:indoor_crowded_regions_frontend/utils/env.dart';
import 'package:indoor_crowded_regions_frontend/ui/components/error_toast.dart';

class APIService {
  final dio = Dio(BaseOptions(
    baseUrl: baseUrl
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

  Future<Response> getArtwork(String query, {int rows = 20, int offset = 0, bool roomIdQuery = false}) async {
    try {
      Response response;
      response = await dio.get("/artwork", queryParameters: {
        roomIdQuery ? "room" : "keys" : query,
        "rows": rows,
        "offset": offset,
      });
      return response;
    } catch (e) {
      roomIdQuery 
        ? ErrorToast.show("Failed to fetch artworks for room") 
        : ErrorToast.show("Failed to fetch artwork");
      rethrow;
    }
  }
}