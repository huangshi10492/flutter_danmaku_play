import 'package:flutter/material.dart';

import 'package:forui/forui.dart';

FSelectMenuTileStyle selectMenuTileStyle({
  required FColors colors,
  required FTypography typography,
  required FStyle style,
}) {
  final groupStyle = _tileGroupStyle(
    colors: colors,
    style: style,
    typography: typography,
  );
  return FSelectMenuTileStyle(
    menuStyle: _popoverMenuStyle(
      colors: colors,
      style: style,
      typography: typography,
    ),
    tileStyle: _tileStyle(colors: colors, typography: typography, style: style),
    labelTextStyle: groupStyle.labelTextStyle,
    descriptionTextStyle: groupStyle.descriptionTextStyle,
    errorTextStyle: groupStyle.errorTextStyle,
    labelPadding: groupStyle.labelPadding,
    descriptionPadding: groupStyle.descriptionPadding,
    errorPadding: groupStyle.errorPadding,
  );
}

FPopoverMenuStyle _popoverMenuStyle({
  required FColors colors,
  required FStyle style,
  required FTypography typography,
}) => FPopoverMenuStyle.inherit(
  colors: colors,
  style: style,
  typography: typography,
);

FTileGroupStyle _tileGroupStyle({
  required FColors colors,
  required FTypography typography,
  required FStyle style,
}) {
  final tileStyle = _tileStyle(
    colors: colors,
    typography: typography,
    style: style,
  );
  return FTileGroupStyle(
    decoration: BoxDecoration(),
    tileStyle: tileStyle.copyWith(
      decoration: tileStyle.decoration.map(
        (d) =>
            d == null
                ? null
                : BoxDecoration(
                  color: d.color,
                  image: d.image,
                  boxShadow: d.boxShadow,
                  gradient: d.gradient,
                  backgroundBlendMode: d.backgroundBlendMode,
                  shape: d.shape,
                ),
      ),
    ),
    dividerColor: FWidgetStateMap.all(colors.border),
    dividerWidth: style.borderWidth,
    labelTextStyle: FWidgetStateMap({
      WidgetState.error: typography.base.copyWith(
        color:
            style.formFieldStyle.labelTextStyle.maybeResolve({})?.color ??
            colors.primary,
        fontWeight: FontWeight.w600,
      ),
      WidgetState.disabled: typography.base.copyWith(
        color:
            style.formFieldStyle.labelTextStyle.maybeResolve({
              WidgetState.disabled,
            })?.color ??
            colors.disable(colors.primary),
        fontWeight: FontWeight.w600,
      ),
      WidgetState.any: typography.base.copyWith(
        color:
            style.formFieldStyle.labelTextStyle.maybeResolve({})?.color ??
            colors.primary,
        fontWeight: FontWeight.w600,
      ),
    }),
    descriptionTextStyle: style.formFieldStyle.descriptionTextStyle.map(
      (s) => typography.xs.copyWith(color: s.color),
    ),
    errorTextStyle: typography.xs.copyWith(
      color: style.formFieldStyle.errorTextStyle.color,
    ),
    labelPadding: const EdgeInsets.symmetric(vertical: 7.7),
    descriptionPadding: const EdgeInsets.only(top: 7.5),
    errorPadding: const EdgeInsets.only(top: 5),
    childPadding: EdgeInsets.zero,
  );
}

FTileStyle _tileStyle({
  required FColors colors,
  required FTypography typography,
  required FStyle style,
}) => FTileStyle(
  backgroundColor: FWidgetStateMap.all(Colors.transparent),
  decoration: FWidgetStateMap({
    WidgetState.disabled: BoxDecoration(
      color: colors.disable(colors.secondary),
      borderRadius: style.borderRadius,
    ),
    WidgetState.hovered | WidgetState.pressed: BoxDecoration(
      color: colors.secondary,
      borderRadius: style.borderRadius,
    ),
    WidgetState.any: BoxDecoration(
      color: Colors.transparent,
      borderRadius: style.borderRadius,
    ),
  }),
  contentStyle: FItemContentStyle(
    padding: const EdgeInsetsDirectional.fromSTEB(15, 13, 10, 13),
    prefixIconStyle: FWidgetStateMap({
      WidgetState.disabled: IconThemeData(
        color: colors.disable(colors.primary),
        size: 18,
      ),
      WidgetState.any: IconThemeData(color: colors.primary, size: 18),
    }),
    titleTextStyle: FWidgetStateMap({
      WidgetState.disabled: typography.base.copyWith(
        color: colors.disable(colors.primary),
      ),
      WidgetState.any: typography.base,
    }),
    subtitleTextStyle: FWidgetStateMap({
      WidgetState.disabled: typography.xs.copyWith(
        color: colors.disable(colors.mutedForeground),
      ),
      WidgetState.any: typography.xs.copyWith(color: colors.mutedForeground),
    }),
    detailsTextStyle: FWidgetStateMap({
      WidgetState.disabled: typography.base.copyWith(
        color: colors.disable(colors.mutedForeground),
      ),
      WidgetState.any: typography.base.copyWith(color: colors.mutedForeground),
    }),
    suffixIconStyle: FWidgetStateMap({
      WidgetState.disabled: IconThemeData(
        color: colors.disable(colors.mutedForeground),
        size: 18,
      ),
      WidgetState.any: IconThemeData(color: colors.mutedForeground, size: 18),
    }),
  ),
  rawItemContentStyle: FRawItemContentStyle(
    padding: const EdgeInsetsDirectional.fromSTEB(15, 13, 10, 13),
    prefixIconStyle: FWidgetStateMap({
      WidgetState.disabled: IconThemeData(
        color: colors.disable(colors.primary),
        size: 18,
      ),
      WidgetState.any: IconThemeData(color: colors.primary, size: 18),
    }),
    childTextStyle: FWidgetStateMap({
      WidgetState.disabled: typography.base.copyWith(
        color: colors.disable(colors.primary),
      ),
      WidgetState.any: typography.base,
    }),
  ),
  tappableStyle: style.tappableStyle.copyWith(
    motion: FTappableMotion.none.call,
    pressedEnterDuration: Duration.zero,
    pressedExitDuration: const Duration(milliseconds: 25),
  ),
  focusedOutlineStyle: style.focusedOutlineStyle,
  margin: EdgeInsets.zero,
);
