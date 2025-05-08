class DimensionFormatter {
  static String? formatNettoDimensions(dynamic exhibit) {
    final dimensions = exhibit["dimensions"];
    if (dimensions == null || dimensions.isEmpty) return null;

    double? height;
    double? width;
    double? depth;

    for (final dim in dimensions) {
      if (dim["part"] == "Netto" && dim["unit"] == "centimeter") {
        final type = dim["type"];
        final valueStr = dim["value"];
        if (valueStr == null) continue;

        final value = double.tryParse(valueStr);
        if (value == null) continue;

        if (type == "højde") {
          height = value;
        } else if (type == "bredde") {
          width = value;
        } else if (type == "dybde") {
          depth = value;
        }
      }
    }

    List<String> parts = [];
    if (height != null) parts.add("Height: ${_formatValue(height)} cm");
    if (width != null) parts.add("Width: ${_formatValue(width)} cm");
    if (depth != null) parts.add("Depth: ${_formatValue(depth)} cm");

    if (parts.isEmpty) return null;
    return parts.join(" × ");
  }

  static String _formatValue(double value) {
    if (value % 1 == 0) {
      return value.toInt().toString();
    } else {
      return value.toStringAsFixed(1);
    }
  }
}
