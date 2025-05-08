import 'package:flutter_test/flutter_test.dart';
import 'package:indoor_crowded_regions_frontend/utils/date_formatter.dart';

void main() {
  group('DateFormatter Tests', () {
    test('formatDating should return "Unknown" for missing production_date key',
        () {
      final exhibit = {'title': 'Test Title'};
      expect(DateFormatter.formatDating(exhibit), 'Unknown');
    });

    test('formatDating should return "Unknown" for null production_date value',
        () {
      final exhibit = {'production_date': null};
      expect(DateFormatter.formatDating(exhibit), 'Unknown');
    });

    test(
        'formatDating should return the period string for a valid list structure',
        () {
      final exhibit = {
        'production_date': [
          {'period': '19th Century', 'details': 'Late 1800s'}
        ]
      };
      expect(DateFormatter.formatDating(exhibit), '19th Century');
    });

    test('formatDating should return "Unknown" if period field is null', () {
      final exhibit = {
        'production_date': [
          {'period': null, 'details': 'Late 1800s'}
        ]
      };
      expect(DateFormatter.formatDating(exhibit), 'Unknown');
    });

    test('formatDating should return "Unknown" for an empty production_date list',
        () {
      final exhibit = {'production_date': []};
      expect(DateFormatter.formatDating(exhibit), 'Unknown');
    });

    test(
        'formatDating should return "details: Late 1800s" for a list item without the period key',
        () {
      final exhibit = {
        'production_date': [
          {'details': 'Late 1800s'}
        ]
      };
      expect(DateFormatter.formatDating(exhibit), 'details: Late 1800s');
    });

    test(
        'formatDating should return "19th Century" for a list item that is not a Map',
        () {
      final exhibit = {
        'production_date': ['19th Century']
      };
      expect(DateFormatter.formatDating(exhibit), '19th Century');
    });

    test('formatDating should return cleaned string for a non-list value', () {
      final exhibit = {'production_date': 'circa 1850'};
      expect(DateFormatter.formatDating(exhibit), 'circa 1850');
    });

    test('formatDating should clean up structural characters in fallback', () {
      final exhibit = {'production_date': '{period: 1800s}'};
      expect(DateFormatter.formatDating(exhibit), 'period: 1800s');

      final exhibit2 = {
        'production_date': '[{"period": "19th Century"}]'
      }; // String representation of a list
      expect(DateFormatter.formatDating(exhibit2), '"period": "19th Century"');
    });

    test('formatDating should handle null exhibit gracefully', () {
      expect(DateFormatter.formatDating(null), 'Unknown');
    });
  });
}

class ComplexObject {}