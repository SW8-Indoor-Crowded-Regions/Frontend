import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indoor_crowded_regions_frontend/my_app.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:indoor_crowded_regions_frontend/ui/widgets/burger_menu.dart';

void main() {
  testWidgets('MyApp renders HomeScreen and opens Drawer when burger menu is tapped', (WidgetTester tester) async {
    // Build app and wait for all async operations to complete.
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Check that a FlutterMap widget is in the widget tree.
    expect(find.byType(FlutterMap), findsOneWidget);

    // Verify the burger menu icon exists.
    final burgerIconFinder = find.byIcon(Icons.menu);
    expect(burgerIconFinder, findsOneWidget);
    expect(find.byType(BurgerMenu), findsOneWidget);

    // Tap the burger menu icon to open the Drawer and check if "Bathrooms" is present.
    await tester.tap(burgerIconFinder);
    await tester.pumpAndSettle();
    expect(find.text('Bathrooms'), findsOneWidget);

    await tester.pumpAndSettle();
  });
}
