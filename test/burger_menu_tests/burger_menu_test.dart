import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;
import 'package:indoor_crowded_regions_frontend/my_app.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:indoor_crowded_regions_frontend/ui/widgets/exhibits_menu.dart';
import 'package:indoor_crowded_regions_frontend/ui/widgets/burger_menu.dart';

void main() {
  setUpAll(() async {
    dotenv.dotenv.testLoad(mergeWith: {'BASE_URL': 'http://localhost:8000', 'FLUTTER_TEST': 'true'});
  });

  testWidgets(
      'MyApp renders HomeScreen and opens Drawer when burger menu is tapped',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(isTestMode: true));
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(FlutterMap), findsOneWidget);
    final burgerIconFinder = find.byIcon(Icons.menu);
    expect(burgerIconFinder, findsOneWidget);
    expect(find.byType(BurgerMenu), findsOneWidget);

    await tester.tap(burgerIconFinder);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Bathrooms'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
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

    expect(find.text("Search Exhibits"), findsOneWidget);
    expect(find.byType(SearchBar), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pump();

    expect(isExhibitsMenuVisible, false);
  });

  testWidgets('Text field is able to be altered', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: ExhibitsMenu()));
    final textField = find.byType(TextField);
    expect(textField, findsOneWidget);
    await tester.enterText(textField, "Mona Lisa");
    expect(find.text("Mona Lisa"), findsOneWidget);
  });
}
