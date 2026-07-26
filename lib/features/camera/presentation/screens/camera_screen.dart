import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_camera_app/core/utils/app_strings.dart';
import 'package:flutter_camera_app/features/camera/presentation/riverpod/camera_notifier.dart';
import 'package:flutter_camera_app/features/camera/presentation/riverpod/camera_providers.dart';
import 'package:flutter_camera_app/features/camera/presentation/riverpod/camera_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/permission_helper.dart';
import '../widgets/camera_controls.dart';
import '../widgets/filter_selector.dart';
import '../widgets/recording_timer_widget.dart';
import '../widgets/zoom_slider.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cameraNotifierProvider.notifier).setup();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState appState) {
    final state = ref.read(cameraNotifierProvider);
    final controller = state.controller;

    if (appState == AppLifecycleState.inactive ||
        appState == AppLifecycleState.paused) {
      if (controller != null && controller.value.isInitialized) {
        controller.dispose();
      }
    } else if (appState == AppLifecycleState.resumed) {
      ref.read(cameraNotifierProvider.notifier).setup();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cameraNotifierProvider);
    final notifier = ref.read(cameraNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: switch (state.status) {
          CameraLifecycleStatus.loading => const Center(
            child: CircularProgressIndicator(color: AppColors.accentPink),
          ),
          CameraLifecycleStatus.permissionDenied => _PermissionDeniedView(
            onOpenSettings: PermissionHelper.openSettings,
            onRetry: notifier.setup,
          ),
          CameraLifecycleStatus.error => _ErrorView(
            message: state.errorMessage ?? AppStrings.defaultError,
            onRetry: notifier.setup,
          ),
          CameraLifecycleStatus.ready => _ReadyView(
            state: state,
            notifier: notifier,
          ),
        },
      ),
    );
  }
}

class _ReadyView extends StatefulWidget {
  final CameraState state;
  final CameraNotifier notifier;

  const _ReadyView({
    required this.state,
    required this.notifier,
  });

  @override
  State<_ReadyView> createState() => _ReadyViewState();
}

class _ReadyViewState extends State<_ReadyView> {
  Offset? _focusPoint;

  void _handleTapToFocus(TapUpDetails details, BoxConstraints constraints) {
    final point = details.localPosition;
    setState(() {
      _focusPoint = point;
    });

    final normalized = Offset(
      point.dx / constraints.maxWidth,
      point.dy / constraints.maxHeight,
    );
    widget.notifier.onTapToFocus(normalized);

    // Hide focus ring after 1.5 seconds
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _focusPoint = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.state.controller;
    if (controller == null || !controller.value.isInitialized) {
      return const SizedBox.shrink();
    }

    final isFrontCamera =
        widget.state.cameras[widget.state.cameraIndex].lensDirection ==
            CameraLensDirection.front;

    return Column(
      children: [
        TopControlsBar(
          flashMode: widget.state.flashMode,
          onFlashTap: isFrontCamera ? () {} : widget.notifier.cycleFlash,
          onGalleryTap: () {},
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                onScaleStart: (_) => widget.notifier.onScaleStart(),
                onScaleUpdate: (details) =>
                    widget.notifier.onScaleUpdate(details.scale),
                onTapUp: (details) => _handleTapToFocus(details, constraints),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      child: OverflowBox(
                        alignment: Alignment.center,
                        maxWidth: double.infinity,
                        maxHeight: double.infinity,
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: controller.value.previewSize?.height ?? 0,
                            height: controller.value.previewSize?.width ?? 0,
                            child: ColorFiltered(
                              colorFilter: ColorFilter.matrix(
                                widget.state.filter.matrix,
                              ),
                              child: CameraPreview(controller),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Tap to Focus Ring Overlay
                    if (_focusPoint != null)
                      Positioned(
                        left: _focusPoint!.dx - 25,
                        top: _focusPoint!.dy - 25,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.accentPink,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    if (widget.state.isRecording)
                      Positioned(
                        top: 16,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: RecordingTimerWidget(
                            elapsed: widget.state.elapsed,
                          ),
                        ),
                      ),
                    Positioned(
                      bottom: 24,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [1.0, 2.0, 3.0].map((zoom) {
                          final isSelected =
                              (widget.state.zoomLevel - zoom).abs() < 0.2;
                          return GestureDetector(
                            onTap: () => widget.notifier.setZoomDirect(zoom),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.black.withValues(alpha: 0.6)
                                    : Colors.black.withValues(alpha: 0.3),
                                shape: BoxShape.circle,
                                border: isSelected
                                    ? Border.all(
                                  color: AppColors.accentPink,
                                  width: 2,
                                )
                                    : null,
                              ),
                              child: Text(
                                AppStrings.zoomLabel(zoom.toInt()),
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    if (widget.state.showZoomIndicator)
                      Positioned(
                        bottom: 70,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: ZoomIndicator(zoom: widget.state.zoomLevel),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.only(top: 12, bottom: 20),
          child: Column(
            children: [
              FilterSelector(
                selected: widget.state.filter,
                onSelected: widget.notifier.selectFilter,
              ),
              const SizedBox(height: 12),
              if (!widget.state.isRecording)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ModeButton(
                      label: AppStrings.photoMode,
                      isSelected: widget.state.captureMode == CaptureMode.photo,
                      onTap: () =>
                          widget.notifier.setCaptureMode(CaptureMode.photo),
                    ),
                    const SizedBox(width: 24),
                    _ModeButton(
                      label: AppStrings.videoMode,
                      isSelected: widget.state.captureMode == CaptureMode.video,
                      onTap: () =>
                          widget.notifier.setCaptureMode(CaptureMode.video),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              BottomControlsBar(
                isRecording: widget.state.isRecording,
                onRecordTap: () => widget.notifier.onCaptureTap(context),
                onSwitchCameraTap: widget.notifier.switchCamera,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 200),
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white54,
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          letterSpacing: 1.1,
        ),
        child: Text(label),
      ),
    );
  }
}

class _PermissionDeniedView extends StatelessWidget {
  final Future<void> Function() onOpenSettings;
  final Future<void> Function() onRetry;

  const _PermissionDeniedView({
    required this.onOpenSettings,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.no_photography_outlined,
              color: AppColors.textSecondary,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              AppStrings.permissionDeniedMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: onRetry,
              child: const Text(AppStrings.tryAgain),
            ),
            TextButton(
              onPressed: onOpenSettings,
              child: const Text(AppStrings.openSettings),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: onRetry,
              child: const Text(AppStrings.retry),
            ),
          ],
        ),
      ),
    );
  }
}