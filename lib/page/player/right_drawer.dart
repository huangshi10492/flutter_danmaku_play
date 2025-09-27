import 'package:fldanplay/model/file_item.dart';
import 'package:fldanplay/model/history.dart';
import 'package:fldanplay/model/video_info.dart';
import 'package:fldanplay/page/player/danmaku_source_settings.dart';
import 'package:fldanplay/page/player/track_page.dart';
import 'package:fldanplay/page/player/danmaku_search_page.dart';
import 'package:fldanplay/page/player/danmaku_settings.dart';
import 'package:fldanplay/service/configure.dart';
import 'package:fldanplay/service/file_explorer.dart';
import 'package:fldanplay/service/global.dart';
import 'package:fldanplay/service/player/player.dart';
import 'package:fldanplay/service/stream_media_explorer.dart';
import 'package:fldanplay/utils/utils.dart';
import 'package:fldanplay/widget/settings/settings_section.dart';
import 'package:fldanplay/widget/settings/settings_tile.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:get_it/get_it.dart';
import 'package:signals_flutter/signals_flutter.dart';

enum RightDrawerType {
  danmakuActions,
  danmakuSearch,
  danmakuSettings,
  danmakuSourceSettings,
  episode,
  speed,
  audioTrack,
  subtitleTrack,
}

class RightDrawerContent extends StatelessWidget {
  RightDrawerContent({
    super.key,
    required this.drawerType,
    required this.playerService,
    required this.onEpisodeSelected,
    required this.onDrawerChanged,
    required this.videoInfo,
  });

  final RightDrawerType drawerType;
  final VideoPlayerService playerService;
  final void Function(int index) onEpisodeSelected;
  final void Function(RightDrawerType newType) onDrawerChanged;
  final VideoInfo videoInfo;
  final _globalService = GetIt.I.get<GlobalService>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: context.theme.colors.background),
      width: 300,
      height: MediaQuery.of(context).size.height,
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (drawerType) {
      case RightDrawerType.speed:
        return _buildSpeedSettings(context);
      case RightDrawerType.danmakuActions:
        return _buildDanmakuActions(context);
      case RightDrawerType.danmakuSearch:
        return _buildDanmakuSearch(context);
      case RightDrawerType.danmakuSettings:
        return DanmakuSettingsPanel(
          danmakuService: playerService.danmakuService,
        );
      case RightDrawerType.danmakuSourceSettings:
        return DanmakuSourceSettings(
          danmakuService: playerService.danmakuService,
        );
      case RightDrawerType.episode:
        return _buildEpisodePanel(context);
      case RightDrawerType.audioTrack:
        return TrackPage(playerService: playerService, isAudio: true);
      case RightDrawerType.subtitleTrack:
        return TrackPage(playerService: playerService, isAudio: false);
    }
  }

  Widget _buildSpeedSettings(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(4),
        child: SingleChildScrollView(
          child: Watch((context) {
            final speed = playerService.playbackSpeed.value;
            final configure = GetIt.I.get<ConfigureService>();
            final defaultSpeed = configure.defaultPlaySpeed.value;
            final doubleSpeed = configure.doublePlaySpeed.value;
            return SettingsSection(
              children: [
                SettingsTile.sliderTile(
                  title: '当前播放速度',
                  details: '${speed.toStringAsFixed(2)}x',
                  silderValue: speed,
                  silderMin: 0.25,
                  silderMax: 4,
                  silderDivisions: 15,
                  onSilderChange: (value) {
                    playerService.setPlaybackSpeed(value);
                  },
                ),
                SettingsTile.sliderTile(
                  title: '默认播放速度',
                  details: '${defaultSpeed.toStringAsFixed(2)}x',
                  silderValue: defaultSpeed,
                  silderMin: 0.25,
                  silderMax: 4,
                  silderDivisions: 15,
                  onSilderChange: (value) {
                    configure.defaultPlaySpeed.value = value;
                  },
                ),
                SettingsTile.sliderTile(
                  title: '长按加速播放速度',
                  details: '${doubleSpeed.toStringAsFixed(2)}x',
                  silderValue: doubleSpeed,
                  silderMin: 1,
                  silderMax: 8,
                  silderDivisions: 28,
                  onSilderChange: (value) {
                    configure.doublePlaySpeed.value = value;
                  },
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildDanmakuActions(BuildContext context) {
    return Column(
      children: [
        Watch((context) {
          final configure = GetIt.I.get<ConfigureService>();
          return FItemGroup(
            children: [
              if (configure.danmakuServiceEnable.value) ...[
                FItem(
                  prefix: const Icon(Icons.search, size: 20),
                  title: Text('搜索弹幕', style: context.theme.typography.base),
                  onPress: () => onDrawerChanged(RightDrawerType.danmakuSearch),
                ),
                FItem(
                  prefix: const Icon(Icons.refresh, size: 20),
                  title: Text('重新匹配弹幕', style: context.theme.typography.base),
                  onPress: () {
                    Navigator.pop(context);
                    _globalService.showNotification('正在匹配弹幕...');
                    playerService.danmakuService.loadDanmaku(force: true);
                  },
                ),
                FItem(
                  prefix: const Icon(Icons.refresh, size: 20),
                  title: Text('重新加载弹幕', style: context.theme.typography.base),
                  onPress: () {
                    Navigator.pop(context);
                    _globalService.showNotification('正在加载弹幕...');
                    playerService.danmakuService.refreshDanmaku();
                  },
                ),
                FItem(
                  prefix: const Icon(Icons.settings, size: 20),
                  title: Text('弹幕设置', style: context.theme.typography.base),
                  onPress:
                      () => onDrawerChanged(RightDrawerType.danmakuSettings),
                ),
                FItem(
                  prefix: const Icon(Icons.settings, size: 20),
                  title: Text('弹幕源设置', style: context.theme.typography.base),
                  onPress:
                      () => onDrawerChanged(
                        RightDrawerType.danmakuSourceSettings,
                      ),
                ),
              ],
              FItem(
                prefix: const Icon(Icons.audiotrack_outlined, size: 20),
                title: Text('音频选择', style: context.theme.typography.base),
                onPress: () => onDrawerChanged(RightDrawerType.audioTrack),
              ),
              FItem(
                prefix: const Icon(Icons.subtitles_outlined, size: 20),
                title: Text('字幕选择', style: context.theme.typography.base),
                onPress: () => onDrawerChanged(RightDrawerType.subtitleTrack),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildDanmakuSearch(BuildContext context) {
    return DanmakuSearchPage(
      searchEpisodes: (name) async {
        return playerService.danmakuService.searchEpisodes(name);
      },
      onEpisodeSelected: ({required animeId, required episodeId}) {
        Navigator.pop(context); // 关闭 sheet
        _globalService.showNotification('正在加载指定弹幕...');
        playerService.danmakuService.selectEpisodeAndLoadDanmaku(
          animeId,
          episodeId,
        );
      },
    );
  }

  List<FItemMixin> _buildItems(List<FileItem> files, BuildContext context) {
    final widgetList = <FItemMixin>[];
    for (var i = 0; i < files.length; i++) {
      final file = files[i];
      if (!file.isVideo) {
        continue;
      }
      widgetList.add(
        FItem(
          title: Text(file.name, maxLines: 2),
          subtitle:
              file.history != null
                  ? Text(
                    '观看进度: ${Utils.formatTime(file.history!.position, file.history!.duration)}',
                  )
                  : Text('未观看'),
          onPress: () => {onEpisodeSelected(i), Navigator.pop(context)},
        ),
      );
    }
    return widgetList;
  }

  Widget _buildEpisodePanel(BuildContext context) {
    if (videoInfo.historiesType == HistoriesType.streamMediaStorage) {
      final streamMediaExplorerService =
          GetIt.I.get<StreamMediaExplorerService>();
      return Watch((context) {
        final episodeList = streamMediaExplorerService.episodeList;
        return FItemGroup(
          children:
              episodeList.asMap().entries.map<FItem>((e) {
                return FItem(
                  title: Text('${e.value.indexNumber}. ${e.value.name}'),
                  onPress:
                      () => {onEpisodeSelected(e.key), Navigator.pop(context)},
                );
              }).toList(),
        );
      });
    }
    if (videoInfo.historiesType == HistoriesType.fileStorage) {
      final FileExplorerService fileExplorerService =
          GetIt.I.get<FileExplorerService>();
      return Watch(
        (context) => fileExplorerService.files.value.map(
          data: (files) {
            if (files.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      FIcons.folder,
                      size: 48,
                      color: context.theme.colors.mutedForeground,
                    ),
                    const SizedBox(height: 16),
                    Text('播放列表为空', style: context.theme.typography.lg),
                  ],
                ),
              );
            }
            return FItemGroup(children: _buildItems(files, context));
          },
          error: (error, stack) => const Center(child: Text('加载失败')),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      );
    }
    return const Center(child: Text('不支持的媒体库类型'));
  }
}
