import 'package:fldanplay/theme/text_field_style.dart';
import 'package:forui/forui.dart';

FThemeData getLightTheme(String theme) {
  switch (theme) {
    case 'blue':
      return FThemes.blue.light.copyWith(
        textFieldStyle: textFieldStyle(
          colors: FThemes.blue.light.colors,
          typography: FThemes.blue.light.typography,
          style: FThemes.blue.light.style,
        ),
      );
    case 'zinc':
      return FThemes.zinc.light.copyWith(
        textFieldStyle: textFieldStyle(
          colors: FThemes.zinc.light.colors,
          typography: FThemes.zinc.light.typography,
          style: FThemes.zinc.light.style,
        ),
      );
    case 'slate':
      return FThemes.slate.light.copyWith(
        textFieldStyle: textFieldStyle(
          colors: FThemes.slate.light.colors,
          typography: FThemes.slate.light.typography,
          style: FThemes.slate.light.style,
        ),
      );
    case 'red':
      return FThemes.red.light.copyWith(
        textFieldStyle: textFieldStyle(
          colors: FThemes.red.light.colors,
          typography: FThemes.red.light.typography,
          style: FThemes.red.light.style,
        ),
      );
    case 'rose':
      return FThemes.rose.light.copyWith(
        textFieldStyle: textFieldStyle(
          colors: FThemes.rose.light.colors,
          typography: FThemes.rose.light.typography,
          style: FThemes.rose.light.style,
        ),
      );
    case 'orange':
      return FThemes.orange.light.copyWith(
        textFieldStyle: textFieldStyle(
          colors: FThemes.orange.light.colors,
          typography: FThemes.orange.light.typography,
          style: FThemes.orange.light.style,
        ),
      );
    case 'green':
      return FThemes.green.light.copyWith(
        textFieldStyle: textFieldStyle(
          colors: FThemes.green.light.colors,
          typography: FThemes.green.light.typography,
          style: FThemes.green.light.style,
        ),
      );
    case 'yellow':
      return FThemes.yellow.light.copyWith(
        textFieldStyle: textFieldStyle(
          colors: FThemes.yellow.light.colors,
          typography: FThemes.yellow.light.typography,
          style: FThemes.yellow.light.style,
        ),
      );
    case 'violet':
      return FThemes.violet.light.copyWith(
        textFieldStyle: textFieldStyle(
          colors: FThemes.violet.light.colors,
          typography: FThemes.violet.light.typography,
          style: FThemes.violet.light.style,
        ),
      );
    default:
      return FThemes.blue.light.copyWith(
        textFieldStyle: textFieldStyle(
          colors: FThemes.blue.light.colors,
          typography: FThemes.blue.light.typography,
          style: FThemes.blue.light.style,
        ),
      );
  }
}

FThemeData getDarkTheme(String theme) {
  switch (theme) {
    case 'blue':
      return FThemes.blue.dark.copyWith(
        textFieldStyle: textFieldStyle(
          colors: FThemes.blue.dark.colors,
          typography: FThemes.blue.dark.typography,
          style: FThemes.blue.dark.style,
        ),
      );
    case 'zinc':
      return FThemes.zinc.dark.copyWith(
        textFieldStyle: textFieldStyle(
          colors: FThemes.zinc.dark.colors,
          typography: FThemes.zinc.dark.typography,
          style: FThemes.zinc.dark.style,
        ),
      );
    case 'slate':
      return FThemes.slate.dark.copyWith(
        textFieldStyle: textFieldStyle(
          colors: FThemes.slate.dark.colors,
          typography: FThemes.slate.dark.typography,
          style: FThemes.slate.dark.style,
        ),
      );
    case 'red':
      return FThemes.red.dark.copyWith(
        textFieldStyle: textFieldStyle(
          colors: FThemes.red.dark.colors,
          typography: FThemes.red.dark.typography,
          style: FThemes.red.dark.style,
        ),
      );
    case 'rose':
      return FThemes.rose.dark.copyWith(
        textFieldStyle: textFieldStyle(
          colors: FThemes.rose.dark.colors,
          typography: FThemes.rose.dark.typography,
          style: FThemes.rose.dark.style,
        ),
      );
    case 'orange':
      return FThemes.orange.dark.copyWith(
        textFieldStyle: textFieldStyle(
          colors: FThemes.orange.dark.colors,
          typography: FThemes.orange.dark.typography,
          style: FThemes.orange.dark.style,
        ),
      );
    case 'green':
      return FThemes.green.dark.copyWith(
        textFieldStyle: textFieldStyle(
          colors: FThemes.green.dark.colors,
          typography: FThemes.green.dark.typography,
          style: FThemes.green.dark.style,
        ),
      );
    case 'yellow':
      return FThemes.yellow.dark.copyWith(
        textFieldStyle: textFieldStyle(
          colors: FThemes.yellow.dark.colors,
          typography: FThemes.yellow.dark.typography,
          style: FThemes.yellow.dark.style,
        ),
      );
    case 'violet':
      return FThemes.violet.dark.copyWith(
        textFieldStyle: textFieldStyle(
          colors: FThemes.violet.dark.colors,
          typography: FThemes.violet.dark.typography,
          style: FThemes.violet.dark.style,
        ),
      );
    default:
      return FThemes.blue.dark.copyWith(
        textFieldStyle: textFieldStyle(
          colors: FThemes.blue.dark.colors,
          typography: FThemes.blue.dark.typography,
          style: FThemes.blue.dark.style,
        ),
      );
  }
}

FItemGroupStyle rootItemGroupStyle(FItemGroupStyle style) {
  return style.copyWith(
    itemStyle:
        (style) => style.copyWith(
          contentStyle:
              (style) => style.copyWith(
                titleTextStyle: FWidgetStateMap.all(
                  style.titleTextStyle
                      .resolve({})
                      .copyWith(fontSize: 18, height: 1.75),
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
    itemStyle:
        (style) => style.copyWith(
          contentStyle:
              (style) => style.copyWith(
                titleTextStyle: FWidgetStateMap.all(
                  style.titleTextStyle
                      .resolve({})
                      .copyWith(fontSize: 16, height: 1.5),
                ),
                prefixIconStyle: FWidgetStateMap.all(
                  style.prefixIconStyle.resolve({}).copyWith(size: 28),
                ),
              ),
        ),
  );
}
