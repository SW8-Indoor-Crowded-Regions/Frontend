import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:indoor_crowded_regions_frontend/ui/components/error_toast.dart';

class FilterService {
  final dio = Dio(BaseOptions(
    baseUrl: dotenv.env['baseUrl'] ?? "http://localhost:8000",
  ));

  Future<Response> getFilters() async {
    try {
      Response response = await dio.get("/filters/");
      return response;
    } catch (e) {
      ErrorToast.show("Failed to fetch filters");
      rethrow;
    }
  }

  Future<Response> getRoomsFromFilters(Map<String, dynamic> filters) async {
    try {
      Response response = await dio.post("/filters/rooms", data: filters);
      return response;
    } catch (e) {
      ErrorToast.show("Failed to fetch rooms from filters");
      rethrow;
    }
  }

}