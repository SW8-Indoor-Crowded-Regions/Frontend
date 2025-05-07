import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:indoor_crowded_regions_frontend/ui/components/error_toast.dart';

class GatewayService {
  final dio = Dio();

  Future<List<Map<String, dynamic>>> getFastestRouteWithCoordinates(
      String source, String target) async {
    try {
      final String baseUrl = dotenv.env['BASE_URL'] ?? "http://localhost:8000";
      Response response = await dio.post(
        "$baseUrl/fastest-path",
        data: {
          "source": source,
          "target": target,
        },
      );

      List<Map<String, dynamic>> sensorsWithCoordinates =
          (response.data['fastest_path'] as List).cast<Map<String, dynamic>>();

      return sensorsWithCoordinates;
    } catch (e) {
      ErrorToast.show("Failed to fetch fastest path");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getFastestMultiRoomPath(
      String source, List<String> roomNames) async {
    try {
      final String baseUrl = dotenv.env['BASE_URL'] ?? "http://localhost:8000";
      Response response = await dio.post(
        "$baseUrl/multi-point-path",
        data: {
          "source": source,
          "target": roomNames,
        },
      );

      List<Map<String, dynamic>> path =
          (response.data['fastest_path'] as List).cast<Map<String, dynamic>>();

      return path;
    } catch (e) {
      ErrorToast.show("Failed to fetch multi-room path");
      return [];
    }
  }
}
