import 'dart:io';

import 'package:fldanplay/service/configure.dart';
import 'package:fldanplay/utils/toast.dart';
import 'package:fldanplay/widget/settings/settings_scaffold.dart';
import 'package:fldanplay/widget/settings/settings_section.dart';
import 'package:fldanplay/widget/settings/settings_tile.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:get_it/get_it.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signals_flutter/signals_flutter.dart';

class FontManagerPage extends StatefulWidget {
  const FontManagerPage({super.key});

  @override
  State<FontManagerPage> createState() => _FontManagerPageState();
}

class _FontManagerPageState extends State<FontManagerPage> {
  late final ConfigureService _configureService =
      GetIt.I.get<ConfigureService>();

  final List<Map<String, String>> _fontPresets = [
    {
      'name': 'NotoSansCJKsc-Regular',
      'url':
          'https://github.com/notofonts/noto-cjk/raw/refs/heads/main/Sans/OTF/SimplifiedChinese/NotoSansCJKsc-Regular.otf',
      'fontName': 'NotoSansCJKsc-Regular',
    },
    {
      'name': 'NotoSansCJKsc-Regular(Mirror)',
      'url':
          'https://ghproxy.net/https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/OTF/SimplifiedChinese/NotoSansCJKsc-Regular.otf',
      'fontName': 'NotoSansCJKsc-Regular',
    },
  ];

  Future<void> _selectLocalFont() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['ttf', 'otf'],
    );

    if (result != null) {
      final filePath = result.files.single.path;
      if (filePath != null) {
        final file = File(filePath);
        final fileName = file.uri.pathSegments.last;

        // 保存字体文件名到配置中
        _configureService.subtitleFontName.value = fileName.split('.').first;
      }
    }
  }

  Future<void> _downloadAndSelectFont(Map<String, String> font) async {
    // 获取应用文档目录
    final appDir = await getApplicationSupportDirectory();
    final fontsDir = Directory('${appDir.path}/fonts');

    // 创建字体目录（如果不存在）
    if (!await fontsDir.exists()) {
      await fontsDir.create(recursive: true);
    }

    // 构造字体文件路径
    final fontFile = File('${fontsDir.path}/${font['fontName']!}');

    // 保存当前的BuildContext引用
    final currentContext = context;

    // 创建进度状态
    int downloaded = 0;
    int total = 0;
    bool isCancelled = false;

    // 创建可更新的弹窗
    late StateSetter dialogStateSetter;

    // 创建取消令牌
    final cancelToken = CancelToken();

    // 显示进度弹窗
    if (currentContext.mounted) {
      showFDialog(
        context: currentContext,
        barrierDismissible: false,
        builder: (BuildContext context, style, animation) {
          return StatefulBuilder(
            builder: (context, setState) {
              dialogStateSetter = setState;

              final progress = total > 0 ? downloaded / total : 0.0;
              final downloadedMB = downloaded / (1024 * 1024);
              final totalMB = total / (1024 * 1024);

              return PopScope(
                canPop: false, // 禁止返回键关闭对话框
                child: FDialog(
                  direction: Axis.horizontal,
                  title: Text('正在下载字体'),
                  animation: animation,
                  body: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(font['name']!),
                      SizedBox(height: 8),
                      LinearProgressIndicator(value: progress.toDouble()),
                      SizedBox(height: 16),
                      Text(
                        total > 0
                            ? '${downloadedMB.toStringAsFixed(2)}MB / ${totalMB.toStringAsFixed(2)}MB'
                            : '正在获取文件信息...',
                      ),
                    ],
                  ),

                  actions: [
                    TextButton(
                      onPressed: () {
                        // 设置取消标志
                        isCancelled = true;
                        // 取消下载
                        cancelToken.cancel();
                      },
                      child: Text('取消'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    }

    try {
      // 下载字体文件
      final dio = Dio();
      await dio.download(
        font['url']!,
        fontFile.path,
        cancelToken: cancelToken,
        onReceiveProgress: (received, totalReceived) {
          // 如果已取消，则不更新进度
          if (isCancelled) return;

          // 更新进度
          if (currentContext.mounted) {
            dialogStateSetter(() {
              downloaded = received;
              total = totalReceived;
            });
          }
        },
      );

      // 检查是否已取消
      if (isCancelled) {
        // 删除可能已部分下载的文件
        if (await fontFile.exists()) {
          await fontFile.delete();
        }
        return; // 直接返回，不执行后续操作
      }

      // 关闭进度弹窗
      if (currentContext.mounted) {
        Navigator.of(currentContext).pop();
      }

      // 保存字体名称到配置中
      _configureService.subtitleFontName.value = font['fontName']!;

      // 显示成功提示
      if (currentContext.mounted) {
        showToast(currentContext, title: '字体下载成功');
      }
    } on DioException catch (e) {
      // 关闭进度弹窗
      if (currentContext.mounted) {
        Navigator.of(currentContext).pop();
      }

      // 检查是否是取消操作
      if (e.type == DioExceptionType.cancel) {
        // 删除可能已部分下载的文件
        if (await fontFile.exists()) {
          await fontFile.delete();
        }
        // 显示取消提示
        if (currentContext.mounted) {
          showToast(currentContext, level: 1, title: '下载已取消');
        }
        return;
      }

      // 显示错误提示
      if (currentContext.mounted) {
        showToast(
          currentContext,
          level: 3,
          title: '字体下载失败',
          description: e.toString(),
        );
      }
    } catch (e) {
      // 关闭进度弹窗
      if (currentContext.mounted) {
        Navigator.of(currentContext).pop();
      }

      // 显示错误提示
      if (currentContext.mounted) {
        showToast(
          currentContext,
          level: 3,
          title: '字体下载失败',
          description: e.toString(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SettingsScaffold(
      title: '字体管理',
      child: Watch((context) {
        final currentFont = _configureService.subtitleFontName.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingsSection(
              title: '当前字体',
              children: [
                SettingsTile.simpleTile(
                  title: '当前选择的字体',
                  subtitle: currentFont.isEmpty ? '未选择字体' : currentFont,
                ),
                SettingsTile.simpleTile(
                  title: '重置为系统默认字体',
                  subtitle: '点击重置为系统默认字体',
                  onPress: () {
                    _configureService.subtitleFontName.value = '';
                  },
                ),
              ],
            ),
            SettingsSection(
              title: '字体预设',
              children: [
                ..._fontPresets.map(
                  (font) => SettingsTile.simpleTile(
                    title: font['name']!,
                    subtitle: '点击下载并使用此字体',
                    onPress: () => _downloadAndSelectFont(font),
                  ),
                ),
              ],
            ),
            SettingsSection(
              title: '本地字体',
              children: [
                SettingsTile.simpleTile(
                  title: '选择本地字体文件',
                  subtitle: '支持 TTF 和 OTF 格式',
                  onPress: _selectLocalFont,
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}
