import 'package:fldanplay/model/video_info.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

enum DownloadStatus {
  finished, // 已完成
  downloading, // 下载中
  failed, // 失败
}

class OfflineCache extends HiveObject {
  String uniqueKey;
  VideoInfo videoInfo;
  String content;
  int fileSize;
  int cacheTime;
  DownloadStatus status;
  int downloadedBytes;
  int totalBytes;

  OfflineCache({
    required this.uniqueKey,
    required this.videoInfo,
    required this.content,
    required this.cacheTime,
    this.fileSize = 0,
    this.status = DownloadStatus.downloading,
    this.downloadedBytes = 0,
    this.totalBytes = 0,
  });

  void updateProgress(int downloadedBytes, int totalBytes) {
    this.downloadedBytes = downloadedBytes;
    this.totalBytes = totalBytes;
    save();
  }
}
