/// Utility class for formatting date information from exhibit data
class DateFormatter {
  /// Format dating information into a simple string
  static String formatDating(dynamic exhibit) {
    try {
      // Check if production_date exists
      if (exhibit["production_date"] == null) {
        return "Unknown";
      }

      // Based on runtime analysis, we only need to handle the case where
      // production_date is a List with a single Map item containing a period field
      if (exhibit["production_date"] is List) {
        final dateList = exhibit["production_date"] as List;
        if (dateList.isNotEmpty) {
          final firstDate = dateList[0];
          if (firstDate is Map &&
              firstDate.containsKey("period") &&
              firstDate["period"] != null) {
            return firstDate["period"].toString();
          }
        }
      }

      // Fallback: just convert to string
      return exhibit["production_date"]
          .toString()
          .replaceAll(RegExp(r'[{}[\]]'), '');
    } catch (e) {
      return "Unknown";
    }
  }
}
