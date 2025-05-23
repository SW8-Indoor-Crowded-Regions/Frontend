import 'package:dio/dio.dart';
import 'package:indoor_crowded_regions_frontend/utils/env.dart';
import 'package:indoor_crowded_regions_frontend/ui/components/error_toast.dart';
import 'package:indoor_crowded_regions_frontend/ui/widgets/utils/types.dart';

class GatewayService {
  final dio = Dio();

  Future<List<DoorObject>> getFastestRouteWithCoordinates(
      String source, String target) async {
    try {
      Response response = await dio.post(
        "$baseUrl/fastest-path",
        data: {
          "source": source,
          "target": target,
        },
      );


      List<DoorObject> sensorsWithCoordinates =
          (response.data['fastest_path'] as List)
              .map((e) => DoorObject.fromJson(e))
              .toList();

      return sensorsWithCoordinates;
    } catch (e) {
      ErrorToast.show("Failed to fetch fastest path");
      return [];
    }
  }
  
  Future<List<DoorObject>> getFastestMultiRoomPath(
      String source, List<String> roomNames) async {
    try {
      Response response = await dio.post(
        "$baseUrl/multi-point-path",
        data: {
          "source": source,
          "targets": roomNames,
        },
      );

      List<DoorObject> path =
          (response.data['fastest_path'] as List)
              .map((e) => DoorObject.fromJson(e))
              .toList();

      return path;
    } catch (e) {
      ErrorToast.show("Failed to fetch multi-room path");
      return [];
    }
  }
}
