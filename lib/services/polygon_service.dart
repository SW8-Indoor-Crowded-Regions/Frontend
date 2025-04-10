import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/polygon_area.dart';
import 'package:latlong2/latlong.dart';


class PolygonService {
  final dio = Dio();
  final String baseUrl;

  PolygonService() : baseUrl = dotenv.env['BASE_URL'] ?? "http://localhost:8000";

  Future<List<PolygonArea>> getPolygons({int? floor}) async {
    try {
      final response = await dio.get(
        "$baseUrl/rooms",
        queryParameters: floor != null ? {"floor": floor} : null,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List;
        return data.map((json) => PolygonArea.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load polygons');
      }
    } catch (e) {
      throw Exception('Failed to fetch polygons: $e');
    }
  }
  // Example mock data for testing without backend
  List<PolygonArea> getMockPolygons() {
    return [
      PolygonArea(
        id: "1",
        name: "Test Area 1",
        points: [
          LatLng(55.68850, 12.57850),
          LatLng(55.68860, 12.57850),
          LatLng(55.68860, 12.57860),
          LatLng(55.68850, 12.57860),
        ],
        additionalData: {
          "type": "room",
          "floor": 1,
        },
      ),
    ];
  }
}
