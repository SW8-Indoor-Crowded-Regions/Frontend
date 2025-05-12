import 'package:dio/dio.dart';
import 'package:indoor_crowded_regions_frontend/utils/env.dart';
import 'package:indoor_crowded_regions_frontend/ui/components/error_toast.dart';
import '../models/polygon_area.dart';

class PolygonService {
  final dio = Dio();

  Future<List<PolygonArea>> getPolygons({int? floor}) async {
    try {
      final response = await dio.get(
        "$baseUrl/rooms",
        queryParameters: floor != null ? {"floor": floor} : null,
      );

      if (response.statusCode != 200) {
        if (!response.data?['detail']) {
          throw Exception("Failed to fetch rooms");
        }
        ErrorToast.show(response.data['detail']);
      }

      final List<dynamic> roomsData = response.data['rooms'] as List;
      return roomsData.map((room) => PolygonArea.fromJson(room)).toList();
    } catch (e) {
      ErrorToast.show("Failed to connect to the server. Please check your connection.");
      return [];
    }
  }
}
