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

FThemeData getLightTheme(String theme) {
  switch (theme) {
    case 'blue':
      return FThemes.blue.light.copyWith(
        textFieldStyle: (style) =>
            textFieldStyle(style, FThemes.blue.light.colors),
      );
    case 'zinc':
      return FThemes.zinc.light.copyWith(
        textFieldStyle: (style) =>
            textFieldStyle(style, FThemes.zinc.light.colors),
      );
    case 'slate':
      return FThemes.slate.light.copyWith(
        textFieldStyle: (style) =>
            textFieldStyle(style, FThemes.slate.light.colors),
      );
    case 'red':
      return FThemes.red.light.copyWith(
        textFieldStyle: (style) =>
            textFieldStyle(style, FThemes.red.light.colors),
      );
    case 'rose':
      return FThemes.rose.light.copyWith(
        textFieldStyle: (style) =>
            textFieldStyle(style, FThemes.rose.light.colors),
      );
    case 'orange':
      return FThemes.orange.light.copyWith(
        textFieldStyle: (style) =>
            textFieldStyle(style, FThemes.orange.light.colors),
      );
    case 'green':
      return FThemes.green.light.copyWith(
        textFieldStyle: (style) =>
            textFieldStyle(style, FThemes.green.light.colors),
      );
    case 'yellow':
      return FThemes.yellow.light.copyWith(
        textFieldStyle: (style) =>
            textFieldStyle(style, FThemes.yellow.light.colors),
      );
    case 'violet':
      return FThemes.violet.light.copyWith(
        textFieldStyle: (style) =>
            textFieldStyle(style, FThemes.violet.light.colors),
      );
    default:
      return FThemes.blue.light.copyWith(
        textFieldStyle: (style) =>
            textFieldStyle(style, FThemes.blue.light.colors),
      );
  }
}

FThemeData getDarkTheme(String theme) {
  switch (theme) {
    case 'blue':
      return FThemes.blue.dark.copyWith(
        textFieldStyle: (style) =>
            textFieldStyle(style, FThemes.blue.dark.colors),
      );
    case 'zinc':
      return FThemes.zinc.dark.copyWith(
        textFieldStyle: (style) =>
            textFieldStyle(style, FThemes.zinc.dark.colors),
      );
    case 'slate':
      return FThemes.slate.dark.copyWith(
        textFieldStyle: (style) =>
            textFieldStyle(style, FThemes.slate.dark.colors),
      );
    case 'red':
      return FThemes.red.dark.copyWith(
        textFieldStyle: (style) =>
            textFieldStyle(style, FThemes.red.dark.colors),
      );
    case 'rose':
      return FThemes.rose.dark.copyWith(
        textFieldStyle: (style) =>
            textFieldStyle(style, FThemes.rose.dark.colors),
      );
    case 'orange':
      return FThemes.orange.dark.copyWith(
        textFieldStyle: (style) =>
            textFieldStyle(style, FThemes.orange.dark.colors),
      );
    case 'green':
      return FThemes.green.dark.copyWith(
        textFieldStyle: (style) =>
            textFieldStyle(style, FThemes.green.dark.colors),
      );
    case 'yellow':
      return FThemes.yellow.dark.copyWith(
        textFieldStyle: (style) =>
            textFieldStyle(style, FThemes.yellow.dark.colors),
      );
    case 'violet':
      return FThemes.violet.dark.copyWith(
        textFieldStyle: (style) =>
            textFieldStyle(style, FThemes.violet.dark.colors),
      );
    default:
      return FThemes.blue.dark.copyWith(
        textFieldStyle: (style) =>
            textFieldStyle(style, FThemes.blue.dark.colors),
      );
  }
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
