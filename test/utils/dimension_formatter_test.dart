import 'package:flutter_test/flutter_test.dart';
import 'package:indoor_crowded_regions_frontend/utils/dimension_formatter.dart';

void main() {
  group('DimensionFormatter Tests', () {
    test(
        'formatNettoDimensions should return formatted string for all dimensions',
        () {
      final exhibit = {
        'dimensions': [
          {'part': 'Netto', 'type': 'højde', 'unit': 'centimeter', 'value': '10.5'},
          {'part': 'Netto', 'type': 'bredde', 'unit': 'centimeter', 'value': '20'},
          {'part': 'Netto', 'type': 'dybde', 'unit': 'centimeter', 'value': '5.25'},
          {'part': 'Brutto', 'type': 'højde', 'unit': 'meter', 'value': '1.1'},
        ]
      };
      expect(DimensionFormatter.formatNettoDimensions(exhibit),
          'Height: 10.5 cm × Width: 20 cm × Depth: 5.3 cm');
    });

    test('formatNettoDimensions should return formatted string for height only',
        () {
      final exhibit = {
        'dimensions': [
          {'part': 'Netto', 'type': 'højde', 'unit': 'centimeter', 'value': '150'},
          {'part': 'Brutto', 'type': 'bredde', 'unit': 'meter', 'value': '2'},
        ]
      };
      expect(DimensionFormatter.formatNettoDimensions(exhibit),
          'Height: 150 cm');
    });

    test('formatNettoDimensions should return formatted string for width only',
        () {
      final exhibit = {
        'dimensions': [
          {'part': 'Netto', 'type': 'bredde', 'unit': 'centimeter', 'value': '75.8'},
        ]
      };
      expect(
          DimensionFormatter.formatNettoDimensions(exhibit), 'Width: 75.8 cm');
    });

    test('formatNettoDimensions should return formatted string for depth only',
        () {
      final exhibit = {
        'dimensions': [
          {'part': 'Netto', 'type': 'dybde', 'unit': 'centimeter', 'value': '30'},
        ]
      };
      expect(DimensionFormatter.formatNettoDimensions(exhibit), 'Depth: 30 cm');
    });

    test(
        'formatNettoDimensions should return formatted string for height and width',
        () {
      final exhibit = {
        'dimensions': [
          {'part': 'Netto', 'type': 'højde', 'unit': 'centimeter', 'value': '100'},
          {'part': 'Netto', 'type': 'bredde', 'unit': 'centimeter', 'value': '50.1'},
        ]
      };
      expect(DimensionFormatter.formatNettoDimensions(exhibit),
          'Height: 100 cm × Width: 50.1 cm');
    });

    test('formatNettoDimensions should return null for empty dimensions list',
        () {
      final exhibit = {'dimensions': []};
      expect(DimensionFormatter.formatNettoDimensions(exhibit), null);
    });

    test('formatNettoDimensions should return null for null dimensions list',
        () {
      final exhibit = {'dimensions': null};
      expect(DimensionFormatter.formatNettoDimensions(exhibit), null);
    });

    test(
        'formatNettoDimensions should return null if no Netto centimeter dimensions are present',
        () {
      final exhibit = {
        'dimensions': [
          {'part': 'Brutto', 'type': 'højde', 'unit': 'centimeter', 'value': '100'},
          {'part': 'Netto', 'type': 'bredde', 'unit': 'meter', 'value': '0.5'},
        ]
      };
      expect(DimensionFormatter.formatNettoDimensions(exhibit), null);
    });

    test('formatNettoDimensions should ignore dimensions with missing keys',
        () {
      final exhibit = {
        'dimensions': [
          {'part': 'Netto', 'type': 'højde', 'unit': 'centimeter', 'value': '100'},
          {'part': 'Netto', 'type': 'bredde', 'unit': 'centimeter'}, // Missing value
          {'part': 'Netto', 'type': 'dybde', 'value': '10'}, // Missing unit
          {'part': 'Netto', 'unit': 'centimeter', 'value': '20'}, // Missing type
          {'type': 'højde', 'unit': 'centimeter', 'value': '5'}, // Missing part
        ]
      };
      expect(DimensionFormatter.formatNettoDimensions(exhibit),
          'Height: 100 cm');
    });

    test(
        'formatNettoDimensions should ignore dimensions with non-numeric value',
        () {
      final exhibit = {
        'dimensions': [
          {'part': 'Netto', 'type': 'højde', 'unit': 'centimeter', 'value': '100'},
          {'part': 'Netto', 'type': 'bredde', 'unit': 'centimeter', 'value': 'abc'}, // Non-numeric
        ]
      };
      expect(DimensionFormatter.formatNettoDimensions(exhibit),
          'Height: 100 cm');
    });
  });
}

// Helper class to simulate a complex object that might cause an error
class ComplexObject {}