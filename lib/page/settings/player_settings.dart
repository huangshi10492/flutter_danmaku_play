import 'package:fldanplay/service/configure.dart';
import 'package:fldanplay/widget/settings/radio_settings_section.dart';
import 'package:fldanplay/widget/settings/settings_scaffold.dart';
import 'package:fldanplay/widget/settings/settings_section.dart';
import 'package:fldanplay/widget/settings/settings_tile.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';

class PlayerSettingsPage extends StatelessWidget {
  const PlayerSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final configure = GetIt.I<ConfigureService>();
    return SettingsScaffold(
      title: '播放器设置',
      child: Watch((context) {
        return Column(
          children: [
            SettingsSection(
              title: '播放',
              children: [
                SettingsTile.sliderTile(
                  title: '默认播放速度',
                  silderValue: configure.defaultPlaySpeed.value,
                  silderMin: 0.25,
                  silderMax: 4,
                  onSilderChange: (value) {
                    configure.defaultPlaySpeed.value = value;
                  },
                  details:
                      '${configure.defaultPlaySpeed.value.toStringAsFixed(2)}x',
                  silderDivisions: 15,
                ),
                SettingsTile.sliderTile(
                  title: '长按加速播放速度',
                  silderValue: configure.doublePlaySpeed.value,
                  silderMin: 1,
                  silderMax: 8,
                  onSilderChange: (value) {
                    configure.doublePlaySpeed.value = value;
                  },
                  details:
                      '${configure.doublePlaySpeed.value.toStringAsFixed(2)}x',
                  silderDivisions: 28,
                ),
                SettingsTile.switchTile(
                  title: '优先使用AudioTrack输出音频',
                  subtitle: '关闭则优先使用OpenSL ES输出音频',
                  switchValue: configure.audioTrack.value,
                  onBoolChange: (value) {
                    configure.audioTrack.value = value;
                  },
                ),
              ],
            ),
            SettingsSection(
              title: '语言',
              children: [
                SettingsTile.radioTile(
                  title: '自动为字幕和弹幕选择语言',
                  onRadioChange: (value) {
                    configure.autoLanguage.value = int.parse(value);
                  },
                  radioOptions: {'关闭': '0', '中文简体': '1', '中文繁体': '2'},
                  radioValue: configure.autoLanguage.value.toString(),
                ),
                SettingsTile.switchTile(
                  title: '自动为音频选择日语',
                  switchValue: configure.autoAudioLanguage.value,
                  onBoolChange: (value) {
                    configure.autoAudioLanguage.value = value;
                  },
                ),
              ],
            ),
            SettingsSection(
              title: '解码',
              children: [
                SettingsTile.switchTile(
                  title: '启用硬解',
                  switchValue: configure.hardwareDecoderEnable.value,
                  onBoolChange: (value) {
                    configure.hardwareDecoderEnable.value = value;
                  },
                ),
                SettingsTile.navigationTile(
                  title: '硬件解码器',
                  subtitle: configure.hardwareDecoder.value,
                  onPress: () {
                    context.push('/settings/player/hardware-decoder');
                  },
                ),
              ],
            ),
            SettingsSection(
              title: '其他',
              children: [
                SettingsTile.switchTile(
                  title: '低内存模式',
                  subtitle: '默认缓存500MB，开启后缓存25MB，适用于低内存设备',
                  switchValue: configure.lowMemoryMode.value,
                  onBoolChange: (value) {
                    configure.lowMemoryMode.value = value;
                  },
                ),
                SettingsTile.switchTile(
                  title: '播放器调试模式',
                  switchValue: configure.playerDebugMode.value,
                  onBoolChange: (value) {
                    configure.playerDebugMode.value = value;
                  },
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}

class HardwareDecoderPage extends StatelessWidget {
  const HardwareDecoderPage({super.key});

  // 可选硬件解码器
  static const Map<String, String> hardwareDecodersList = {
    'auto': '启用任意可用解码器',
    'auto-safe': '启用最佳解码器',
    'auto-copy': '启用带拷贝功能的最佳解码器',
    'd3d11va': 'DirectX11 (windows8 及以上)',
    'd3d11va-copy': 'DirectX11 (windows8 及以上) (非直通)',
    'videotoolbox': 'VideoToolbox (macOS / iOS)',
    'videotoolbox-copy': 'VideoToolbox (macOS / iOS) (非直通)',
    'vaapi': 'VAAPI (Linux)',
    'vaapi-copy': 'VAAPI (Linux) (非直通)',
    'nvdec': 'NVDEC (NVIDIA独占)',
    'nvdec-copy': 'NVDEC (NVIDIA独占) (非直通)',
    'drm': 'DRM (Linux)',
    'drm-copy': 'DRM (Linux) (非直通)',
    'vulkan': 'Vulkan (全平台) (实验性)',
    'vulkan-copy': 'Vulkan (全平台) (实验性) (非直通)',
    'dxva2': 'DXVA2 (Windows7 及以上)',
    'dxva2-copy': 'DXVA2 (Windows7 及以上) (非直通)',
    'vdpau': 'VDPAU (Linux)',
    'vdpau-copy': 'VDPAU (Linux) (非直通)',
    'mediacodec': 'MediaCodec (Android)',
    'mediacodec-copy': 'MediaCodec (Android) (非直通)',
    'cuda': 'CUDA (NVIDIA独占) (过时)',
    'cuda-copy': 'CUDA (NVIDIA独占) (过时) (非直通)',
    'crystalhd': 'CrystalHD (全平台) (过时)',
    'rkmpp': 'Rockchip MPP (仅部分Rockchip芯片)',
  };

  @override
  Widget build(BuildContext context) {
    final configure = GetIt.I<ConfigureService>();
    return SettingsScaffold(
      title: '硬件解码器',
      child: Watch((context) {
        return RadioSettingsSection(
          options: hardwareDecodersList,
          value: configure.hardwareDecoder.value,
          onChange: (value) {
            configure.hardwareDecoder.value = value;
          },
        );
      }),
    );
  }
}
