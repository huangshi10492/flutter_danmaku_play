import 'package:fldanplay/theme/tile_group_style.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class RadioSettingsSection extends StatelessWidget {
  const RadioSettingsSection({
    super.key,
    this.title,
    required this.options,
    required this.value,
    required this.onChange,
  });
  final String? title;
  final Map<String, String> options;
  final String value;
  final void Function(String) onChange;

  @override
  Widget build(BuildContext context) {
    return FSelectTileGroup<String>(
      style: tileGroupStyle(
        colors: context.theme.colors,
        typography: context.theme.typography,
        style: context.theme.style,
      ),
      selectController: FSelectTileGroupController.radio(value),
      children:
          options.entries
              .map(
                (e) => FSelectTile(
                  title: Text(e.key),
                  subtitle: Text(e.value),
                  value: e.key,
                ),
              )
              .toList(),
      onChange: (value) => onChange(value.first),
    );
  }
}
