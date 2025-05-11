// lib/app/utils/date_formatter.dart
class DateFormatter {
  // Format date to time ago format (e.g. "2d ago", "5h ago")
  static String getTimeAgo(String publishedAt) {
    if (publishedAt.isEmpty) return "Unknown time";
    
    try {
      final publishDate = DateTime.parse(publishedAt);
      final now = DateTime.now();
      final difference = now.difference(publishDate);
      
      if (difference.inDays > 0) {
        return "${difference.inDays}d ago";
      } else if (difference.inHours > 0) {
        return "${difference.inHours}h ago";
      } else if (difference.inMinutes > 0) {
        return "${difference.inMinutes}m ago";
      } else {
        return "Just now";
      }
    } catch (e) {
      return "Unknown time";
    }
  }
}