import 'package:indoor_crowded_regions_frontend/ui/screens/home_screen.dart';
import 'package:indoor_crowded_regions_frontend/ui/widgets/path/line_path.dart';
import 'package:indoor_crowded_regions_frontend/services/gateway_service.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;

class MockGatewayService extends Mock implements GatewayService {
  @override
  noSuchMethod(Invocation invocation,
          {Object? returnValue, Object? returnValueForMissingStub}) =>
      super.noSuchMethod(
        invocation,
        returnValue: Future.value(<Map<String, dynamic>>[]),
        returnValueForMissingStub: Future.value(<Map<String, dynamic>>[]),
      );
}

void main() {
  setUpAll(() async {
    dotenv.dotenv.testLoad(mergeWith: {'BASE_URL': 'http://localhost:8000'});
  });

  testWidgets('Finds a LinePath widget', (WidgetTester tester) async {
    final mockGatewayService = MockGatewayService();

    when(mockGatewayService.getFastestRouteWithCoordinates("test", "test"))
        .thenAnswer((_) async => [
              {"id": "sensor1", "longitude": 12.577325, "latitude": 55.688495},
              {"id": "sensor2", "longitude": 12.577545, "latitude": 55.688732},
            ]);

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreenTestWrapper(
          skipUserLocation: true,
          loadGraphDataOverride: (dynamic _) async =>
              mockGatewayService.getFastestRouteWithCoordinates("test", "test"),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(LinePath), findsOneWidget);
  });

  testWidgets('Finds a PolylineLayer', (WidgetTester tester) async {
    final mockGatewayService = MockGatewayService();

    when(mockGatewayService.getFastestRouteWithCoordinates("test", "test"))
        .thenAnswer((_) async => [
              {"id": "sensor1", "longitude": 12.577325, "latitude": 55.688495},
              {"id": "sensor2", "longitude": 12.577545, "latitude": 55.688732},
            ]);

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreenTestWrapper(
          skipUserLocation: true,
          loadGraphDataOverride: (_) async =>
              mockGatewayService.getFastestRouteWithCoordinates("test", "test"),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(PolylineLayer), findsOneWidget);
  });

  testWidgets('Finds the line path with color blue',
      (WidgetTester tester) async {
    final mockGatewayService = MockGatewayService();

    when(mockGatewayService.getFastestRouteWithCoordinates("test", "test"))
        .thenAnswer((_) async => [
              {"id": "sensor1", "longitude": 12.577325, "latitude": 55.688495},
              {"id": "sensor2", "longitude": 12.577545, "latitude": 55.688732},
              {"id": "sensor3", "longitude": 12.577640, "latitude": 55.688732},
            ]);

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreenTestWrapper(
          skipUserLocation: true,
          loadGraphDataOverride: (_) async =>
              mockGatewayService.getFastestRouteWithCoordinates("test", "test"),
        ),
      ),
    );

    await tester.pump(const Duration(seconds: 1));

    final polylineLayerFinder = find.byType(PolylineLayer);
    expect(polylineLayerFinder, findsOneWidget);

    final polylineLayer =
        tester.widget<PolylineLayer>(find.byType(PolylineLayer));
    final polylines = polylineLayer.polylines;

    final colorsUsed = polylines.map((p) => p.color).toSet();

    expect(colorsUsed, contains(Colors.blue));
  });
}

class HomeScreenTestWrapper extends StatelessWidget {
  final Future<List<Map<String, dynamic>>> Function(dynamic)?
      loadGraphDataOverride;
  final bool skipUserLocation;

  const HomeScreenTestWrapper({
    super.key,
    this.loadGraphDataOverride,
    this.skipUserLocation = false,
  });

  @override
  Widget build(BuildContext context) {
    return HomeScreen(
      loadGraphDataFn: loadGraphDataOverride,
      skipUserLocation: skipUserLocation,
      isTestMode: true,
    );
  }
}
