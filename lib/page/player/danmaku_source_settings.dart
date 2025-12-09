import 'package:fldanplay/page/player/right_drawer.dart';
import 'package:fldanplay/service/player/danmaku.dart';
import 'package:fldanplay/service/global.dart';
import 'package:fldanplay/service/player/player.dart';
import 'package:fldanplay/utils/icon.dart';
import 'package:fldanplay/widget/icon_switch.dart';
import 'package:fldanplay/widget/settings/settings_section.dart';
import 'package:fldanplay/widget/settings/settings_tile.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:get_it/get_it.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// 弹幕设置面板
class DanmakuSourceSettings extends StatelessWidget {
  final DanmakuService danmakuService;
  final VideoPlayerService playerService;
  final void Function(RightDrawerType newType) onDrawerChanged;

  const DanmakuSourceSettings({
    super.key,
    required this.danmakuService,
    required this.playerService,
    required this.onDrawerChanged,
  });

  @override
  Widget build(BuildContext context) {
    final globalService = GetIt.I.get<GlobalService>();
    return Scaffold(
      body: Watch((context) {
        final settings = danmakuService.danmakuSettings.value;
        final ratio = globalService.danmakuCount.value;
        return ListView(
          padding: EdgeInsets.all(4),
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Text(
                '弹幕操作',
                style: TextStyle(color: context.theme.colors.mutedForeground),
              ),
            ),
            FButton(
              style: FButtonStyle.secondary(),
              onPress: () => onDrawerChanged(RightDrawerType.danmakuSearch),
              child: const Text('手动搜索获取/更换弹幕'),
            ),
            const SizedBox(height: 8),
            FButton(
              style: FButtonStyle.secondary(),
              onPress: () {
                Navigator.pop(context);
                globalService.showNotification('正在匹配弹幕...');
                playerService.danmakuService.loadDanmaku(force: true);
              },
              child: const Text('重新匹配'),
            ),
            const SizedBox(height: 8),
            FButton(
              style: FButtonStyle.secondary(),
              onPress: () {
                Navigator.pop(context);
                globalService.showNotification('正在加载弹幕...');
                playerService.danmakuService.refreshDanmaku();
              },
              child: const Text('重新加载'),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Text(
                '数据源过滤',
                style: TextStyle(color: context.theme.colors.mutedForeground),
              ),
            ),
            GridView(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                IconSwitch(
                  value: settings.bilibiliSource,
                  onPress: () {
                    danmakuService.updateDanmakuSettings(
                      settings.copyWith(
                        bilibiliSource: !settings.bilibiliSource,
                      ),
                    );
                  },
                  icon: MyIcon.bilibili,
                  title: '哔哩哔哩',
                  subtitle: '(${ratio['BiliBili']!})',
                ),
                IconSwitch(
                  value: settings.gamerSource,
                  onPress: () {
                    danmakuService.updateDanmakuSettings(
                      settings.copyWith(gamerSource: !settings.gamerSource),
                    );
                  },
                  icon: MyIcon.bahamut,
                  title: '巴哈姆特',
                  subtitle: '(${ratio['Gamer']!})',
                ),
                IconSwitch(
                  value: settings.dandanSource,
                  onPress: () {
                    danmakuService.updateDanmakuSettings(
                      settings.copyWith(dandanSource: !settings.dandanSource),
                    );
                  },
                  icon: MyIcon.dandanplay,
                  title: '弹弹play',
                  subtitle: '(${ratio['DanDanPlay']!})',
                ),

                IconSwitch(
                  value: settings.otherSource,
                  onPress: () {
                    danmakuService.updateDanmakuSettings(
                      settings.copyWith(otherSource: !settings.otherSource),
                    );
                  },
                  icon: FIcons.ellipsis,
                  title: '其他',
                  subtitle: '(${ratio['Other']!})',
                ),
              ],
            ),
            SettingsSection(
              title: '延迟设置',
              children: [
                SettingsTile.sliderTile(
                  title: '哔哩哔哩',
                  onSilderChange: (value) {
                    danmakuService.updateDanmakuSettings(
                      settings.copyWith(bilibiliDelay: value.round()),
                    );
                  },
                  details: settings.bilibiliDelay >= 0
                      ? '提前${settings.bilibiliDelay}秒'
                      : '延迟${settings.bilibiliDelay}秒',
                  silderValue: settings.bilibiliDelay.toDouble(),
                  silderDivisions: 40,
                  silderMin: -20,
                  silderMax: 20,
                ),
                SettingsTile.sliderTile(
                  title: '巴哈姆特',
                  onSilderChange: (value) {
                    danmakuService.updateDanmakuSettings(
                      settings.copyWith(gamerDelay: value.round()),
                    );
                  },
                  details: settings.gamerDelay >= 0
                      ? '提前${settings.gamerDelay}秒'
                      : '延迟${settings.gamerDelay}秒',
                  silderValue: settings.gamerDelay.toDouble(),
                  silderDivisions: 40,
                  silderMin: -20,
                  silderMax: 20,
                ),
                SettingsTile.sliderTile(
                  title: '弹弹play',
                  onSilderChange: (value) {
                    danmakuService.updateDanmakuSettings(
                      settings.copyWith(dandanDelay: value.round()),
                    );
                  },
                  details: settings.dandanDelay >= 0
                      ? '提前${settings.dandanDelay}秒'
                      : '延迟${settings.dandanDelay}秒',
                  silderValue: settings.dandanDelay.toDouble(),
                  silderDivisions: 40,
                  silderMin: -20,
                  silderMax: 20,
                ),
                SettingsTile.sliderTile(
                  title: '其他',
                  onSilderChange: (value) {
                    danmakuService.updateDanmakuSettings(
                      settings.copyWith(otherDelay: value.round()),
                    );
                  },
                  details: settings.otherDelay >= 0
                      ? '提前${settings.otherDelay}秒'
                      : '延迟${settings.otherDelay}秒',
                  silderValue: settings.otherDelay.toDouble(),
                  silderDivisions: 40,
                  silderMin: -20,
                  silderMax: 20,
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}
