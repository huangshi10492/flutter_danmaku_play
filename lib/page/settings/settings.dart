import 'package:fldanplay/utils/theme.dart';
import 'package:fldanplay/widget/sys_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SysAppBar(title: '设置'),
      body: SingleChildScrollView(
        child: SafeArea(
          child: FItemGroup(
            style: settingsItemGroupStyle,
            divider: FItemDivider.indented,
            children: [
              FItem(
                prefix: const Icon(FIcons.video, size: 24),
                title: const Text('播放器'),
                subtitle: const Text('设置播放器的相关参数'),
                onPress: () => context.push('/settings/player'),
              ),
              FItem(
                prefix: const Icon(FIcons.captions, size: 24),
                title: const Text('弹幕'),
                subtitle: const Text('设置弹幕相关参数'),
                onPress: () => context.push('/settings/danmaku'),
              ),
              FItem(
                prefix: const Icon(FIcons.type, size: 24),
                title: const Text('字体'),
                subtitle: const Text('管理视频字幕字体'),
                onPress: () => context.push('/settings/font'),
              ),
              FItem(
                prefix: const Icon(FIcons.palette, size: 24),
                title: const Text('界面'),
                subtitle: const Text('设置应用主题'),
                onPress: () => context.push('/settings/appearance'),
              ),
              FItem(
                prefix: const Icon(FIcons.cloud, size: 24),
                title: const Text('同步'),
                subtitle: const Text('设置 WebDAV 同步参数'),
                onPress: () => context.push('/settings/webdav'),
              ),
              FItem(
                prefix: const Icon(FIcons.logs, size: 24),
                title: const Text('日志'),
                subtitle: const Text('设置日志级别和导出日志'),
                onPress: () => context.push('/settings/log'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
