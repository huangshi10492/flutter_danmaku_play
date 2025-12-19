import 'dart:async';
import 'dart:io';

import 'package:canvas_danmaku/danmaku_controller.dart';
import 'package:canvas_danmaku/models/danmaku_content_item.dart';
import 'package:fldanplay/model/danmaku.dart';
import 'package:fldanplay/model/video_info.dart';
import 'package:fldanplay/service/configure.dart';
import 'package:fldanplay/service/global.dart';
import 'package:fldanplay/utils/danmaku_api_utils.dart';
import 'package:fldanplay/utils/log.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../model/history.dart';

class DanmakuService {
  late DanmakuController controller;
  final VideoInfo videoInfo;

  DanmakuService(this.videoInfo);

  ConfigureService configureService = GetIt.I.get<ConfigureService>();
  GlobalService globalService = GetIt.I.get<GlobalService>();
  late DanmakuApiUtils danmakuApiUtils;
  final DanmakuGetter danmakuGetter = DanmakuGetter();

  final _log = Logger('DanmakuService');
  Map<int, List<Danmaku>> _bili = {};
  Map<int, List<Danmaku>> _gamer = {};
  Map<int, List<Danmaku>> _dandan = {};
  Map<int, List<Danmaku>> _other = {};
  final Signal<DanmakuSettings> danmakuSettings = Signal(DanmakuSettings());
  final Signal<bool> danmakuEnabled = Signal(true);
  late History history;
  int episodeId = 0;
  int animeId = 0;
  int lastTime = 0;
  String cacheDir = "";
  late bool danmakuServiceEnable = configureService.danmakuServiceEnable.value;

  Future<void> init({bool searchMode = false}) async {
    final documentsDir = await getApplicationSupportDirectory();
    cacheDir = Directory('${documentsDir.path}/danmaku').path;
    danmakuApiUtils = DanmakuApiUtils(configureService.danmakuServiceUrl.value);
    danmakuEnabled.value = configureService.defaultDanmakuEnable.value;
    final sittings = configureService.getDanmakuSettings();
    danmakuSettings.value = sittings;
    controller.updateOption(sittings.toDanmakuOption());
    globalService.videoName = videoInfo.videoName;
    loadDanmaku(searchMode: searchMode);
  }

  void syncWithVideo(bool isPlaying) {
    if (isPlaying) {
      controller.resume();
    } else {
      controller.pause();
    }
  }

  void _clear() {
    controller.clear();
    _bili = {};
    _gamer = {};
    _dandan = {};
    _other = {};
  }

  void resetDanmakuPosition() {
    controller.clear();
    lastTime = 0;
  }

  void updateSpeed() {
    if (danmakuSettings.value.speedSync) {
      controller.updateOption(
        danmakuSettings.value
            .copyWith(
              duration: danmakuSettings.value.duration / globalService.speed,
            )
            .toDanmakuOption(),
      );
    }
  }

  /// 根据当前播放位置更新弹幕显示
  void updatePlayPosition(Duration position, double speed) {
    if (!danmakuEnabled.value) return;
    final currentSecond = position.inSeconds;
    if (lastTime == currentSecond) return;
    lastTime = currentSecond;
    var delay = 0;
    if (danmakuSettings.value.bilibiliSource) {
      for (Danmaku danmaku
          in _bili[currentSecond + danmakuSettings.value.bilibiliDelay] ?? []) {
        delay = 0;
        if (danmaku.time > position) {
          delay =
              (danmaku.time.inMilliseconds -
                  danmakuSettings.value.bilibiliDelay * 1000 -
                  position.inMilliseconds) ~/
              speed;
        }
        Future.delayed(
          Duration(milliseconds: delay),
          () => _addDanmakuToController(danmaku),
        );
      }
    }
    if (danmakuSettings.value.gamerSource) {
      for (Danmaku danmaku
          in _gamer[currentSecond + danmakuSettings.value.gamerDelay] ?? []) {
        delay = 0;
        if (danmaku.time > position) {
          delay =
              (danmaku.time.inMilliseconds -
                  danmakuSettings.value.gamerDelay * 1000 -
                  position.inMilliseconds) ~/
              speed;
        }
        Future.delayed(
          Duration(milliseconds: delay),
          () => _addDanmakuToController(danmaku),
        );
      }
    }
    if (danmakuSettings.value.dandanSource) {
      for (Danmaku danmaku
          in _dandan[currentSecond + danmakuSettings.value.dandanDelay] ?? []) {
        delay = 0;
        if (danmaku.time > position) {
          delay =
              (danmaku.time.inMilliseconds -
                  danmakuSettings.value.dandanDelay * 1000 -
                  position.inMilliseconds) ~/
              speed;
        }
        Future.delayed(
          Duration(milliseconds: delay),
          () => _addDanmakuToController(danmaku),
        );
      }
    }
    if (danmakuSettings.value.otherSource) {
      for (Danmaku danmaku
          in _other[currentSecond + danmakuSettings.value.otherDelay] ?? []) {
        delay = 0;
        if (danmaku.time > position) {
          delay =
              (danmaku.time.inMilliseconds -
                  danmakuSettings.value.otherDelay * 1000 -
                  position.inMilliseconds) ~/
              speed;
        }
        Future.delayed(
          Duration(milliseconds: delay),
          () => _addDanmakuToController(danmaku),
        );
      }
    }
  }

  /// 将弹幕添加到控制器中显示
  void _addDanmakuToController(Danmaku danmaku) {
    try {
      // 根据弹幕类型转换为canvas_danmaku的类型
      DanmakuItemType danmakuType;
      switch (danmaku.type) {
        case 4:
          danmakuType = DanmakuItemType.bottom; // 底部弹幕
          break;
        case 5:
          danmakuType = DanmakuItemType.top; // 顶部弹幕
          break;
        default:
          danmakuType = DanmakuItemType.scroll; // 默认滚动弹幕
      }

      // 调用controller的addDanmaku方法
      controller.addDanmaku(
        DanmakuContentItem(
          danmaku.text,
          type: danmakuType,
          color: danmaku.color,
        ),
      );
    } catch (e) {
      _log.error('_addDanmakuToController', '添加弹幕失败', error: e);
    }
  }

  void _danmaku2Map(List<Danmaku> danmakus) {
    _clear();
    var bili = 0;
    var gamer = 0;
    var dandan = 0;
    var other = 0;
    for (var danmaku in danmakus) {
      final key = danmaku.time.inSeconds;
      switch (danmaku.source) {
        case 'BiliBili':
        case 'bilibili':
          bili++;
          if (!_bili.containsKey(key)) {
            _bili[key] = [];
          }
          _bili[key]!.add(danmaku);
          break;
        case 'Gamer':
          gamer++;
          if (!_gamer.containsKey(key)) {
            _gamer[key] = [];
          }
          _gamer[key]!.add(danmaku);
          break;
        case 'DanDanPlay':
          dandan++;
          if (!_dandan.containsKey(key)) {
            _dandan[key] = [];
          }
          _dandan[key]!.add(danmaku);
          break;
        default:
          other++;
          if (!_other.containsKey(key)) {
            _other[key] = [];
          }
          _other[key]!.add(danmaku);
      }
    }
    globalService.danmakuCount.value = {
      'BiliBili': bili,
      'Gamer': gamer,
      'DanDanPlay': dandan,
      'Other': other,
    };
  }

  /// 加载弹幕
  Future<void> loadDanmaku({
    bool searchMode = false,
    bool force = false,
  }) async {
    if (!danmakuServiceEnable) return;
    try {
      if (!force) {
        final exist = await _getCachedDanmakus(videoInfo.uniqueKey);
        if (exist) return;
      }
      DanmakuMatchResult? result;
      if (searchMode) {
        result = await danmakuGetter.getBySearch(
          videoInfo.uniqueKey,
          videoInfo.videoName,
        );
      }
      if (result == null) {
        result = await danmakuGetter.match(
          videoInfo.uniqueKey,
          videoInfo.videoName,
        );
        if (result == null) {
          globalService.showNotification('未找到弹幕');
          return;
        }
      }
      await _getCachedDanmakus(videoInfo.uniqueKey);
    } catch (e, t) {
      _log.error('loadDanmaku', '加载弹幕失败', error: e, stackTrace: t);
    }
  }

  /// 从缓存获取弹幕数据
  Future<bool> _getCachedDanmakus(String uniqueKey) async {
    try {
      final danmakuFile = File('$cacheDir/$uniqueKey.json');
      if (!await danmakuFile.exists()) return false;
      final jsonString = await danmakuFile.readAsString();
      final danmakuData = DanmakuFile.fromJsonString(jsonString);
      final expireTime = danmakuData.expireTime.millisecondsSinceEpoch;
      final now = DateTime.now().millisecondsSinceEpoch;
      episodeId = danmakuData.episodeId;
      animeId = danmakuData.animeId;
      if (now > expireTime) {
        _log.info('_getCachedDanmakus', '弹幕缓存已过期');
        final result = await danmakuGetter.save(uniqueKey, episodeId, animeId);
        if (result.isNotEmpty) {
          _danmaku2Map(result);
          globalService.showNotification('更新弹幕: ${result.length}条');
          return true;
        }
      }
      _danmaku2Map(danmakuData.danmakus);
      globalService.showNotification('加载弹幕: ${danmakuData.danmakus.length}条');
      return true;
    } catch (e, t) {
      _log.warn('_getCachedDanmakus', '读取缓存弹幕失败', error: e, stackTrace: t);
      return false;
    }
  }

  /// 搜索番剧集数
  Future<List<Anime>> searchEpisodes(String animeName) async {
    return await danmakuApiUtils.searchEpisodes(animeName);
  }

  /// 选择episodeId并加载弹幕
  Future<void> selectEpisodeAndLoadDanmaku(
    String uniqueKey,
    int animeId,
    int episodeId,
  ) async {
    try {
      final danmakus = await danmakuGetter.save(uniqueKey, episodeId, animeId);
      _danmaku2Map(danmakus);
      _log.info('selectEpisodeAndLoadDanmaku', '搜索弹幕加载成功: ${danmakus.length}条');
      globalService.showNotification('从API加载弹幕: ${danmakus.length}条');
    } catch (e, t) {
      _log.error(
        'selectEpisodeAndLoadDanmaku',
        '手动选择弹幕加载失败',
        error: e,
        stackTrace: t,
      );
      globalService.showNotification('手动选择弹幕加载失败');
    }
  }

  Future<void> refreshDanmaku() async {
    if (animeId == 0 || episodeId == 0) return;
    try {
      final danmakus = await danmakuGetter.save(
        videoInfo.uniqueKey,
        episodeId,
        animeId,
      );
      _danmaku2Map(danmakus);
      _log.info('refreshDanmaku', '刷新弹幕成功: ${danmakus.length}条');
      globalService.showNotification('刷新弹幕: ${danmakus.length}条');
    } catch (e, t) {
      _log.error('refreshDanmaku', '刷新弹幕失败', error: e, stackTrace: t);
      globalService.showNotification('刷新弹幕失败');
    }
  }

  void updateDanmakuSettings(DanmakuSettings settings) {
    danmakuSettings.value = settings;
    configureService.setDanmakuSettings(settings);
    controller.updateOption(settings.toDanmakuOption());
    _log.debug('updateDanmakuSettings', '弹幕设置更新: $settings');
  }
}

class DanmakuGetter {
  final configureService = GetIt.I.get<ConfigureService>();
  late final DanmakuApiUtils danmakuApiUtils = DanmakuApiUtils(
    configureService.danmakuServiceUrl.value,
  );
  final _log = Logger('DanmakuGetter');

  Future<DanmakuMatchResult?> getBySearch(String uniqueKey, String name) async {
    int animesId = 0;
    int episodesId = 0;
    try {
      final animes = await danmakuApiUtils.searchEpisodes(name);
      if (animes.isEmpty) return null;
      final episodes = animes.first.episodes;
      if (episodes.isEmpty) return null;
      animesId = episodes.first.animeId;
      episodesId = episodes.first.episodeId;
      await save(uniqueKey, episodesId, animesId);
      return DanmakuMatchResult(
        animeId: animesId,
        episodeId: episodesId,
        animeTitle: animes.first.animeTitle,
        episodeTitle: episodes.first.episodeTitle,
      );
    } catch (e, t) {
      _log.error('getBySearch', '搜索番剧失败', error: e, stackTrace: t);
      throw AppException('搜索番剧失败', e);
    }
  }

  Future<DanmakuMatchResult?> match(
    String uniqueKey,
    String fileName, {
    String? fileHash,
  }) async {
    try {
      final episodes = await danmakuApiUtils.matchVideo(
        fileName: fileName,
        fileHash: fileHash,
      );
      if (episodes.isEmpty) return null;
      await save(uniqueKey, episodes.first.episodeId, episodes.first.animeId);
      return DanmakuMatchResult(
        animeId: episodes.first.animeId,
        episodeId: episodes.first.episodeId,
        animeTitle: episodes.first.animeTitle,
        episodeTitle: episodes.first.episodeTitle,
      );
    } catch (e, t) {
      _log.error('match', '匹配视频失败', error: e, stackTrace: t);
      throw AppException('匹配视频失败', e);
    }
  }

  Future<List<Danmaku>> save(
    String uniqueKey,
    int episodeId,
    int animeId,
  ) async {
    try {
      final comments = await danmakuApiUtils.getComments(
        episodeId,
        sc: configureService.autoLanguage.value,
      );
      final danmakus = comments.map((comment) => comment.toDanmaku()).toList();
      final documentsDir = await getApplicationSupportDirectory();
      final cacheDir = Directory('${documentsDir.path}/danmaku');
      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
      }
      final cacheFile = File('${cacheDir.path}/$uniqueKey.json');
      final cacheData = DanmakuFile(
        uniqueKey: uniqueKey,
        cacheTime: DateTime.now(),
        expireTime: DateTime.now().add(
          danmakus.length > 100
              ? const Duration(days: 3)
              : const Duration(days: 1),
        ),
        danmakus: danmakus,
        episodeId: episodeId,
        animeId: animeId,
      );
      await cacheFile.writeAsString(cacheData.toJsonString());
      _log.info('save', '弹幕缓存保存成功， 弹幕数量: ${danmakus.length}');
      return danmakus;
    } catch (e, t) {
      _log.error('_save', '保存弹幕缓存失败', error: e, stackTrace: t);
      throw AppException('保存弹幕缓存失败', e);
    }
  }
}
