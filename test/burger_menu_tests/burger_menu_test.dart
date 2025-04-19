import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:indoor_crowded_regions_frontend/my_app.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:indoor_crowded_regions_frontend/ui/widgets/exhibits_menu.dart';
import 'package:indoor_crowded_regions_frontend/ui/widgets/burger_menu.dart';

void main() {
  setUpAll(() async {
    await dotenv.load(fileName: ".env");
  });

  testWidgets(
      'MyApp renders HomeScreen and opens Drawer when burger menu is tapped',
      (WidgetTester tester) async {
    // Build app and wait for all async operations to complete.
    await tester.pumpWidget(const MyApp(isTestMode: true));
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

  testWidgets('Exhibits menu closes when back button is tapped',
      (WidgetTester tester) async {
    bool isExhibitsMenuVisible = true;

    await tester.pumpWidget(
      MaterialApp(
        home: ExhibitsMenu(
          showExhibitsMenu: (show) {
            isExhibitsMenuVisible = show;
          },
        ),
      ),
    );

    // Ensure the exhibits menu is displayed initially
    expect(find.text("Search Exhibits"), findsOneWidget);
    expect(find.byType(SearchBar), findsOneWidget);
    // Tap the back button
    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pump();

    // Verify the callback updates the state correctly
    expect(isExhibitsMenuVisible, false);
  });

  testWidgets('Text field is able to be altered', (WidgetTester tester) async {
    // Build the widget tree
    await tester.pumpWidget(const MaterialApp(home: ExhibitsMenu()));
    // Find the search bar
    final textField = find.byType(TextField);
    expect(textField, findsOneWidget);
    // Enter text into the search bar
    await tester.enterText(textField, "Mona Lisa");
    expect(find.text("Mona Lisa"), findsOneWidget);
  });
}
