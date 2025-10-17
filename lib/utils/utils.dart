import 'dart:io';

import 'package:intl/intl.dart' as intl;

class Utils {
  /// 判断是否为桌面设备
  static bool isDesktop() {
    return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  }

  /// 格式化时长显示
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  static String formatTime(int position, int duration) {
    return '${formatDuration(Duration(milliseconds: position))}/${formatDuration(Duration(milliseconds: duration))}';
  }

  static String formatDateTime(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return intl.DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }

  // 格式化最后观看时间
  static String formatLastWatchTime(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}年前';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}个月前';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
}
