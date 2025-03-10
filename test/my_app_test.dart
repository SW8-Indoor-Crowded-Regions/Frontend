import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indoor_crowded_regions_frontend/my_app.dart';
import 'package:indoor_crowded_regions_frontend/ui/screens/home_screen.dart';

void main() {
  testWidgets('MyApp renders MaterialApp with correct title, theme and HomeScreen', (WidgetTester tester) async {
    // Build MyApp and wait for animations and async operations.
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify that MaterialApp is rendered.
    final materialAppFinder = find.byType(MaterialApp);
    expect(materialAppFinder, findsOneWidget);

    // Retrieve the MaterialApp widget and verify its title.
    final MaterialApp materialApp = tester.widget(materialAppFinder);
    expect(materialApp.title, equals('SMK Map'));

    // Check that the app's theme uses Material3.
    final BuildContext context = tester.element(materialAppFinder);
    final ThemeData theme = Theme.of(context);
    expect(theme.useMaterial3, isTrue);

    // Verify that HomeScreen is set as the home widget.
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
