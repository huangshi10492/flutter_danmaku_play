import 'package:fldanplay/model/danmaku.dart';
import 'package:fldanplay/service/player/danmaku.dart';
import 'package:fldanplay/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

enum _DanmakuSearchState { matching, matchSuccess, search, searching, saving }

class DanmakuMatchDialog extends StatefulWidget {
  final String uniqueKey;
  final String fileName;
  const DanmakuMatchDialog({
    super.key,
    required this.uniqueKey,
    required this.fileName,
  });

  @override
  State<DanmakuMatchDialog> createState() => _DanmakuMatchDialogState();
}

class _DanmakuMatchDialogState extends State<DanmakuMatchDialog> {
  final _searchController = TextEditingController();
  final danmakuGetter = DanmakuGetter();
  _DanmakuSearchState _state = _DanmakuSearchState.matching;
  String _message = '';
  String? _errorMessage;
  List<Anime>? _animes;

  @override
  void initState() {
    super.initState();
    _match();
    _searchController.text = widget.fileName;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _match() async {
    var result = await danmakuGetter.match(widget.uniqueKey, widget.fileName);
    if (result == null) {
      result = await danmakuGetter.getBySearch(
        widget.uniqueKey,
        widget.fileName,
      );
      if (result == null) {
        setState(() {
          _state = _DanmakuSearchState.search;
        });
        if (mounted) showToast(context, title: '未找到弹幕');
        return;
      }
    }
    setState(() {
      _state = _DanmakuSearchState.matchSuccess;
      _message = '${result!.animeTitle}\n${result.episodeTitle}';
    });
  }

  Future<void> _search() async {
    final keyword = _searchController.text.trim();
    if (keyword.isEmpty) {
      return;
    }
    setState(() {
      _state = _DanmakuSearchState.searching;
      _animes = null;
      _errorMessage = null;
    });
    try {
      final animes = await danmakuGetter.danmakuApiUtils.searchEpisodes(
        keyword,
      );
      setState(() {
        _animes = animes;
        _state = _DanmakuSearchState.search;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _state = _DanmakuSearchState.search;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_state == _DanmakuSearchState.matching) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('正在匹配弹幕...', style: context.theme.typography.base),
        ],
      );
    }
    if (_state == _DanmakuSearchState.saving) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('正在保存弹幕...', style: context.theme.typography.base),
        ],
      );
    }
    if (_state == _DanmakuSearchState.matchSuccess) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('自动匹配成功', style: context.theme.typography.xl),
          const SizedBox(height: 16),
          Text(_message, style: context.theme.typography.base),
          const SizedBox(height: 16),
          FButton(
            onPress: () {
              setState(() {
                _state = _DanmakuSearchState.search;
              });
            },
            child: const Text('手动搜索覆盖'),
          ),
          const SizedBox(height: 8),
          FButton(
            onPress: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      );
    }
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
        minHeight: 200,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Text(
                    '搜索弹幕',
                    style: context.theme.typography.xl.copyWith(height: 1),
                    textAlign: TextAlign.start,
                  ),
                ),
                IconButton(
                  icon: const Icon(FIcons.x),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildSearchBar(context),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FAccordion(
                children: _buildBody(),
                style: (style) => style.copyWith(childPadding: EdgeInsets.zero),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FTextField(
            controller: _searchController,
            hint: '输入动画或剧集名称',
            clearable: (value) => value.text.isNotEmpty,
          ),
        ),
        const SizedBox(width: 8),
        FButton.icon(
          onPress: _state == _DanmakuSearchState.searching ? () {} : _search,
          child: _state == _DanmakuSearchState.searching
              ? const SizedBox(
                  width: 25,
                  height: 25,
                  child: FCircularProgress(),
                )
              : Icon(
                  Icons.search,
                  size: 25,
                  color: context.theme.colors.primary,
                ),
        ),
      ],
    );
  }

  List<Widget> _buildBody() {
    if (_errorMessage != null) {
      return [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('错误: $_errorMessage', textAlign: TextAlign.center),
          ),
        ),
      ];
    }
    if (_animes == null) return [];
    if (_animes!.isEmpty) {
      return [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('无结果', textAlign: TextAlign.center),
          ),
        ),
      ];
    }
    return _animes!.map((anime) {
      return FAccordionItem(
        title: Text(anime.animeTitle, textAlign: TextAlign.start),
        child: ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: anime.episodes.length * 2 - 1,
          itemBuilder: (context, index) {
            if (index % 2 == 1) {
              return Divider(height: 1, color: context.theme.colors.border);
            }
            final episode = anime.episodes[(index / 2).round()];
            return FItem(
              style: (style) => style.copyWith(
                margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 0),
                contentStyle: (style) => style.copyWith(
                  padding: EdgeInsetsDirectional.symmetric(
                    vertical: 10,
                    horizontal: 6,
                  ),
                ),
              ),
              title: Text(
                episode.episodeTitle,
                style: context.theme.typography.base,
                maxLines: 2,
              ),
              onPress: () async {
                setState(() {
                  _state = _DanmakuSearchState.saving;
                });
                final result = await danmakuGetter.save(
                  widget.uniqueKey,
                  episode.episodeId,
                  anime.animeId,
                );
                if (mounted) {
                  if (result.isNotEmpty) {
                    showToast(this.context, title: '弹幕保存成功');
                    Navigator.pop(this.context, result);
                  } else {
                    showToast(this.context, title: '弹幕保存失败');
                    setState(() {
                      _state = _DanmakuSearchState.search;
                    });
                  }
                }
              },
            );
          },
        ),
      );
    }).toList();
  }
}
