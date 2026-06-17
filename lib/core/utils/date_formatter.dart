import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String format(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, HH:mm').format(dateTime.toLocal());
  }

  static String formatDate(DateTime dateTime) {
    return DateFormat('dd MMM yyyy').format(dateTime.toLocal());
  }

  static String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime.toLocal());

    if (difference.inDays > 7) {
      return formatDate(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
