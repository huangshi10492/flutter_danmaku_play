import 'package:hive_ce_flutter/hive_flutter.dart';

enum HistoriesType { network, local, fileStorage, streamMediaStorage }

class History extends HiveObject {
  String uniqueKey;
  int duration;
  int position;
  String? url;
  HistoriesType type;
  String? storageKey;
  int updateTime;
  String name;
  String? subtitle;
  String? fileName;

  History({
    required this.uniqueKey,
    required this.duration,
    required this.position,
    this.url,
    required this.type,
    this.storageKey,
    required this.updateTime,
    required this.name,
    this.subtitle,
    this.fileName,
  });

  History copyWith({
    String? uniqueKey,
    int? duration,
    int? position,
    String? url,
    HistoriesType? type,
    String? storageKey,
    int? updateTime,
    String? name,
    String? subtitle,
    String? fileName,
  }) {
    return History(
      uniqueKey: uniqueKey ?? this.uniqueKey,
      duration: duration ?? this.duration,
      position: position ?? this.position,
      url: url ?? this.url,
      type: type ?? this.type,
      storageKey: storageKey ?? this.storageKey,
      updateTime: updateTime ?? this.updateTime,
      name: name ?? this.name,
      subtitle: subtitle ?? this.subtitle,
      fileName: fileName ?? this.fileName,
    );
  }
}
