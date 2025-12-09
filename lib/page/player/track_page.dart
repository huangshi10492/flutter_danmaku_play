import 'package:fldanplay/service/player/player.dart';
import 'package:fldanplay/utils/video_player_utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';

class TrackPage extends StatefulWidget {
  final VideoPlayerService playerService;
  final bool isAudio;
  const TrackPage({
    super.key,
    required this.playerService,
    required this.isAudio,
  });

  @override
  State<TrackPage> createState() => _TrackPageState();
}

class _TrackPageState extends State<TrackPage> {
  final controller = FSelectTileGroupController.radio(0);

  @override
  void initState() {
    super.initState();
    if (widget.isAudio) {
      final activeTrack = widget.playerService.activeAudioTrack.value;
      controller.update(activeTrack, add: true);
      controller.addUpdateListener((value) {
        if (value.$2) {
          widget.playerService.setActiveAudioTrack(value.$1);
          context.pop();
        }
      });
    } else {
      final activeTrack = widget.playerService.activeSubtitleTrack.value;
      controller.update(activeTrack, add: true);
      controller.addUpdateListener((value) {
        if (value.$2) {
          widget.playerService.setActiveSubtitleTrack(value.$1);
          context.pop();
        }
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _pickExternalSubtitle() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['srt', 'ass', 'ssa', 'vtt', 'sub', 'idx'],
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        await widget.playerService.loadExternalSubtitle(filePath);

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('外部字幕加载成功')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('加载外部字幕失败: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Watch((context) {
            final tracks = widget.isAudio
                ? widget.playerService.audioTracks.value
                : widget.playerService.subtitleTracks.value;
            return FSelectTileGroup<int>(
              selectController: controller,
              children: tracks.map((track) {
                final name = VideoPlayerUtils.trackNameTranslation(
                  track.id,
                  track.title,
                  track.language,
                );
                return FSelectTile(title: Text(name), value: track.index);
              }).toList(),
            );
          }),
          widget.isAudio
              ? const SizedBox()
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    child: ElevatedButton.icon(
                      onPressed: _pickExternalSubtitle,
                      icon: const Icon(Icons.file_upload),
                      label: const Text('导入外部字幕'),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
