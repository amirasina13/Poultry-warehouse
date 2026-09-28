import 'package:intl/intl.dart';

class DateTimeParser {
  // to return time only
  String parseTime(String input) {
    final DateFormat inputFormat = DateFormat("yyyy-MM-dd hh:mm");
    DateTime dateTime = inputFormat.parse(input);

    final DateFormat timeFormat = DateFormat("hh:mm a");
    String timeOnly = timeFormat.format(dateTime);

    return timeOnly;
  }

  // to return date only
  String parseDate(String input) {
    try {
      final DateFormat dateFormat = DateFormat("yyyy-MM-dd");
      DateTime dateTimeParse = dateFormat.parse(input.trim());
      final DateFormat outputFormat = DateFormat("yyyy-MM-dd");

      return outputFormat.format(dateTimeParse);
    } catch (e) {
      return "";
    }

    // // final DateFormat inputFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
    // DateTime dateTime = DateTime.parse(input);

    // String dateOnly = dateFormat.format(dateTime);

    // return dateOnly;
  }

  // to return current date and time in yyyy-MM-dd HH:mm:ss format
  String getCurrentDateTime() {
    final now = DateTime.now();
    final formattedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    return formattedDateTime;
  }

  // to return current date and time in yyyy-MM-dd HH:mm PM/AM format
  String getDateTime(String dateTimeStr) {
    DateTime date = DateTime.parse(dateTimeStr);
    String formattedTime = DateFormat('yyyy-MM-dd hh:mm a').format(date);

    return formattedTime;
  }
}
