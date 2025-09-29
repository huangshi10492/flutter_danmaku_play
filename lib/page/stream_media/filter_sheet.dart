import 'package:fldanplay/service/stream_media_explorer.dart';
import 'package:fldanplay/widget/icon_switch.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

enum SortKey { name, playDate, communityRating }

class StreamMediaFilterSheet extends StatefulWidget {
  final StreamMediaExplorerService service;
  const StreamMediaFilterSheet({super.key, required this.service});
  @override
  State<StreamMediaFilterSheet> createState() => _StreamMediaFilterSheetState();
}

class _StreamMediaFilterSheetState extends State<StreamMediaFilterSheet> {
  late TextEditingController searchController;
  late TextEditingController yearsController;
  late FSelectTileGroupController<String> statusController;
  late String sortBy;
  late bool sortOrder;

  final sortOptions = {
    '名称': 'SortName',
    '播放日期': 'DatePlayed',
    '社区评分': 'CommunityRating',
  };

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() {
    setState(() {
      searchController = TextEditingController(text: widget.service.searchTerm);
      yearsController = TextEditingController(text: widget.service.years);
      statusController = FSelectTileGroupController<String>();
      sortBy = widget.service.sortBy;
      sortOrder = widget.service.sortOrder;
      statusController.value = widget.service.seriesStatus.split(',').toSet();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    yearsController.dispose();
    super.dispose();
  }

  void _applyFilter() {
    widget.service.searchTerm = searchController.text;
    widget.service.years = yearsController.text;
    widget.service.seriesStatus = statusController.value.join(',');
    widget.service.sortBy = sortBy;
    widget.service.sortOrder = sortOrder;
    widget.service.refresh();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FButton(
              style: FButtonStyle.ghost(),
              onPress: () {
                widget.service.resetFilter();
                init();
              },
              child: const Text('重置'),
            ),
            FButton(onPress: () => _applyFilter(), child: const Text('确定')),
          ],
        ),
        const SizedBox(height: 12),
        FTextField(
          label: Text('搜索'),
          hint: '输入关键词',
          controller: searchController,
        ),
        const SizedBox(height: 12),
        FTextField(
          label: Text('年份'),
          hint: '按,分隔年份，如2000,2001,2002',
          controller: yearsController,
        ),
        const SizedBox(height: 12),
        FSelectTileGroup(
          label: Text(
            '连载状态',
            style: context.theme.typography.sm.copyWith(
              color: context.theme.colors.primary,
            ),
          ),
          selectController: statusController,
          children: [
            FSelectTile(title: const Text('连载中'), value: 'Continuing'),
            FSelectTile(title: const Text('已完结'), value: 'Ended'),
            FSelectTile(title: const Text('未发布'), value: 'Unreleased'),
          ],
        ),
        const SizedBox(height: 12),
        FSelectMenuTile.fromMap(
          sortOptions,
          title: Text('排序类型'),
          initialValue: sortBy,
          details: Text(
            sortOptions.entries.firstWhere((e) => e.value == sortBy).key,
          ),
          onChange:
              (value) => setState(() {
                sortBy = value.first;
              }),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: 8),
                child: IconSwitch(
                  value: sortOrder,
                  onPress: () {
                    setState(() {
                      sortOrder = !sortOrder;
                    });
                  },
                  icon: Icons.arrow_upward,
                  title: '升序',
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 8),
                child: IconSwitch(
                  value: !sortOrder,
                  onPress: () {
                    setState(() {
                      sortOrder = !sortOrder;
                    });
                  },
                  icon: Icons.arrow_downward,
                  title: '降序',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
