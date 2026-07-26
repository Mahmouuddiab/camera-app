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
    final controller = ref.read(cameraNotifierProvider).controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (appState == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (appState == AppLifecycleState.resumed) {
      ref.read(cameraNotifierProvider.notifier).setup();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onTapToFocus(TapUpDetails details, BoxConstraints constraints) {
    final normalized = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    ref.read(cameraNotifierProvider.notifier).onTapToFocus(normalized);
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
            onTapToFocus: _onTapToFocus,
          ),
        },
      ),
    );
  }
}

class _ReadyView extends StatelessWidget {
  final CameraState state;
  final CameraNotifier notifier;
  final void Function(TapUpDetails, BoxConstraints) onTapToFocus;

  const _ReadyView({
    required this.state,
    required this.notifier,
    required this.onTapToFocus,
  });

  @override
  Widget build(BuildContext context) {
    final controller = state.controller;
    if (controller == null || !controller.value.isInitialized) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        TopControlsBar(
          flashMode: state.flashMode,
          onFlashTap: notifier.cycleFlash,
          onGalleryTap: () {},
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                onScaleStart: (_) => notifier.onScaleStart(),
                onScaleUpdate:
                    (details) => notifier.onScaleUpdate(details.scale),
                onTapUp: (details) => onTapToFocus(details, constraints),
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
                                state.filter.matrix,
                              ),
                              child: CameraPreview(controller),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (state.isRecording)
                      Positioned(
                        top: 16,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: RecordingTimerWidget(elapsed: state.elapsed),
                        ),
                      ),
                    Positioned(
                      bottom: 24,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:
                        [1.0, 2.0, 3.0].map((zoom) {
                          final isSelected =
                              (state.zoomLevel - zoom).abs() < 0.2;
                          return GestureDetector(
                            onTap: () => notifier.setZoomDirect(zoom),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color:
                                isSelected
                                    ? Colors.black.withOpacity(0.6)
                                    : Colors.black.withOpacity(0.3),
                                shape: BoxShape.circle,
                                border:
                                isSelected
                                    ? Border.all(
                                  color: AppColors.accentPink,
                                  width: 2,
                                )
                                    : null,
                              ),
                              child: Text(
                                AppStrings.zoomLabel(zoom.toInt()),
                                style: TextStyle(
                                  color:
                                  isSelected
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
                    if (state.showZoomIndicator)
                      Positioned(
                        bottom: 70,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: ZoomIndicator(zoom: state.zoomLevel),
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
                selected: state.filter,
                onSelected: notifier.selectFilter,
              ),
              const SizedBox(height: 12),
              if (!state.isRecording)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ModeButton(
                      label: AppStrings.photoMode,
                      isSelected: state.captureMode == CaptureMode.photo,
                      onTap: () => notifier.setCaptureMode(CaptureMode.photo),
                    ),
                    const SizedBox(width: 24),
                    _ModeButton(
                      label: AppStrings.videoMode,
                      isSelected: state.captureMode == CaptureMode.video,
                      onTap: () => notifier.setCaptureMode(CaptureMode.video),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              BottomControlsBar(
                isRecording: state.isRecording,
                onRecordTap: () => notifier.onCaptureTap(context),
                onSwitchCameraTap: notifier.switchCamera,
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