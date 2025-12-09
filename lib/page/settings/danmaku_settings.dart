import 'package:fldanplay/service/configure.dart';
import 'package:fldanplay/widget/settings/settings_scaffold.dart';
import 'package:fldanplay/widget/settings/settings_section.dart';
import 'package:fldanplay/widget/settings/settings_tile.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:get_it/get_it.dart';
import 'package:signals_flutter/signals_flutter.dart';

class DanmakuSettingsPage extends StatelessWidget {
  const DanmakuSettingsPage({super.key});
  void _showInputDialog({
    required BuildContext context,
    required String title,
    required String currentValue,
    required Function(String) onSave,
  }) {
    showFDialog(
      context: context,
      builder: (context, style, animation) {
        final controller = TextEditingController(text: currentValue);
        return FDialog(
          style: style.call,
          direction: Axis.horizontal,
          animation: animation,
          title: Text(title),
          body: FTextField(controller: controller),
          actions: [
            FButton(
              style: FButtonStyle.outline(),
              onPress: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            FButton(
              onPress: () {
                onSave(controller.text);
                Navigator.pop(context);
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final configure = GetIt.I<ConfigureService>();
    return SettingsScaffold(
      title: '弹幕设置',
      child: Watch((context) {
        return Column(
          children: [
            SettingsSection(
              title: '弹幕',
              children: [
                SettingsTile.switchTile(
                  title: '默认启用弹幕',
                  switchValue: configure.defaultDanmakuEnable.value,
                  onBoolChange: (value) {
                    configure.defaultDanmakuEnable.value = value;
                  },
                ),
              ],
            ),
            SettingsSection(
              title: '弹幕服务',
              children: [
                SettingsTile.switchTile(
                  title: '启用弹幕服务',
                  switchValue: configure.danmakuServiceEnable.value,
                  onBoolChange: (value) {
                    configure.danmakuServiceEnable.value = value;
                  },
                ),
                //地址
                SettingsTile.navigationTile(
                  title: '弹幕服务地址',
                  subtitle: configure.danmakuServiceUrl.value,
                  onPress: () => _showInputDialog(
                    context: context,
                    title: '弹幕服务地址',
                    currentValue: configure.danmakuServiceUrl.value,
                    onSave: (value) =>
                        configure.danmakuServiceUrl.value = value,
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}
