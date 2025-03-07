import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indoor_crowded_regions_frontend/my_app.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:indoor_crowded_regions_frontend/ui/widgets/burger_menu.dart';
import 'package:indoor_crowded_regions_frontend/ui/screens/home_screen.dart';

void main() {
  testWidgets('Renders HomeScreen, FlutterMap and rooms when zoom level is high enough', (WidgetTester tester) async {
    // Build the MyApp widget and wait for asynchronous operations.
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify that the AppBar and FlutterMap widgets are present.
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byType(FlutterMap), findsOneWidget);

    // Access the HomeScreen state and update the zoom level.
    final homeScreenState = tester.state(find.byType(HomeScreen)) as dynamic;
    homeScreenState.setZoom(19.0);
    await tester.pumpAndSettle();

    // Instead of searching for a Room (data model), we check for the rendered icon.
    // Room markers use the Icons.place icon.
    expect(find.byIcon(Icons.place), findsWidgets);
  });


  testWidgets('Renders SMK map and finds room 101', (WidgetTester tester) async {
    // Build the MyApp widget and wait for asynchronous operations.
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify that the AppBar and FlutterMap widgets are present.
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byType(FlutterMap), findsOneWidget);

    // Access the HomeScreen state and update the zoom level.
    final homeScreenState = tester.state(find.byType(HomeScreen)) as dynamic;
    homeScreenState.setZoom(19.0);
    await tester.pumpAndSettle();

    // Check that room markers (which use Icons.place) are rendered.
    final markerIconFinder = find.byIcon(Icons.place);
    expect(markerIconFinder, findsWidgets);

    // Tap the first marker, which corresponds to "Room 101" in the room list.
    await tester.tap(markerIconFinder.first);
    await tester.pumpAndSettle();

    // Expect that the AlertDialog is shown with the title "Room 101".
    expect(find.text("Room 101"), findsOneWidget);
  });
}
