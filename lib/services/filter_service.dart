import 'package:dio/dio.dart';
import 'package:indoor_crowded_regions_frontend/utils/env.dart';
import 'package:indoor_crowded_regions_frontend/ui/components/error_toast.dart';

class FilterService {
  final dio = Dio(BaseOptions(
    baseUrl: baseUrl
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

  Future<List<dynamic>> getRoomsFromFilters(Map<String, dynamic> filters) async {
    try {
      Response response = await dio.post("/filters/rooms", data: filters);
      return response.data;
    } catch (e) {
      ErrorToast.show("Failed to fetch rooms from filters");
      rethrow;
    }
  }

}