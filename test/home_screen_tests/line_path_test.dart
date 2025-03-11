import 'package:indoor_crowded_regions_frontend/data/models/graph_models.dart';
import 'package:indoor_crowded_regions_frontend/ui/screens/home_screen.dart';
import 'package:indoor_crowded_regions_frontend/ui/widgets/path/line_path.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<Map<String, dynamic>> mockLoadGraphData() async {
  return {
    'edges': <EdgeModel>[
      EdgeModel(source: 1, target: 2, population: 500),
      EdgeModel(source: 2, target: 3, population: 1500),
      EdgeModel(source: 3, target: 4, population: 2000),
    ],
    'nodeMap': <int, NodeModel>{
      1: NodeModel(id: 1, latitude: 55.68875, longitude: 12.577592),
      2: NodeModel(id: 2, latitude: 55.68875, longitude: 12.577687),
      3: NodeModel(id: 3, latitude: 55.68875, longitude: 12.577782),
      4: NodeModel(id: 4, latitude: 55.68875, longitude: 12.577877),
    },
  };
}

void main() {
  testWidgets('Finds a LinePath widget', (WidgetTester tester) async {
    // Uses mock data to avoid reading from the filesystem
    await tester.runAsync(() async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreenTestWrapper(
            loadGraphDataOverride: mockLoadGraphData,
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
            loadGraphDataOverride: mockLoadGraphData,
            skipUserLocation: true,
          ),
        ),
      );
      await tester.pumpAndSettle();
    });

    // Verify that the Polyline widgets are present in the widget tree
    expect(find.byType(PolylineLayer), findsOneWidget);
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