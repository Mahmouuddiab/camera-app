import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_camera_app/core/utils/app_strings.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/filter_type.dart';

class VideoPreviewScreen extends StatefulWidget {
  final String videoPath;
  final FilterType appliedFilter;

  const VideoPreviewScreen({
    super.key,
    required this.videoPath,
    required this.appliedFilter,
  });

  @override
  State<VideoPreviewScreen> createState() => _VideoPreviewScreenState();
}

class _VideoPreviewScreenState extends State<VideoPreviewScreen> {
  late final VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() => _initialized = true);
        _controller
          ..setLooping(true)
          ..play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Text(
                    AppStrings.previewTitle,
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: _initialized
                    ? GestureDetector(
                  onTap: () {
                    setState(() {
                      _controller.value.isPlaying
                          ? _controller.pause()
                          : _controller.play();
                    });
                  },
                  child: ColorFiltered(
                    colorFilter:
                    ColorFilter.matrix(widget.appliedFilter.matrix),
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                )
                    : const CircularProgressIndicator(
                    color: AppColors.accentPink),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: const Text(AppStrings.retakeButton,
                        style: TextStyle(color: Colors.white)),
                  ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accentPink,
                    ),
                    onPressed: () => Navigator.of(context)
                        .popUntil((route) => route.isFirst),
                    icon: const Icon(Icons.check),
                    label: const Text(AppStrings.doneButton),
                  ),
                ],
              ),
            ),
            Text(
              AppStrings.savedToPath(widget.videoPath),
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 11),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}