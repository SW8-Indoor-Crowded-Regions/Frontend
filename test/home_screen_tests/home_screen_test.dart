import 'package:indoor_crowded_regions_frontend/my_app.dart';
import 'package:indoor_crowded_regions_frontend/ui/screens/home_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_map/flutter_map.dart';


void main() {
  testWidgets('Renders HomeScreen, FlutterMap and rooms when zoom level is high enough', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.byType(FlutterMap), findsOneWidget);

    final homeScreenState = tester.state(find.byType(HomeScreen)) as dynamic;
    homeScreenState.setZoom(19.0);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.place), findsWidgets);
    await tester.pumpAndSettle();
  });


  testWidgets('Renders SMK map without zooming to level 19 and does not find any icons', (WidgetTester tester) async {
    // Build the MyApp widget and wait for asynchronous operations.
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify that the AppBar and FlutterMap widgets are present.
    expect(find.byType(FlutterMap), findsOneWidget);

    // Check that room markers (which use Icons.place) are not rendered.
    final markerIconFinder = find.byIcon(Icons.place);
    expect(markerIconFinder, findsNothing);
    await tester.pumpAndSettle();
  });
}