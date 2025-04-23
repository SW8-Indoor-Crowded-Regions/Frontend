import 'package:indoor_crowded_regions_frontend/my_app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_map/flutter_map.dart';

void main() {
  setUpAll(() async {
    dotenv.dotenv.testLoad(mergeWith: {'BASE_URL': 'http://localhost:8000', 'FLUTTER_TEST': 'true'});
  });

  testWidgets(
      'Renders SMK map without zooming to level 19 and does not find any icons',
      (WidgetTester tester) async {
    // Build the MyApp widget and wait for asynchronous operations.
    await tester.pumpWidget(const MyApp(isTestMode: true));
    await tester.pump(const Duration(seconds: 1));

    // Verify that the AppBar and FlutterMap widgets are present.
    expect(find.byType(FlutterMap), findsOneWidget);

    // Check that room markers (which use Icons.place) are not rendered.
    final markerIconFinder = find.byIcon(Icons.place);
    expect(markerIconFinder, findsNothing);
    await tester.pump(const Duration(seconds: 1));
  });
}
