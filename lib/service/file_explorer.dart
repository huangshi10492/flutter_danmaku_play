import 'dart:convert';
import 'dart:io';

import 'package:fldanplay/model/file_item.dart';
import 'package:fldanplay/model/video_info.dart';
import 'package:fldanplay/service/history.dart';
import 'package:fldanplay/utils/crypto_utils.dart';
import 'package:fldanplay/utils/log.dart';
import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:string_util_xx/StringUtilxx.dart';
import 'package:webdav_client_plus/webdav_client_plus.dart';
import '../model/storage.dart';
import '../model/history.dart';

abstract class FileExplorerProvider {
  Future<List<FileItem>> listFiles(String path, String rootPath);
  Map<String, String> get headers;
  void dispose();
}

class FileExplorerService {
  final Signal<FileExplorerProvider?> provider = signal(null);
  final path = signal('/');
  final Signal<String?> error = signal(null);
  final listLength = signal(0);
  Storage? _storage;
  final _logger = Logger('FileExplorerService');

  late final FutureSignal<List<FileItem>> files = futureSignal(() async {
    try {
      if (provider.value == null || _storage == null) {
        return [];
      }
      final list = await provider.value!.listFiles(path.value, _storage!.key);
      listLength.value = list.length;
      return list;
    } catch (e) {
      error.value = e.toString();
      return [];
    }
  }, dependencies: [path, provider]);

  static void register() {
    final service = FileExplorerService();
    GetIt.I.registerSingleton<FileExplorerService>(service);
  }

  void setProvider(FileExplorerProvider newProvider, Storage storage) {
    batch(() {
      provider.value?.dispose();
      provider.value = newProvider;
      _storage = storage;
      path.value = '/';
    });
    _logger.info('setProvider', '设置新的文件库提供者');
  }

  void next(String name) {
    path.value = '${path.value}$name/';
  }

  bool back() {
    if (path.value == '/') {
      return false;
    }
    path.value =
        '${path.value.split('/').sublist(0, path.value.split('/').length - 2).join('/')}/';
    return true;
  }

  void cd(String newPath) {
    path.value = newPath;
  }

  Future<void> refresh() async {
    await files.refresh();
  }

  Future<VideoInfo?> selectVideo(int index) async {
    _logger.info('selectVideo', '选择视频: $index');
    final list = await files.future;
    if (index >= list.length || index < 0 || list[index].isFolder) {
      return null;
    }
    return getVideoInfo(list[index].videoIndex, list[index].path);
  }

  Future<VideoInfo> getVideoInfo(int index, String path) async {
    final videoPath = '${_storage!.url}$path';
    final headers = provider.value!.headers;
    return VideoInfo.fromFile(
      currentVideoPath: videoPath,
      virtualVideoPath: '${_storage!.key}$path',
      headers: headers.map((key, value) => MapEntry(key, value.toString())),
      historiesType: HistoriesType.fileStorage,
      videoIndex: index,
      listLength: listLength.value,
      canSwitch: true,
      storageKey: _storage!.uniqueKey,
    );
  }

  Future<VideoInfo> getVideoInfoFromHistory(History history) async {
    final parts = history.url!.split('/');
    final path = parts.sublist(1, parts.length);
    final videoPath = '${_storage!.url}/${path.join('/')}';
    final headers = provider.value!.headers;
    return VideoInfo.fromFile(
      currentVideoPath: videoPath,
      virtualVideoPath: history.url!,
      headers: headers.map((key, value) => MapEntry(key, value.toString())),
      historiesType: HistoriesType.fileStorage,
      subtitle: history.subtitle,
      storageKey: _storage!.uniqueKey,
    );
  }
}

// WebDAV implementation (placeholder)
class WebDAVFileExplorerProvider implements FileExplorerProvider {
  WebdavClient? client;
  late final Map<String, String> _headers;
  final _logger = Logger('WebDAVFileExplorerProvider');

  @override
  Map<String, String> get headers => _headers;

  WebDAVFileExplorerProvider(Storage storage) {
    if (storage.isAnonymous!) {
      _headers = {"Authorization": "Basic ${base64Encode(utf8.encode(':'))}"};
    } else {
      _headers = {
        "Authorization":
            "Basic ${base64Encode(utf8.encode('${storage.account!}:${storage.password!}'))}",
      };
    }
    client = null;
    if (storage.isAnonymous!) {
      client = WebdavClient.noAuth(url: storage.url);
    } else {
      client = WebdavClient.basicAuth(
        url: storage.url,
        user: storage.account!,
        pwd: storage.password!,
      );
    }
    _logger.info('WebDAVFileExplorerProvider', '初始化WebDAV文件库提供者');
  }

  @override
  Future<List<FileItem>> listFiles(String path, String rootPath) async {
    try {
      if (client == null) {
        return [];
      }
      List<FileItem> list = [];
      var fileList = await client!.readDir(path);
      for (var file in fileList) {
        final filePath = '$path${file.name}';
        if (FileItem.getFileType(file.name) != FileType.video && !file.isDir) {
          continue;
        }
        if (file.isDir) {
          list.add(
            FileItem(name: file.name, path: filePath, type: FileType.folder),
          );
          continue;
        }
        var uniqueKey = CryptoUtils.generateVideoUniqueKey(
          '$rootPath$filePath',
        );
        var history = GetIt.I.get<HistoryService>().getHistory(uniqueKey);
        list.add(
          FileItem(
            name: file.name,
            path: filePath,
            type: FileItem.getFileType(file.name),
            size: file.size,
            uniqueKey: uniqueKey,
            history: history,
          ),
        );
      }
      list.sort(_compare);
      list = setVideoIndex(list);
      return list;
    } catch (e) {
      _logger.error('listFiles', '获取文件列表失败', error: e);
      throw Exception('获取文件列表失败: ${e.toString()}');
    }
  }

  @override
  void dispose() {}
}

class LocalFileExplorerProvider implements FileExplorerProvider {
  final String url;
  final _logger = Logger('LocalFileExplorerProvider');

  @override
  Map<String, String> get headers => {};
  LocalFileExplorerProvider(this.url) {
    Permission.videos.request();
  }

  @override
  Future<List<FileItem>> listFiles(String path, String rootPath) async {
    try {
      final historyService = GetIt.I.get<HistoryService>();
      if (path.isEmpty) {
        return [];
      }
      var list = <FileItem>[];
      final fileList = Directory('$url$path').list();
      await for (var file in fileList) {
        if (file is! File) {
          list.add(
            FileItem(
              name: file.path.split('/').last,
              path: file.path,
              type: FileType.folder,
            ),
          );
          continue;
        }
        final filePath = '$path${file.path.split('/').last}';
        if (FileItem.getFileType(file.path) != FileType.video) {
          continue;
        }
        var uniqueKey = CryptoUtils.generateVideoUniqueKey(
          '$rootPath$filePath',
        );
        var history = historyService.getHistory(uniqueKey);
        list.add(
          FileItem(
            name: file.path.split('/').last,
            path: filePath,
            type: FileItem.getFileType(file.path),
            size: file.lengthSync(),
            uniqueKey: uniqueKey,
            history: history,
          ),
        );
      }
      list.sort(_compare);
      list = setVideoIndex(list);
      return list;
    } catch (e) {
      _logger.error('listFiles', '获取文件列表失败', error: e);
      throw Exception('获取文件列表失败: ${e.toString()}');
    }
  }

  @override
  void dispose() {}
}

int _compare(FileItem a, FileItem b) {
  if (a.isFolder && !b.isFolder) {
    return -1;
  }
  if (!a.isFolder && b.isFolder) {
    return 1;
  }
  return StringUtilxx_c.compareExtend(a.name, b.name);
}

List<FileItem> setVideoIndex(List<FileItem> list) {
  int videoIndex = 0;
  for (var i = 0; i < list.length; i++) {
    if (!list[i].isVideo) {
      continue;
    }
    list[i].videoIndex = videoIndex;
    videoIndex++;
  }
  return list;
}
