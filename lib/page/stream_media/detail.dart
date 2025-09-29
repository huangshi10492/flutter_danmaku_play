import 'dart:ui';

import 'package:fldanplay/model/stream_media.dart';
import 'package:fldanplay/router.dart';
import 'package:fldanplay/service/global.dart';
import 'package:fldanplay/service/history.dart';
import 'package:fldanplay/service/stream_media_explorer.dart';
import 'package:fldanplay/utils/crypto_utils.dart';
import 'package:fldanplay/widget/network_image.dart';
import 'package:fldanplay/widget/rating_bar.dart';
import 'package:fldanplay/widget/video_item.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';

class StreamMediaDetailPage extends StatefulWidget {
  final MediaItem mediaItem;
  const StreamMediaDetailPage({super.key, required this.mediaItem});

  @override
  State<StreamMediaDetailPage> createState() => _StreamMediaDetailPageState();
}

class _StreamMediaDetailPageState extends State<StreamMediaDetailPage>
    with TickerProviderStateMixin {
  late final StreamMediaExplorerService _service;
  final _historyService = GetIt.I.get<HistoryService>();
  late TabController _tabController;
  MediaDetail? _mediaDetail;
  bool _isLoading = true;
  String? _error;
  final Map<String, int> _refreshMap = {};

  @override
  void initState() {
    super.initState();
    _service = GetIt.I.get<StreamMediaExplorerService>();
    _tabController = TabController(length: 0, vsync: this);
    _loadMediaDetail();
    GetIt.I.get<GlobalService>().updateListener = refreshItem;
  }

  @override
  void dispose() {
    _tabController.dispose();
    GetIt.I.get<GlobalService>().updateListener = null;
    super.dispose();
  }

  // 触发单个项刷新的方法
  void refreshItem(String uniqueKey) {
    setState(() {
      _refreshMap[uniqueKey] = (_refreshMap[uniqueKey] ?? 0) + 1;
    });
  }

  Future<void> _loadMediaDetail() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final detail = await _service.getMediaDetail(widget.mediaItem.id);

      setState(() {
        _mediaDetail = detail;
        _isLoading = false;

        // 重新创建TabController
        _tabController.dispose();
        _tabController = TabController(
          length: detail.seasons.length,
          vsync: this,
        );
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLandscape = constraints.maxWidth > constraints.maxHeight;
          return isLandscape ? _buildLandscapeLayout() : _buildPortraitLayout();
        },
      ),
    );
  }

  Widget _buildPortraitLayout() {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: SliverAppBar.medium(
              title: Text(widget.mediaItem.name),
              scrolledUnderElevation: 0,
              stretch: true,
              centerTitle: false,
              expandedHeight: 300 + kTextTabBarHeight + kToolbarHeight,
              toolbarHeight: kToolbarHeight,
              collapsedHeight:
                  kTextTabBarHeight +
                  kToolbarHeight +
                  MediaQuery.paddingOf(context).top,
              forceElevated: innerBoxIsScrolled,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: Stack(
                  children: [
                    SizedBox(
                      height: 300 + kTextTabBarHeight + kToolbarHeight,
                      child: _buildbackground(false),
                    ),
                    SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16, kToolbarHeight, 16, 0),
                        child: _buildMediaInfoWithLoading(),
                      ),
                    ),
                  ],
                ),
              ),

              bottom: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                dividerHeight: 0,
                tabs:
                    _mediaDetail == null
                        ? []
                        : _mediaDetail!.seasons
                            .map((season) => Tab(text: season.name))
                            .toList(),
              ),
            ),
          ),
        ];
      },
      body: _buildPortraitTabContent(),
    );
  }

  Widget _buildLandscapeLayout() {
    return Row(
      children: [
        Stack(
          children: [
            SizedBox(width: 380, child: _buildbackground(true)),
            SafeArea(
              child: SizedBox(
                width: 400,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: IconButton(
                        icon: const Icon(FIcons.arrowLeft, size: 24),
                        onPressed: () => context.pop(),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 16,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildMediaInfoWithLoading(isLandscape: true),
                              const SizedBox(height: 16),
                              _buildDetail(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: SafeArea(
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  dividerHeight: 0,
                  tabs:
                      _mediaDetail == null
                          ? []
                          : _mediaDetail!.seasons
                              .map((season) => Tab(text: season.name))
                              .toList(),
                ),
                Expanded(child: _buildLandscapeTabContent()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPortraitTabContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('加载失败: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMediaDetail,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (_mediaDetail == null || _mediaDetail!.seasons.isEmpty) {
      return const Center(child: Text('暂无季度信息'));
    }

    return TabBarView(
      controller: _tabController,
      children:
          _mediaDetail!.seasons.map((season) {
            if (season.episodes.isEmpty) {
              return const Center(child: Text('暂无集数'));
            }
            return Builder(
              builder: (BuildContext context) {
                return CustomScrollView(
                  scrollBehavior: const ScrollBehavior().copyWith(
                    scrollbars: false,
                  ),
                  slivers: <Widget>[
                    SliverOverlapInjector(
                      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                        context,
                      ),
                    ),
                    SliverLayoutBuilder(
                      builder: (context, constraints) {
                        return SliverList.builder(
                          itemCount: season.episodes.length,
                          itemBuilder: (context, index) {
                            return _buildSeasonViewBuilder(
                              context,
                              index,
                              season,
                            );
                          },
                        );
                      },
                    ),
                  ],
                );
              },
            );
          }).toList(),
    );
  }

  Widget _buildLandscapeTabContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('加载失败: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMediaDetail,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }
    if (_mediaDetail == null || _mediaDetail!.seasons.isEmpty) {
      return const Center(child: Text('暂无季度信息'));
    }

    return TabBarView(
      controller: _tabController,
      children:
          _mediaDetail!.seasons.map((season) {
            if (season.episodes.isEmpty) {
              return const Center(child: Text('暂无集数'));
            }
            return ListView.builder(
              itemCount: season.episodes.length,
              itemBuilder: (context, index) {
                return _buildSeasonViewBuilder(context, index, season);
              },
            );
          }).toList(),
    );
  }

  Widget _buildMediaInfoWithLoading({bool isLandscape = false}) {
    final provider = _service.provider;
    return SizedBox(
      height: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.mediaItem.name,
            style: context.theme.typography.xl.copyWith(height: 1.4),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 0.7,
                  child: LayoutBuilder(
                    builder: (context, boxConstraints) {
                      final double maxWidth = boxConstraints.maxWidth;
                      final double maxHeight = boxConstraints.maxHeight;
                      return Hero(
                        transitionOnUserGestures: true,
                        tag: widget.mediaItem.id,
                        child: NetworkImageWidget(
                          url: provider.getImageUrl(widget.mediaItem.id),
                          headers: provider.headers,
                          maxWidth: maxWidth,
                          maxHeight: maxHeight,
                          large: true,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Skeletonizer(
                    enabled: _isLoading,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        if (isLandscape) {
                          return;
                        }
                        showModalBottomSheet(
                          isScrollControlled: true,
                          useSafeArea: true,
                          showDragHandle: true,
                          context: context,
                          builder: (context) {
                            return DraggableScrollableSheet(
                              expand: false,
                              initialChildSize: 0.6,
                              minChildSize: 0.4,
                              builder: (context, scrollController) {
                                return SingleChildScrollView(
                                  controller: scrollController,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: context.theme.colors.background,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(8),
                                        topRight: Radius.circular(8),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 16,
                                        right: 16,
                                        bottom: 16,
                                      ),
                                      child: _buildDetail(),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8, top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('年份:'),
                            Text(
                              _mediaDetail == null
                                  ? '2000'
                                  : _mediaDetail!.productionYear.toString(),
                              style: TextStyle(
                                fontSize: 24,
                                height: 1.5,
                                fontWeight: FontWeight.bold,
                                color: context.theme.colors.primary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text('评分:'),
                            const SizedBox(height: 6),
                            _mediaDetail == null
                                ? Text(
                                  '********',
                                  style: TextStyle(
                                    fontSize: 20,
                                    height: 1.2,
                                    fontWeight: FontWeight.bold,
                                    color: context.theme.colors.primary,
                                  ),
                                )
                                : RatingBar(
                                  rating: _mediaDetail?.rating ?? 0.0,
                                ),
                            Text(
                              _mediaDetail == null
                                  ? '0.0'
                                  : _mediaDetail!.rating.toString(),
                              style: TextStyle(
                                fontSize: 22,
                                height: 1.4,
                                fontWeight: FontWeight.bold,
                                color: context.theme.colors.primary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text('分类:'),
                            const SizedBox(height: 6),
                            Text(
                              _mediaDetail == null
                                  ? '分类1, 分类2, 分类3' // Skeleton Loader 占位符
                                  : _mediaDetail!.genres.join(' / '),
                              style: TextStyle(fontSize: 14, height: 1.25),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildbackground(bool isLandscape) {
    if (_mediaDetail == null) {
      return Container();
    }
    return IgnorePointer(
      child: Opacity(
        opacity: 0.3,
        child: LayoutBuilder(
          builder: (context, boxConstraints) {
            return ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    begin:
                        isLandscape
                            ? Alignment.centerLeft
                            : Alignment.topCenter,
                    end:
                        isLandscape
                            ? Alignment.centerRight
                            : Alignment.bottomCenter,
                    colors: [Colors.white, Colors.transparent],
                    stops: [0.8, 1],
                  ).createShader(bounds);
                },
                child: NetworkImageWidget(
                  url: _service.provider.getImageUrl(widget.mediaItem.id),
                  headers: _service.provider.headers,
                  maxWidth: boxConstraints.maxWidth,
                  maxHeight: boxConstraints.maxHeight,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDetail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('简介', style: context.theme.typography.xl),
        const SizedBox(height: 4),
        Text(
          (_mediaDetail?.overview
                  ?.replaceAll('<br>', ' ')
                  .replaceAll('<br/>', ' ')
                  .replaceAll('<br />', ' ')) ??
              '',
          style: context.theme.typography.base,
        ),
        const SizedBox(height: 16),
        Text('标签', style: context.theme.typography.xl),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              _mediaDetail?.tags.map((tag) {
                return Padding(
                  padding: const EdgeInsets.all(2),
                  child: FFocusedOutline(
                    focused: true,
                    style:
                        (style) => style.copyWith(
                          color: context.theme.colors.mutedForeground,
                        ),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Text(tag),
                    ),
                  ),
                );
              }).toList() ??
              [],
        ),
        const SizedBox(height: 16),
        Text('外部链接', style: context.theme.typography.xl),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              _mediaDetail?.externalUrls.map((url) {
                return InkWell(
                  onTap: () {
                    launchUrl(Uri.parse(url.url));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: FFocusedOutline(
                      focused: true,
                      style:
                          (style) => style.copyWith(
                            color: context.theme.colors.mutedForeground,
                          ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Text(
                          url.name,
                          style: context.theme.typography.base,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList() ??
              [],
        ),
      ],
    );
  }

  Widget _buildSeasonViewBuilder(
    BuildContext context,
    int index,
    SeasonInfo season,
  ) {
    final episode = season.episodes[index];
    final uniqueKey = CryptoUtils.generateVideoUniqueKey(episode.id);
    _refreshMap[uniqueKey] ??= 0;
    final refreshKey = _refreshMap[uniqueKey]!;
    return VideoItem(
      key: ValueKey(uniqueKey),
      refreshKey: refreshKey,
      imageUrl: _service.provider.getImageUrl(episode.id),
      headers: _service.provider.headers,
      name: '${episode.indexNumber}. ${episode.name}',
      history: _historyService.getHistoryByPath(episode.id),
      onPress: () async {
        try {
          _service.setVideoList(season);
          final videoInfo = await _service.getVideoInfo(index);
          if (mounted) {
            final location = Uri(path: videoPlayerPath);
            this.context.push(location.toString(), extra: videoInfo);
          }
        } catch (e) {
          if (mounted) {
            showFToast(
              context: this.context,
              title: Text('播放失败: ${e.toString()}'),
            );
          }
        }
      },
    );
  }
}
