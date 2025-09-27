import 'dart:async';
import 'dart:io';

import 'package:fldanplay/utils/log.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:synchronized/synchronized.dart';
import '../model/history.dart';
import '../utils/crypto_utils.dart';

class HistoryService {
  late Box<History> _historyBox;
  final lock = Lock();
  HistoryService();
  final _logger = Logger('HistoryService');

  static Future<HistoryService> register() async {
    final service = HistoryService();
    await service.init();
    GetIt.I.registerSingleton<HistoryService>(service);
    return service;
  }

  Future<void> init() async {
    _historyBox = await Hive.openBox<History>('history');
  }

  late final ValueListenable<Box<History>> listener = _historyBox.listenable();

  History? getHistory(String key) {
    return _historyBox.get(key);
  }

  Future<void> clearAllHistories() async {
    await _historyBox.clear();
  }

  Future<void> beforeSync() async {
    await _historyBox.flush();
    await _historyBox.compact();
  }

  Future<History> startHistory({
    required String url,
    required String headers,
    required Duration duration,
    required HistoriesType type,
    String? storageKey,
    required String name,
    String? subtitle,
  }) async {
    return await lock.synchronized(() async {
      _logger.info('startHistory', '开始记录播放历史: $url');
      final uniqueKey = CryptoUtils.generateVideoUniqueKey(url);
      final existing = getHistory(uniqueKey);
      if (existing != null) {
        existing.duration = duration.inMilliseconds;
        existing.updateTime = DateTime.now().millisecondsSinceEpoch;
        await existing.save();
        return existing;
      }
      final history = History(
        uniqueKey: uniqueKey,
        duration: duration.inMilliseconds,
        position: 0,
        url: url,
        type: type,
        storageKey: storageKey,
        name: name,
        subtitle: subtitle,
        updateTime: DateTime.now().millisecondsSinceEpoch,
      );
      await _historyBox.put(uniqueKey, history);
      return getHistory(uniqueKey)!;
    });
  }

  Future<void> updateProgress({
    required Duration position,
    required Duration duration,
    required History history,
  }) async {
    await lock.synchronized(() async {
      history.position = position.inMilliseconds;
      history.duration = duration.inMilliseconds;
      history.updateTime = DateTime.now().millisecondsSinceEpoch;
      await history.save();
    });
  }

  History? getHistoryByPath(String videoPath) {
    final uniqueKey = CryptoUtils.generateVideoUniqueKey(videoPath);
    return getHistory(uniqueKey);
  }

  Future<void> merge(File remoteFile, int lastSyncTime) async {
    _logger.info('merge', '开始合并历史记录');
    final remoteBox = await Hive.openBox<History>(
      'tempHistoryBox',
      bytes: remoteFile.readAsBytesSync(),
    );
    final remoteList = remoteBox.values.toList();
    for (final history in remoteList) {
      final localHistory = getHistory(history.uniqueKey);
      if (localHistory == null) {
        await _historyBox.put(history.uniqueKey, history.copyWith());
        continue;
      }
      if (localHistory.updateTime < history.updateTime) {
        await _historyBox.put(localHistory.uniqueKey, history.copyWith());
      }
    }
    final localList = _historyBox.values.toList();
    for (final history in localList) {
      final exist = remoteBox.containsKey(history.uniqueKey);
      if (!exist) {
        if (history.updateTime < lastSyncTime) {
          history.delete();
        }
      }
    }
    await remoteBox.close();
    _logger.info('merge', '合并历史记录完成');
  }
}
