import 'package:fldanplay/service/configure.dart';
import 'package:fldanplay/widget/settings/settings_scaffold.dart';
import 'package:fldanplay/widget/settings/settings_section.dart';
import 'package:fldanplay/widget/settings/settings_tile.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:signals_flutter/signals_flutter.dart';

class GeneralSettingsPage extends StatelessWidget {
  const GeneralSettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final configure = GetIt.I<ConfigureService>();
    return SettingsScaffold(
      title: '通用设置',
      child: Watch((context) {
        return Column(
          children: [
            SettingsSection(
              title: '主题',
              children: [
                SettingsTile.radioTile(
                  title: '主题模式',
                  radioValue: configure.themeMode.value,
                  onRadioChange: (value) {
                    configure.themeMode.value = value;
                  },
                  radioOptions: {'跟随系统': '0', '浅色模式': '1', '深色模式': '2'},
                ),
                SettingsTile.radioTile(
                  title: '主题颜色',
                  radioValue: configure.themeColor.value,
                  onRadioChange: (value) {
                    configure.themeColor.value = value;
                  },
                  radioOptions: {
                    '蓝色': 'blue',
                    '灰白色': 'zinc',
                    '深灰色': 'slate',
                    '红色': 'red',
                    '玫瑰色': 'rose',
                    '橙色': 'orange',
                    '绿色': 'green',
                    '黄色': 'yellow',
                    '紫色': 'violet',
                  },
                ),
              ],
            ),
            SettingsSection(
              title: '缓存',
              children: [
                SettingsTile.switchTile(
                  title: '优先使用离线缓存',
                  subtitle: '开启后，优先使用离线缓存播放视频',
                  switchValue: configure.offlineCacheFirst.value,
                  onBoolChange: (value) {
                    configure.offlineCacheFirst.value = value;
                  },
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}
