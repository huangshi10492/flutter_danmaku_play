import 'package:fldanplay/model/file_item.dart';
import 'package:fldanplay/model/storage.dart';
import 'package:fldanplay/router.dart';
import 'package:fldanplay/service/configure.dart';
import 'package:fldanplay/service/file_explorer.dart';
import 'package:fldanplay/service/offline_cache.dart';
import 'package:fldanplay/service/storage.dart';
import 'package:fldanplay/service/global.dart';
import 'package:fldanplay/utils/toast.dart';
import 'package:fldanplay/widget/sys_app_bar.dart';
import 'package:fldanplay/widget/video_item.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';

class FileExplorerPage extends StatefulWidget {
  final String storageKey;
  const FileExplorerPage({super.key, required this.storageKey});

  @override
  State<FileExplorerPage> createState() => _FileExplorerPageState();
}

class _FileExplorerPageState extends State<FileExplorerPage> {
  Storage? _storage;
  final FileExplorerService _fileExplorerService =
      GetIt.I.get<FileExplorerService>();
  final OfflineCacheService _offlineCacheService =
      GetIt.I.get<OfflineCacheService>();
  final ScrollController _scrollController = ScrollController();
  final Map<String, int> _refreshMap = {};

  @override
  void initState() {
    init();
    GetIt.I.get<GlobalService>().updateListener = refreshItem;
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    GetIt.I.get<GlobalService>().updateListener = null;
    _fileExplorerService.provider.value?.dispose();
    super.dispose();
  }

  void refreshItem(String uniqueKey) {
    setState(() {
      _refreshMap[uniqueKey] = (_refreshMap[uniqueKey] ?? 0) + 1;
    });
    _refresh();
  }

  void init() async {
    final storageService = GetIt.I.get<StorageService>();
    final storage = storageService.get(widget.storageKey);
    if (storage == null) {
      return;
    }
    late FileExplorerProvider provider;
    switch (storage.storageType) {
      case StorageType.webdav:
        provider = WebDAVFileExplorerProvider(storage);
        break;
      case StorageType.ftp:
        break;
      case StorageType.smb:
        break;
      case StorageType.local:
        provider = LocalFileExplorerProvider(storage.url);
        break;
      default:
        return;
    }
    await provider.init();
    _fileExplorerService.setProvider(provider, storage);
    setState(() {
      _storage = storage;
    });
  }

  void _playVideo(String path, int index) async {
    final videoInfo = await _fileExplorerService.getVideoInfo(index, path);
    if (GetIt.I.get<ConfigureService>().offlineCacheFirst.value) {
      videoInfo.cached = _offlineCacheService.isCached(videoInfo.uniqueKey);
    }
    if (mounted) {
      final location = Uri(path: videoPlayerPath);
      context.push(location.toString(), extra: videoInfo);
    }
  }

  void _handleOfflineDownload(String path, int index) async {
    final videoInfo = await _fileExplorerService.getVideoInfo(index, path);
    _offlineCacheService.startDownload(videoInfo);
    if (mounted) showToast(context, title: '${videoInfo.name}已加入离线缓存');
  }

  Future<void> _refresh() async {
    await _fileExplorerService.refresh();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (!_fileExplorerService.back()) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: SysAppBar(title: _storage?.name ?? ''),
        body:
            _storage == null
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                  onRefresh: _refresh,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        controller: _scrollController,
                        child: Watch((context) {
                          final path = _fileExplorerService.path.watch(context);
                          final parts =
                              path
                                  .split('/')
                                  .where((p) => p.isNotEmpty)
                                  .toList();

                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (_scrollController.hasClients &&
                                _scrollController.position.maxScrollExtent >
                                    0) {
                              _scrollController.jumpTo(
                                _scrollController.position.maxScrollExtent,
                              );
                            }
                          });
                          final children = <Widget>[
                            FBreadcrumbItem(
                              onPress: () => _fileExplorerService.cd('/'),
                              child: Text(
                                '根目录',
                                style: TextStyle(
                                  color:
                                      parts.isEmpty
                                          ? context.theme.colors.primary
                                          : context.theme.colors.foreground,
                                ),
                              ),
                            ),
                          ];
                          var currentPath = '';
                          for (var i = 0; i < parts.length; i++) {
                            final part = parts[i];
                            currentPath += '/$part';
                            final targetPath = currentPath;
                            final isLast = i == parts.length - 1;
                            children.add(
                              FBreadcrumbItem(
                                onPress:
                                    isLast
                                        ? null
                                        : () =>
                                            _fileExplorerService.cd(targetPath),
                                child: Text(
                                  part,
                                  style: TextStyle(
                                    color:
                                        isLast
                                            ? context.theme.colors.primary
                                            : context.theme.colors.foreground,
                                  ),
                                ),
                              ),
                            );
                          }
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: FBreadcrumb(children: children),
                          );
                        }),
                      ),
                      Expanded(
                        child: Watch(
                          (context) => _fileExplorerService.files.value.map(
                            data: (files) {
                              if (files.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        FIcons.folder,
                                        size: 48,
                                        color:
                                            context
                                                .theme
                                                .colors
                                                .mutedForeground,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        '此文件夹为空',
                                        style: context.theme.typography.xl,
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return CustomScrollView(
                                slivers: [
                                  SliverToBoxAdapter(
                                    child: SafeArea(
                                      child: FItemGroup(
                                        divider: FItemDivider.indented,
                                        children: _listBuilder(files),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                            error:
                                (error, stack) => Center(
                                  child: Text(
                                    '加载失败: ${_fileExplorerService.error.value}',
                                  ),
                                ),
                            loading:
                                () => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }

  List<FItemMixin> _listBuilder(List<FileItem> files) {
    final widgetList = <FItemMixin>[];
    for (var i = 0; i < files.length; i++) {
      final file = files[i];
      if (file.isFolder) {
        widgetList.add(
          FItem(
            prefix: const Icon(FIcons.folder, size: 40),
            title: Text(
              file.name,
              style: context.theme.typography.base,
              maxLines: 2,
            ),
            subtitle: Text('目录'),
            onPress: () => {_fileExplorerService.next(file.name)},
          ),
        );
        continue;
      }
      final refreshKey = _refreshMap[file.uniqueKey] ?? 0;
      widgetList.add(
        VideoItem(
          key: ValueKey(file.uniqueKey),
          refreshKey: refreshKey,
          history: file.history,
          name: file.name,
          onOfflineDownload:
              () => _handleOfflineDownload(file.path, file.videoIndex),
          onPress: () => _playVideo(file.path, file.videoIndex),
        ),
      );
    }
    return widgetList;
  }
}
