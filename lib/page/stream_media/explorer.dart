import 'package:fldanplay/model/storage.dart';
import 'package:fldanplay/model/stream_media.dart';
import 'package:fldanplay/page/stream_media/filter_sheet.dart';
import 'package:fldanplay/router.dart';
import 'package:fldanplay/service/storage.dart';
import 'package:fldanplay/service/stream_media_explorer.dart';
import 'package:fldanplay/widget/network_image.dart';
import 'package:fldanplay/widget/sys_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';

class StreamMediaExplorerPage extends StatefulWidget {
  final String storageKey;
  const StreamMediaExplorerPage({super.key, required this.storageKey});

  @override
  State<StreamMediaExplorerPage> createState() =>
      _StreamMediaExplorerPageState();
}

class _StreamMediaExplorerPageState extends State<StreamMediaExplorerPage> {
  late StreamMediaExplorerProvider provider;

  void _openConfigSheet(StreamMediaExplorerService service) {
    showModalBottomSheet(
      isScrollControlled: true,
      useSafeArea: true,
      context: context,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: context.theme.colors.background,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.8,
            minChildSize: 0.4,
            builder: (context, scrollController) {
              return SingleChildScrollView(
                controller: scrollController,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: StreamMediaFilterSheet(service: service),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMediaCard(MediaItem mediaItem) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      shape: Border.all(color: Colors.transparent),
      child: InkWell(
        onTap: () {
          context.push(streamMediaDetailPath, extra: mediaItem);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 0.7,
              child: LayoutBuilder(
                builder: (context, boxConstraints) {
                  final double maxWidth = boxConstraints.maxWidth;
                  final double maxHeight = boxConstraints.maxHeight;
                  return Hero(
                    transitionOnUserGestures: true,
                    tag: mediaItem.id,
                    child: NetworkImageWidget(
                      url: provider.getImageUrl(mediaItem.id),
                      headers: provider.headers,
                      maxWidth: maxWidth,
                      maxHeight: maxHeight,
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 3, 4, 1),
              child: Text(
                mediaItem.name,
                style: context.theme.typography.sm,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final storageService = GetIt.I.get<StorageService>();
    final storage = storageService.get(widget.storageKey);
    final streamMediaExplorerService =
        GetIt.I.get<StreamMediaExplorerService>();
    if (storage == null) {
      return const Center(child: Text('存储配置不存在'));
    }
    switch (storage.storageType) {
      case StorageType.jellyfin:
        provider = JellyfinStreamMediaExplorerProvider(
          storage.url,
          storage.token!,
          storage.uniqueKey,
        );
        break;
      default:
        return const Center(child: Text('不支持的媒体库类型'));
    }
    streamMediaExplorerService.setProvider(provider, storage);
    return Scaffold(
      appBar: SysAppBar(title: storage.name),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: OrientationBuilder(
          builder: (context, orientation) {
            int crossCount = orientation != Orientation.portrait ? 6 : 3;
            return LayoutBuilder(
              builder: (context, constraints) {
                return Watch((context) {
                  return streamMediaExplorerService.items.value.map(
                    data: (items) {
                      return CustomScrollView(
                        slivers: [
                          SliverGrid(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  // 行间距
                                  mainAxisSpacing: 6,
                                  // 列间距
                                  crossAxisSpacing: 6,
                                  // 最大列宽
                                  crossAxisCount: crossCount,
                                  mainAxisExtent:
                                      constraints.maxWidth / crossCount / 0.7 +
                                      36,
                                ),
                            delegate: SliverChildBuilderDelegate((
                              BuildContext context,
                              int index,
                            ) {
                              return _buildMediaCard(items[index]);
                            }, childCount: items.length),
                          ),
                          if (items.length == 300)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  '最多显示300个结果，更多结果请使用筛选',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                    error:
                        (error, stack) =>
                            Center(child: Text('加载失败\n${error.toString()}')),
                    loading:
                        () => const Center(child: CircularProgressIndicator()),
                  );
                });
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openConfigSheet(streamMediaExplorerService),
        shape: CircleBorder(),
        child: const Icon(FIcons.listFilter),
      ),
    );
  }
}
