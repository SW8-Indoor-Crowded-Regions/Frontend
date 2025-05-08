/// Utility class for formatting date information from exhibit data
class DateFormatter {
  static String formatDating(dynamic exhibit) {
    try {
      if (exhibit == null || exhibit["production_date"] == null) {
        return "Unknown";
      }

      if (exhibit["production_date"] is List) {
        final dateList = exhibit["production_date"] as List;
        // Handle the case where the list is empty
        if (dateList.isEmpty) {
          return "Unknown";
        }

        // Now process the non-empty list
        final firstDate = dateList[0];
        if (firstDate is Map) {
          if (firstDate.containsKey("period")) {
            if (firstDate["period"] != null) {
               return firstDate["period"].toString();
            } else {
               return "Unknown";
            }
          }
        }
      }

      final date = exhibit["production_date"];
       if (date != null) {
         return date
             .toString()
             .replaceAll(RegExp(r'[{}[\]]'), '');
       } else {
         // This else might be redundant due to the initial null check,
         // but provides a final safeguard.
         return "Unknown";
       }

    } catch (e) {
      return "Unknown";
    }
  }
}