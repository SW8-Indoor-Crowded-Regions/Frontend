/// Utility class for extracting data from exhibit JSON
class DataExtractor {
  /// Extract a single value from the JSON response with error handling
  static String extractValue(dynamic item, String key) {
    try {
      if (item == null || item[key] == null) return "Unknown";

      if (item[key] is List) {
        final list = item[key] as List;
        if (list.isEmpty) return "Unknown";
        return list[0].toString();
      }

      return item[key].toString();
    } catch (e) {
      // Return a default value if there's an error
      return "Unknown";
    }
  }

  /// Extract a list of values with error handling
  static List<String> extractListValues(dynamic item, String key) {
    try {
      if (item == null || item[key] == null) return [];

      if (item[key] is List) {
        final list = item[key] as List;
        return list.map((value) => value.toString()).toList();
      }

      return [];
    } catch (e) {
      // Return an empty list if there's an error
      return [];
    }
  }

  /// Extract title from exhibit data
  static String extractTitle(dynamic exhibit) {
    try {
      final titles = exhibit["titles"] as List?;
      return titles?.isNotEmpty == true
          ? titles![0]["title"]?.toString() ?? "Untitled"
          : "Untitled";
    } catch (e) {
      return "Untitled";
    }
  }

  /// Extract artist from exhibit data
  static String extractArtist(dynamic exhibit) {
    try {
      return (exhibit["artist"] as List?)?.isNotEmpty == true
          ? exhibit["artist"][0] ?? "Unknown"
          : "Unknown";
    } catch (e) {
      return "Unknown";
    }
  }

  /// Extract location from exhibit data
  static String extractLocation(dynamic exhibit) {
    return exhibit["current_location_name"] ?? "Not on display";
  }
}
