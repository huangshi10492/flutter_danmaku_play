import 'package:fldanplay/model/video_info.dart';
import 'package:fldanplay/widget/storage_sheet.dart';
import 'package:fldanplay/router.dart';
import 'package:fldanplay/service/storage.dart';
import 'package:fldanplay/utils/theme.dart';
import 'package:fldanplay/widget/sys_app_bar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../model/storage.dart';
import '../model/history.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => RootPageState();
}

class RootPageState extends State<RootPage> {
  final _storageService = GetIt.I.get<StorageService>();

  void _showDeleteDialog(Storage storage) {
    showAdaptiveDialog(
      context: context,
      builder:
          (context) => FDialog(
            direction: Axis.vertical,
            title: const Text('删除媒体库'),
            body: Text('确定要删除媒体库 "${storage.name}" 吗？'),
            actions: [
              FButton(
                onPress: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              FButton(
                style: FButtonStyle.destructive(),
                onPress: () {
                  Navigator.pop(context);
                  storage.delete();
                },
                child: const Text('删除'),
              ),
            ],
          ),
    );
  }

  void _showPlayVideoDialog() {
    showFDialog(
      context: context,
      builder: (context, style, animation) {
        return FDialog(
          style: style.call,
          animation: animation,
          title: const Text('选择视频来源'),
          body: const SizedBox(height: 8),
          actions: [
            FButton(
              style: FButtonStyle.outline(),
              onPress: () {
                Navigator.pop(context);
                _playLocalVideo();
              },
              child: const Text('本地'),
            ),
            FButton(
              style: FButtonStyle.outline(),
              onPress: () {
                Navigator.pop(context);
                _playNetworkVideo();
              },
              child: const Text('网络'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _playLocalVideo() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );
      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final videoInfo = VideoInfo.fromFile(
          currentVideoPath: filePath,
          virtualVideoPath: filePath,
          historiesType: HistoriesType.local,
        );
        if (mounted) {
          final location = Uri(path: videoPlayerPath);
          context.push(location.toString(), extra: videoInfo);
        }
      }
    } catch (e) {
      if (mounted) {
        showFToast(
          context: context,
          alignment: FToastAlignment.topRight,
          title: const Text('选择文件失败'),
          description: Text('$e'),
        );
      }
    }
  }

  Future<void> _playNetworkVideo() async {
    try {
      showFDialog(
        context: context,
        builder: (context, style, animation) {
          final controller = TextEditingController();
          return FDialog(
            title: Text('请输入视频URL'),
            direction: Axis.horizontal,
            body: FTextField(controller: controller),
            actions: [
              FButton(
                style: FButtonStyle.outline(),
                onPress: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              FButton(
                onPress: () {
                  final url = controller.text.trim();
                  if (url.isEmpty) {
                    return;
                  }
                  // 格式校验
                  if (!url.startsWith('http')) {
                    showFToast(
                      context: context,
                      alignment: FToastAlignment.topRight,
                      title: const Text('请输入有效的网络视频URL'),
                    );
                    return;
                  }
                  final videoInfo = VideoInfo(
                    currentVideoPath: url,
                    virtualVideoPath: url,
                    historiesType: HistoriesType.network,
                    videoName: url.split('/').last.split('.').first,
                    name: url.split('/').last,
                  );
                  if (mounted) {
                    final location = Uri(path: videoPlayerPath);
                    context.push(location.toString(), extra: videoInfo);
                  }
                  Navigator.pop(context);
                },
                child: const Text('确定'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (mounted) {
        showFToast(
          context: context,
          alignment: FToastAlignment.topRight,
          title: const Text('播放视频失败'),
          description: Text('$e'),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SysAppBar(
        title: '主页',
        actions: [
          FButton.icon(
            style: FButtonStyle.ghost(),
            child: const Icon(FIcons.settings, size: 24),
            onPress: () => context.push(settingsPath),
          ),
        ],
      ),
      body: Watch((_) {
        final storages = _storageService.storages.value;
        return SingleChildScrollView(
          child: SafeArea(
            child: FItemGroup(
              divider: FItemDivider.indented,
              style: rootItemGroupStyle,
              children: [
                FItem(
                  prefix: const Icon(FIcons.clock),
                  title: const Text('观看历史'),
                  subtitle: Text('查看观看历史'),
                  onPress: () => context.push(historyPath),
                ),
                FItem(
                  prefix: const Icon(FIcons.play),
                  title: const Text('选择视频播放'),
                  subtitle: Text('选择本地视频或网络视频'),
                  onPress: () => _showPlayVideoDialog(),
                ),
                ...storages.map(
                  (storage) => _PopoverMenu(
                    edit: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        enableDrag: false,
                        builder: (context) {
                          return AnimatedPadding(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                            ),
                            duration: Duration.zero,
                            child: EditStorageSheet(
                              storageKey: storage.key,
                              storageType: storage.storageType,
                            ),
                          );
                        },
                      );
                    },
                    delete: () => _showDeleteDialog(storage),
                    child:
                        (controller) => FItem(
                          prefix: const Icon(FIcons.folder),
                          title: Text(storage.name),
                          subtitle: Text(storage.url),
                          onPress: () {
                            switch (storage.storageType) {
                              case StorageType.webdav:
                              case StorageType.ftp:
                              case StorageType.smb:
                              case StorageType.local:
                                context.push(
                                  '$fileExplorerPath?key=${storage.key}',
                                );
                                break;
                              case StorageType.jellyfin:
                              case StorageType.emby:
                                context.push(
                                  '$streamMediaExplorerPath?key=${storage.key}',
                                );
                                break;
                            }
                          },
                          onLongPress: () async {
                            controller.toggle();
                          },
                        ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => showModalBottomSheet(
              context: context,
              builder: (context) {
                return SelectStorageTypeSheet();
              },
            ),
        shape: CircleBorder(),
        child: const Icon(FIcons.plus),
      ),
    );
  }
}

class _PopoverMenu extends StatefulWidget with FItemMixin {
  final Function edit;
  final Function delete;
  final Widget Function(FPopoverController controller) child;
  const _PopoverMenu({
    required this.edit,
    required this.delete,
    required this.child,
  });
  @override
  _PopoverMenuState createState() => _PopoverMenuState();
}

class _PopoverMenuState extends State<_PopoverMenu>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final controller = FPopoverController(vsync: this);
    return FPopoverMenu(
      popoverController: controller,
      menu: [
        FItemGroup(
          children: [
            FItem(
              prefix: const Icon(FIcons.pencil),
              title: Text('编辑'),
              onPress: () {
                controller.toggle();
                widget.edit();
              },
            ),
            FItem(
              prefix: const Icon(FIcons.trash, color: Colors.red),
              title: Text('删除'),
              onPress: () {
                controller.toggle();
                widget.delete();
              },
            ),
          ],
        ),
      ],
      child: widget.child(controller),
    );
  }
}
