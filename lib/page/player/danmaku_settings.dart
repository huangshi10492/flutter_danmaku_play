import 'package:fldanplay/service/player/danmaku.dart';
import 'package:fldanplay/widget/icon_switch.dart';
import 'package:fldanplay/widget/settings/settings_section.dart';
import 'package:fldanplay/widget/settings/settings_tile.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// 弹幕设置面板
class DanmakuSettingsPanel extends StatelessWidget {
  final DanmakuService danmakuService;

  const DanmakuSettingsPanel({super.key, required this.danmakuService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Watch((context) {
        final settings = danmakuService.danmakuSettings.value;
        return ListView(
          padding: EdgeInsets.all(4),
          children: [
            SettingsSection(
              title: '样式设置',
              children: [
                SettingsTile.sliderTile(
                  title: '透明度',
                  onSilderChange: (value) {
                    danmakuService.updateDanmakuSettings(
                      settings.copyWith(opacity: value),
                    );
                  },
                  details: settings.opacity.toStringAsFixed(1),
                  silderValue: settings.opacity,
                  silderDivisions: 10,
                  silderMin: 0,
                  silderMax: 1,
                ),
                SettingsTile.sliderTile(
                  title: '字体大小',
                  onSilderChange: (value) {
                    danmakuService.updateDanmakuSettings(
                      settings.copyWith(fontSize: value),
                    );
                  },
                  details: settings.fontSize.round().toString(),
                  silderValue: settings.fontSize,
                  silderDivisions: 22,
                  silderMin: 10,
                  silderMax: 32,
                ),
                SettingsTile.sliderTile(
                  title: '字体粗细',
                  onSilderChange: (value) {
                    danmakuService.updateDanmakuSettings(
                      settings.copyWith(fontWeight: value.round()),
                    );
                  },
                  details: settings.fontWeight.toString(),
                  silderValue: settings.fontWeight.toDouble(),
                  silderDivisions: 8,
                  silderMin: 0,
                  silderMax: 8,
                ),
                SettingsTile.sliderTile(
                  title: '描边宽度',
                  onSilderChange: (value) {
                    danmakuService.updateDanmakuSettings(
                      settings.copyWith(strokeWidth: value),
                    );
                  },
                  details: settings.strokeWidth.toString(),
                  silderValue: settings.strokeWidth,
                  silderDivisions: 16,
                  silderMin: 0,
                  silderMax: 4,
                ),
                SettingsTile.sliderTile(
                  title: '显示时长',
                  onSilderChange: (value) {
                    danmakuService.updateDanmakuSettings(
                      settings.copyWith(duration: value),
                    );
                  },
                  details: settings.duration.toString(),
                  silderValue: settings.duration.toDouble(),
                  silderDivisions: 16,
                  silderMin: 1,
                  silderMax: 17,
                ),
                SettingsTile.sliderTile(
                  title: '弹幕区域',
                  onSilderChange: (value) {
                    danmakuService.updateDanmakuSettings(
                      settings.copyWith(danmakuArea: value),
                    );
                  },
                  details: '${(settings.danmakuArea * 100).round()}%',
                  silderValue: settings.danmakuArea,
                  silderDivisions: 4,
                  silderMin: 0,
                  silderMax: 1,
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Text(
                '按位置过滤',
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
                  value: !settings.hideScroll,
                  onPress: () {
                    danmakuService.updateDanmakuSettings(
                      settings.copyWith(hideScroll: !settings.hideScroll),
                    );
                  },
                  icon: Icons.arrow_forward,
                  title: '滚动弹幕',
                ),
                IconSwitch(
                  value: !settings.hideTop,
                  onPress: () {
                    danmakuService.updateDanmakuSettings(
                      settings.copyWith(hideTop: !settings.hideTop),
                    );
                  },
                  icon: Icons.arrow_upward,
                  title: '顶部弹幕',
                ),
                IconSwitch(
                  value: !settings.hideBottom,
                  onPress: () {
                    danmakuService.updateDanmakuSettings(
                      settings.copyWith(hideBottom: !settings.hideBottom),
                    );
                  },
                  icon: Icons.arrow_downward,
                  title: '底部弹幕',
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}
