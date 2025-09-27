import 'package:flutter/material.dart';

import 'package:forui/forui.dart';

FTileStyle tileStyle({
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
    bounceTween: FTappableStyle.noBounceTween,
    pressedEnterDuration: Duration.zero,
    pressedExitDuration: const Duration(milliseconds: 25),
  ),
  focusedOutlineStyle: style.focusedOutlineStyle,
  margin: EdgeInsets.zero,
);
