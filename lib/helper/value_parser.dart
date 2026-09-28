/// Utility class for safe type casting and JSON API value formatting.
class ValueParser {
  /// Safely parses dynamic input into an [int].
  /// Returns [0] if input is null or unparseable.
  static int parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value.trim()) ?? 0;
    return 0;
  }

  /// Safely parses dynamic input into a [double].
  /// Returns [0.0] if input is null or unparseable.
  static double parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value.trim()) ?? 0.0;
    return 0.0;
  }

  /// Converts values to [String] for display/ui without destroying zeroes.
  /// Returns empty string `""` only if actual null, "null", or empty.
  static String formatValue(dynamic value) {
    if (value == null) return "";

    final str = value.toString().trim();
    if (str.isEmpty || str.toLowerCase() == "null") {
      return "";
    }

    // Format double zeroes consistently
    final numValue = num.tryParse(str);
    if (numValue != null && numValue == 0) {
      return "";
    }

    return str;
  }

  // ===========================================================================
  // JSON API PAYLOAD HELPERS
  // ===========================================================================

  /// Use for JSON API numeric fields (e.g., qty, weight).
  /// Preserves numbers (including 0) and returns [null] if missing.
  static num? formatNumberPayload(dynamic value) {
    if (value == null) return null;
    if (value is num) return value;

    final str = value.toString().trim();
    if (str.isEmpty || str.toLowerCase() == "null") return null;

    return num.tryParse(str);
  }

  /// Use for JSON API text/ID fields (e.g., vendor_id, remarks).
  /// Returns clean [String] or [null] for empty/missing items.
  static String? formatStringPayload(dynamic value) {
    final str = formatValue(value);
    return str.isEmpty ? null : str;
  }
}

// double parseDouble(dynamic value) {
//   if (value == null) return 0.00;
//   if (value is double) return value;
//   if (value is int) return value.toDouble(); //value.toString();
//   if (value is String) return double.tryParse(value.trim()) ?? 0.00;
//   return 0.00;
// }

// int parseInt(dynamic value) {
//   if (value == null) return 0;
//   if (value is int) return value;
//   if (value is double) return value.toInt();
//   if (value is String) return int.tryParse(value.trim()) ?? 0;
//   return 0;
// }

// String formatValue(dynamic value) {
//   // Check for actual null, the string "null", or an empty string
//   if (value == null ||
//       value.toString().toLowerCase() == "null" ||
//       value.toString().trim().isEmpty) {
//     return "";
//   }

//   if (value is double && value == 0.0 || value == "0.0" || value == "0.00") {
//     return "0.0";
//   }

//   // Also check for 0 if you still want that converted to empty
//   if (value == 0 || value == "0") {
//     return "0";
//   }

//   return value.toString();
// }

// double toDouble(dynamic value) {
//   if (value == null) return 0.0;
//   if (value is double) return value;
//   if (value is int) return value.toDouble();
//   return double.tryParse(value.toString()) ?? 0.0;
// }
