import 'package:fldanplay/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

FTextFieldStyle textFieldStyle(FTextFieldStyle style, FColors colors) {
  final disabledTextStyle = style.contentTextStyle.resolve({
    WidgetState.disabled,
  });
  final anyTextStyle = style.contentTextStyle
      .resolve({})
      .copyWith(color: colors.foreground);
  return style.copyWith(
    contentTextStyle: FWidgetStateMap({
      WidgetState.disabled: disabledTextStyle,
      WidgetState.any: anyTextStyle,
    }),
  );
}

FThemeData getTheme(String theme, bool isDark) {
  late FColors colors;
  if (isDark) {
    switch (theme) {
      case 'blue':
        colors = FThemes.blue.dark.colors;
      case 'zinc':
        colors = FThemes.zinc.dark.colors;
      case 'slate':
        colors = FThemes.slate.dark.colors;
      case 'red':
        colors = FThemes.red.dark.colors;
      case 'rose':
        colors = FThemes.rose.dark.colors;
      case 'orange':
        colors = FThemes.orange.dark.colors;
      case 'green':
        colors = FThemes.green.dark.colors;
      case 'yellow':
        colors = FThemes.yellow.dark.colors;
      case 'violet':
        colors = FThemes.violet.dark.colors;
      default:
        colors = FThemes.blue.dark.colors;
    }
  } else {
    switch (theme) {
      case 'blue':
        colors = FThemes.blue.light.colors;
      case 'zinc':
        colors = FThemes.zinc.light.colors;
      case 'slate':
        colors = FThemes.slate.light.colors;
      case 'red':
        colors = FThemes.red.light.colors;
      case 'rose':
        colors = FThemes.rose.light.colors;
      case 'orange':
        colors = FThemes.orange.light.colors;
      case 'green':
        colors = FThemes.green.light.colors;
      case 'yellow':
        colors = FThemes.yellow.light.colors;
      case 'violet':
        colors = FThemes.violet.light.colors;
      default:
        colors = FThemes.blue.light.colors;
    }
  }
  return FThemeData(
    colors: colors,
    typography: FTypography.inherit(
      colors: colors,
      defaultFontFamily: Utils.font('packages/forui/Inter')!,
    ),
  ).copyWith(textFieldStyle: (style) => textFieldStyle(style, colors));
}

FItemGroupStyle rootItemGroupStyle(FItemGroupStyle style) {
  return style.copyWith(
    itemStyle: (style) => style.copyWith(
      contentStyle: (style) => style.copyWith(
        titleTextStyle: FWidgetStateMap.all(
          style.titleTextStyle.resolve({}).copyWith(fontSize: 18, height: 1.75),
        ),
        prefixIconStyle: FWidgetStateMap.all(
          style.prefixIconStyle.resolve({}).copyWith(size: 32),
        ),
      ),
    ),
  );
}

FItemGroupStyle settingsItemGroupStyle(FItemGroupStyle style) {
  return style.copyWith(
    itemStyle: (style) => style.copyWith(
      contentStyle: (style) => style.copyWith(
        titleTextStyle: FWidgetStateMap.all(
          style.titleTextStyle.resolve({}).copyWith(fontSize: 16, height: 1.5),
        ),
        prefixIconStyle: FWidgetStateMap.all(
          style.prefixIconStyle.resolve({}).copyWith(size: 28),
        ),
      ),
    ),
  );
}
