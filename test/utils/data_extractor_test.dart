import 'package:flutter_test/flutter_test.dart';
import 'package:indoor_crowded_regions_frontend/utils/data_extractor.dart';

void main() {
  group('DataExtractor Tests', () {
    test('extractValue should return value for existing key', () {
      final item = {'name': 'Test Item', 'id': 123};
      expect(DataExtractor.extractValue(item, 'name'), 'Test Item');
      expect(DataExtractor.extractValue(item, 'id'), '123');
    });

    test('extractValue should return "Unknown" for missing key', () {
      final item = {'name': 'Test Item'};
      expect(DataExtractor.extractValue(item, 'description'), 'Unknown');
    });

    test('extractValue should return "Unknown" for null item', () {
      expect(DataExtractor.extractValue(null, 'name'), 'Unknown');
    });

    test('extractValue should return "Unknown" for null value at key', () {
      final item = {'name': null};
      expect(DataExtractor.extractValue(item, 'name'), 'Unknown');
    });

    test('extractValue should return the first item for a list value', () {
      final item = {
        'tags': ['tag1', 'tag2']
      };
      expect(DataExtractor.extractValue(item, 'tags'), 'tag1');
    });

    test('extractValue should return "Unknown" for an empty list value', () {
      final item = {'tags': []};
      expect(DataExtractor.extractValue(item, 'tags'), 'Unknown');
    });

    test('extractListValues should return list of values for existing list key',
        () {
      final item = {
        'tags': ['tag1', 'tag2', 'tag3']
      };
      expect(DataExtractor.extractListValues(item, 'tags'),
          ['tag1', 'tag2', 'tag3']);
    });

    test(
        'extractListValues should return empty list for existing non-list key',
        () {
      final item = {'name': 'Test Item'};
      expect(DataExtractor.extractListValues(item, 'name'), []);
    });

    test('extractListValues should return empty list for missing key', () {
      final item = {'name': 'Test Item'};
      expect(DataExtractor.extractListValues(item, 'tags'), []);
    });

    test('extractListValues should return empty list for null item', () {
      expect(DataExtractor.extractListValues(null, 'tags'), []);
    });

    test('extractListValues should return empty list for null value at key',
        () {
      final item = {'tags': null};
      expect(DataExtractor.extractListValues(item, 'tags'), []);
    });

    test('extractListValues should return empty list on error', () {
      // Simulate an error
      final item = {
        'tags': ComplexObject()
      }; // Assuming ComplexObject is not a List
      expect(DataExtractor.extractListValues(item, 'tags'), []);
    });

    test('extractTitle should return the first title from the list', () {
      final exhibit = {
        'titles': [
          {'title': 'Main Title', 'lang': 'en'},
          {'title': 'Alternate Title', 'lang': 'fr'}
        ]
      };
      expect(DataExtractor.extractTitle(exhibit), 'Main Title');
    });

    test('extractTitle should return "Untitled" for missing "titles" key', () {
      final exhibit = {'artist': 'Unknown'};
      expect(DataExtractor.extractTitle(exhibit), 'Untitled');
    });

    test('extractTitle should return "Untitled" for empty "titles" list', () {
      final exhibit = {'titles': []};
      expect(DataExtractor.extractTitle(exhibit), 'Untitled');
    });

    test('extractTitle should return "Untitled" for null "titles" list', () {
      final exhibit = {'titles': null};
      expect(DataExtractor.extractTitle(exhibit), 'Untitled');
    });

    test('extractTitle should return "Untitled" if title in item is null', () {
      final exhibit = {
        'titles': [
          {'title': null, 'lang': 'en'}
        ]
      };
      expect(DataExtractor.extractTitle(exhibit), 'Untitled');
    });

    test('extractTitle should return "Untitled" on error', () {
      // Simulate an error
      final exhibit = {
        'titles': ComplexObject()
      }; // Assuming ComplexObject is not a List
      expect(DataExtractor.extractTitle(exhibit), 'Untitled');
    });

    test('extractArtist should return the first artist from the list', () {
      final exhibit = {
        'artist': ['Artist Name 1', 'Artist Name 2']
      };
      expect(DataExtractor.extractArtist(exhibit), 'Artist Name 1');
    });

    test('extractArtist should return "Unknown" for missing "artist" key', () {
      final exhibit = {'title': 'Test Title'};
      expect(DataExtractor.extractArtist(exhibit), 'Unknown');
    });

    test('extractArtist should return "Unknown" for empty "artist" list', () {
      final exhibit = {'artist': []};
      expect(DataExtractor.extractArtist(exhibit), 'Unknown');
    });

    test('extractArtist should return "Unknown" for null "artist" list', () {
      final exhibit = {'artist': null};
      expect(DataExtractor.extractArtist(exhibit), 'Unknown');
    });

    test('extractArtist should return "Unknown" if artist in item is null', () {
      final exhibit = {
        'artist': [null]
      };
      expect(DataExtractor.extractArtist(exhibit), 'Unknown');
    });

    test('extractArtist should return "Unknown" on error', () {
      // Simulate an error
      final exhibit = {
        'artist': ComplexObject()
      }; // Assuming ComplexObject is not a List
      expect(DataExtractor.extractArtist(exhibit), 'Unknown');
    });

    test('extractLocation should return location for existing key', () {
      final exhibit = {'current_location_name': 'Gallery A'};
      expect(DataExtractor.extractLocation(exhibit), 'Gallery A');
    });

    test('extractLocation should return "Not on display" for missing key', () {
      final exhibit = {'title': 'Test Title'};
      expect(DataExtractor.extractLocation(exhibit), 'Not on display');
    });

    test('extractLocation should return "Not on display" for null value at key',
        () {
      final exhibit = {'current_location_name': null};
      expect(DataExtractor.extractLocation(exhibit), 'Not on display');
    });
  });
}

// Helper class to simulate a complex object that might cause an error
class ComplexObject {}