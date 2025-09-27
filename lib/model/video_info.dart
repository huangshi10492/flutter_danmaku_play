import 'package:fldanplay/model/history.dart';
import 'package:fldanplay/utils/crypto_utils.dart';

class VideoInfo {
  // 视频文件的真实地址
  String currentVideoPath;
  // 虚拟路径(1/video.mp4)
  String virtualVideoPath;
  Map<String, String> headers;
  HistoriesType historiesType;
  String? storageKey;
  int videoIndex;
  int listLength;
  bool canSwitch = false;
  late String uniqueKey;
  late String videoName;
  late String name;
  String? subtitle;

  VideoInfo.fromFile({
    required this.currentVideoPath,
    required this.virtualVideoPath,
    this.headers = const {},
    required this.historiesType,
    this.storageKey,
    this.videoIndex = 0,
    this.listLength = 0,
    this.canSwitch = false,
    this.subtitle,
  }) {
    name = virtualVideoPath.split('/').last;
    videoName = virtualVideoPath.split('/').last.split('.').first;
    uniqueKey = CryptoUtils.generateVideoUniqueKey(virtualVideoPath);
  }

  VideoInfo({
    required this.currentVideoPath,
    required this.virtualVideoPath,
    this.headers = const {},
    required this.historiesType,
    this.storageKey,
    this.videoIndex = 0,
    this.listLength = 0,
    this.canSwitch = false,
    required this.videoName,
    required this.name,
    this.subtitle,
  }) {
    uniqueKey = CryptoUtils.generateVideoUniqueKey(virtualVideoPath);
  }
}

/// 轨道信息模型
class TrackInfo {
  final int index;
  final String id;
  final String language;
  final String title;

  const TrackInfo({
    required this.index,
    required this.id,
    required this.language,
    required this.title,
  });
}
