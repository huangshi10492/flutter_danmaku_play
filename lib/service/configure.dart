import 'dart:convert';
import 'package:fldanplay/model/danmaku.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce/hive.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// 配置服务
/// 提供类型安全的配置项管理，支持默认值和持久化存储
class ConfigureService {
  late final Box _box;

  late final Signal<double> defaultPlaySpeed = Signal(
    _box.get('defaultPlaySpeed', defaultValue: 1.0),
  );
  late final Signal<double> doublePlaySpeed = Signal(
    _box.get('doublePlaySpeed', defaultValue: 2.0),
  );
  late final Signal<int> forwardSeconds = Signal(
    _box.get('forwardSeconds', defaultValue: 10),
  );
  late final Signal<int> backwardSeconds = Signal(
    _box.get('backwardSeconds', defaultValue: 10),
  );
  late final Signal<int> seekOPSeconds = Signal(
    _box.get('seekOPSeconds', defaultValue: 85),
  );
  // 自动为字幕和弹幕选择语言（0: 关闭，1: 中文简体，2: 中文繁体）
  late final Signal<int> autoLanguage = Signal(
    _box.get('autoLanguage', defaultValue: 1),
  );
  // 自动为音频选择日语
  late final Signal<bool> autoAudioLanguage = Signal(
    _box.get('autoAudioLanguage', defaultValue: true),
  );
  late final Signal<bool> hardwareDecoderEnable = Signal(
    _box.get('hardwareDecoderEnable', defaultValue: true),
  );
  late final Signal<String> hardwareDecoder = Signal(
    _box.get('hardwareDecoder', defaultValue: 'auto'),
  );
  late final Signal<bool> lowMemoryMode = Signal(
    _box.get('lowMemoryMode', defaultValue: false),
  );
  late final Signal<bool> playerDebugMode = Signal(
    _box.get('playerDebugMode', defaultValue: false),
  );
  late final Signal<bool> audioTrack = Signal(
    _box.get('audioTrack', defaultValue: false),
  );
  late final Signal<DanmakuSettings> danmakuSettings = Signal(
    getDanmakuSettings(),
  );
  late final Signal<String> themeMode = Signal(
    _box.get('themeMode', defaultValue: '0'),
  );
  late final Signal<String> themeColor = Signal(
    _box.get('themeColor', defaultValue: 'blue'),
  );
  late final Signal<bool> offlineCacheFirst = Signal(
    _box.get('offlineCacheEnable', defaultValue: true),
  );
  late final Signal<bool> syncEnable = Signal(
    _box.get('syncEnable', defaultValue: false),
  );
  late final Signal<bool> danmakuServiceEnable = Signal(
    _box.get('danmakuServiceEnable', defaultValue: false),
  );
  late final Signal<bool> defaultDanmakuEnable = Signal(
    _box.get('subtitleEnable', defaultValue: true),
  );
  late final Signal<String> danmakuServiceUrl = Signal(
    _box.get(
      'danmakuServiceUrl',
      defaultValue: 'https://danmaku.huangshi10492.top/huangshi10492',
    ),
  );
  // 日志级别配置 (0: DEBUG, 1: INFO, 2: WARNING, 3: ERROR)
  late final Signal<String> logLevel = Signal(
    _box.get('logLevel', defaultValue: '1'), // 默认为INFO级别
  );
  late final Signal<String> webDavURL = Signal(
    _box.get('webDavURL', defaultValue: ''),
  );
  late final Signal<String> webDavUsername = Signal(
    _box.get('webDavUsername', defaultValue: ''),
  );
  late final Signal<String> webDavPassword = Signal(
    _box.get('webDavPassword', defaultValue: ''),
  );
  // 数据库文件最后更新时间
  late final Signal<int> lastSyncTime = Signal(
    _box.get('lastSyncTime', defaultValue: 0),
  );
  // 字幕字体名称
  late final Signal<String> subtitleFontName = Signal(
    _box.get('subtitleFontName', defaultValue: ''),
  );

  ConfigureService._(this._box);

  static Future<ConfigureService> register() async {
    Box box = await Hive.openBox('configure');
    var service = ConfigureService._(box);
    service.setupSignalListeners();
    GetIt.I.registerSingleton<ConfigureService>(service);
    return service;
  }

  void setupSignalListeners() {
    effect(() {
      _box.put('defaultPlaySpeed', defaultPlaySpeed.value);
    });
    effect(() {
      _box.put('doublePlaySpeed', doublePlaySpeed.value);
    });
    effect(() {
      _box.put('forwardSeconds', forwardSeconds.value);
    });
    effect(() {
      _box.put('backwardSeconds', backwardSeconds.value);
    });
    effect(() {
      _box.put('seekOPSeconds', seekOPSeconds.value);
    });
    effect(() {
      _box.put('autoLanguage', autoLanguage.value);
    });
    effect(() {
      _box.put('autoAudioLanguage', autoAudioLanguage.value);
    });
    effect(() {
      _box.put('hardwareDecoderEnable', hardwareDecoderEnable.value);
    });
    effect(() {
      _box.put('hardwareDecoder', hardwareDecoder.value);
    });
    effect(() {
      _box.put('lowMemoryMode', lowMemoryMode.value);
    });
    effect(() {
      _box.put('playerDebugMode', playerDebugMode.value);
    });
    effect(() {
      _box.put('audioTrack', audioTrack.value);
    });
    effect(() {
      setDanmakuSettings(danmakuSettings.value);
    });
    effect(() {
      _box.put('themeMode', themeMode.value);
    });
    effect(() {
      _box.put('themeColor', themeColor.value);
    });
    effect(() {
      _box.put('offlineCacheFirst', offlineCacheFirst.value);
    });
    effect(() {
      _box.put('syncEnable', syncEnable.value);
    });
    effect(() {
      _box.put('webDavURL', webDavURL.value);
    });
    effect(() {
      _box.put('webDavUsername', webDavUsername.value);
    });
    effect(() {
      _box.put('webDavPassword', webDavPassword.value);
    });
    effect(() {
      _box.put('danmakuServiceEnable', danmakuServiceEnable.value);
    });
    effect(() {
      _box.put('defaultDanmakuEnable', defaultDanmakuEnable.value);
    });
    effect(() {
      _box.put('danmakuServiceUrl', danmakuServiceUrl.value);
    });
    effect(() {
      _box.put('logLevel', logLevel.value);
    });
    effect(() {
      _box.put('lastSyncTime', lastSyncTime.value);
    });
    effect(() {
      _box.put('subtitleFontName', subtitleFontName.value);
    });
  }

  DanmakuSettings getDanmakuSettings() {
    final jsonString = _box.get('danmakuSettings');
    if (jsonString == null) {
      return DanmakuSettings();
    }
    return DanmakuSettings.fromJson(
      jsonDecode(utf8.decode(base64Decode(jsonString))),
    );
  }

  Future<void> setDanmakuSettings(DanmakuSettings settings) async {
    await _box.put(
      'danmakuSettings',
      base64Encode(utf8.encode(jsonEncode(settings.toJson()))),
    );
  }
}
