import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/polygon_area.dart';

class PolygonService {
  final dio = Dio();
  final String baseUrl;

  PolygonService()
      : baseUrl = dotenv.env['BASE_URL'] ?? "http://localhost:8000";

  Future<List<PolygonArea>> getPolygons({int? floor}) async {
    try {
      final response = await dio.get(
        "$baseUrl/rooms",
        queryParameters: floor != null ? {"floor": floor} : null,
      );

      if (response.statusCode == 200) {
        if (response.data is Map) {
          if (response.data.containsKey('rooms')) {
            final List<dynamic> roomsData = response.data['rooms'] as List;
            return roomsData.map((room) => PolygonArea.fromJson(room)).toList();
          } else {
            throw Exception(
                'API response Map does not contain expected list key.');
          }
        } else {
          throw Exception(
              'Unexpected response format: ${response.data.runtimeType}');
        }
      } else {
        throw Exception('Failed to load polygons');
      }
    } catch (e) {
      throw Exception('Failed to fetch polygons: $e');
    }
  }
}
