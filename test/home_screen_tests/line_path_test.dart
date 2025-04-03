import 'package:indoor_crowded_regions_frontend/ui/screens/home_screen.dart';
import 'package:indoor_crowded_regions_frontend/ui/widgets/path/line_path.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Finds a LinePath widget', (WidgetTester tester) async {
    // Uses mock data to avoid reading from the filesystem
    await tester.runAsync(() async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreenTestWrapper(
            skipUserLocation: true,
          ),
        ),
      );
      // Ensures all asynchronous tasks (like your Future) have completed
      await tester.pumpAndSettle();
    });

    // Verify the LinePath is present in the widget tree
    expect(find.byType(LinePath), findsOneWidget);
  });

  testWidgets('Finds a PolyLineLayer', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreenTestWrapper(
            skipUserLocation: true,
          ),
        ),
      );
      await tester.pumpAndSettle();
    });

    // Verify that the Polyline widgets are present in the widget tree
    expect(find.byType(PolylineLayer), findsOneWidget);
  });

  testWidgets('Finds the three colors "green, yellow and red"', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreenTestWrapper(
            skipUserLocation: true,
          ),
        ),
      );
      await tester.pumpAndSettle();
    });

    final polylineLayer = tester.widget<PolylineLayer>(find.byType(PolylineLayer));
    final polylines = polylineLayer.polylines;
    final colors = polylines.map((p) => p.color).toSet();

    expect(colors, contains(Colors.green));
    expect(colors, contains(Colors.yellow));
    expect(colors, contains(Colors.red));
  });
}

class HomeScreenTestWrapper extends StatelessWidget {
  final Future<Map<String, dynamic>> Function()? loadGraphDataOverride;
  final bool skipUserLocation;
  
  const HomeScreenTestWrapper({
    super.key,
    this.loadGraphDataOverride,
    this.skipUserLocation = false,
    });
  
  @override
  Widget build(BuildContext context) {
    // Overriding the loadGraphData function in HomeScreen
    return HomeScreen(loadGraphDataFn: loadGraphDataOverride, skipUserLocation: skipUserLocation);
  }
}