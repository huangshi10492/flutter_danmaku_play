import 'package:fldanplay/service/configure.dart';
import 'package:fldanplay/widget/settings/settings_section.dart';
import 'package:fldanplay/widget/settings/settings_tile.dart';
import 'package:fldanplay/widget/sys_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:get_it/get_it.dart';
import 'package:signals_flutter/signals_flutter.dart';

class AppearanceSettingsPage extends StatelessWidget {
  const AppearanceSettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final configure = GetIt.I<ConfigureService>();
    return Scaffold(
      appBar: SysAppBar(title: '界面设置'),
      body: Padding(
        padding: context.theme.scaffoldStyle.childPadding,
        child: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              children: [
                SettingsSection(
                  title: '主题',
                  children: [
                    Watch((context) {
                      return SettingsTile.radioTile(
                        title: '主题模式',
                        radioValue: configure.themeMode.value,
                        onRadioChange: (value) {
                          configure.themeMode.value = value;
                        },
                        radioOptions: {'跟随系统': '0', '浅色模式': '1', '深色模式': '2'},
                      );
                    }),
                    Watch((context) {
                      return SettingsTile.radioTile(
                        title: '主题颜色',
                        radioValue: configure.themeColor.value,
                        onRadioChange: (value) {
                          configure.themeColor.value = value;
                        },
                        radioOptions: {
                          '蓝色': 'blue',
                          '灰白色': 'zinc',
                          '深灰色': 'slate',
                          '红色': 'red',
                          '玫瑰色': 'rose',
                          '橙色': 'orange',
                          '绿色': 'green',
                          '黄色': 'yellow',
                          '紫色': 'violet',
                        },
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
