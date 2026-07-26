import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_camera_app/core/utils/app_strings.dart';
import 'package:flutter_camera_app/features/camera/presentation/screens/video_preview_screen.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/permission_helper.dart';
import '../../domain/entities/filter_type.dart';
import '../../domain/repositories/camera_repository.dart';
import '../../domain/usecases/get_available_cameras_usecase.dart';
import '../../domain/usecases/initialize_camera_usecase.dart';
import '../../domain/usecases/save_photo_usecase.dart';
import '../../domain/usecases/save_video_usecase.dart';
import '../../domain/usecases/set_flash_mode_usecase.dart';
import '../../domain/usecases/set_focus_point_usecase.dart';
import '../../domain/usecases/set_zoom_level_usecase.dart';
import '../../domain/usecases/start_recording_usecase.dart';
import '../../domain/usecases/stop_recording_usecase.dart';
import 'camera_state.dart';

class CameraNotifier extends StateNotifier<CameraState> {
  final GetAvailableCamerasUseCase getAvailableCamerasUseCase;
  final InitializeCameraUseCase initializeCameraUseCase;
  final SetFlashModeUseCase setFlashModeUseCase;
  final SetZoomLevelUseCase setZoomLevelUseCase;
  final SetFocusPointUseCase setFocusPointUseCase;
  final StartRecordingUseCase startRecordingUseCase;
  final StopRecordingUseCase stopRecordingUseCase;
  final SaveVideoUseCase saveVideoUseCase;
  final SavePhotoUseCase savePhotoUseCase;
  final CameraRepository cameraRepository;

  Timer? _recordingTimer;
  Timer? _zoomIndicatorTimer;
  double _baseZoomAtGestureStart = 1.0;

  CameraNotifier({
    required this.getAvailableCamerasUseCase,
    required this.initializeCameraUseCase,
    required this.setFlashModeUseCase,
    required this.setZoomLevelUseCase,
    required this.setFocusPointUseCase,
    required this.startRecordingUseCase,
    required this.stopRecordingUseCase,
    required this.saveVideoUseCase,
    required this.savePhotoUseCase,
    required this.cameraRepository,
  }) : super(const CameraState());

  Future<void> setup() async {
    final granted = await PermissionHelper.requestCameraAndMic();
    if (!granted) {
      state = state.copyWith(status: CameraLifecycleStatus.permissionDenied);
      return;
    }

    try {
      final cameras = await getAvailableCamerasUseCase();
      if (cameras.isEmpty) {
        state = state.copyWith(
          status: CameraLifecycleStatus.error,
          errorMessage: AppStrings.noCamerasFound,
        );
        return;
      }
      await _bootController(cameras: cameras, index: 0);
    } catch (e) {
      state = state.copyWith(
        status: CameraLifecycleStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> _bootController({
    required List<CameraDescription> cameras,
    required int index,
  }) async {
    final controller = await initializeCameraUseCase(
      cameras: cameras,
      cameraIndex: index,
      previousController: state.controller,
    );

    final minZoom = await controller.getMinZoomLevel();
    final maxZoom = await controller.getMaxZoomLevel();

    state = state.copyWith(
      status: CameraLifecycleStatus.ready,
      cameras: cameras,
      controller: controller,
      cameraIndex: index,
      zoomLevel: 1.0,
      minZoom: minZoom,
      maxZoom: maxZoom,
      flashMode: FlashMode.off,
    );
  }

  void setCaptureMode(CaptureMode mode) {
    if (state.isRecording || state.isTakingPhoto) return;
    state = state.copyWith(captureMode: mode);
  }

  Future<void> switchCamera() async {
    if (state.cameras.length < 2 || state.isRecording || state.isTakingPhoto) {
      return;
    }
    final nextIndex = (state.cameraIndex + 1) % state.cameras.length;
    await _bootController(cameras: state.cameras, index: nextIndex);
  }

  Future<void> cycleFlash() async {
    final controller = state.controller;
    if (controller == null || state.isFrontCamera) return;

    const cycle = [FlashMode.off, FlashMode.auto, FlashMode.always];
    final nextMode = cycle[(cycle.indexOf(state.flashMode) + 1) % cycle.length];

    await setFlashModeUseCase(controller, nextMode);
    state = state.copyWith(flashMode: nextMode);
  }

  void onScaleStart() {
    _baseZoomAtGestureStart = state.zoomLevel;
  }

  Future<void> onScaleUpdate(double scale) async {
    final controller = state.controller;
    if (controller == null) return;

    final newZoom = (_baseZoomAtGestureStart * scale).clamp(
      state.minZoom,
      state.maxZoom,
    );

    await setZoomLevelUseCase(controller, newZoom);
    _zoomIndicatorTimer?.cancel();
    state = state.copyWith(zoomLevel: newZoom, showZoomIndicator: true);
    _zoomIndicatorTimer = Timer(const Duration(seconds: 1), () {
      state = state.copyWith(showZoomIndicator: false);
    });
  }

  Future<void> setZoomDirect(double zoom) async {
    final controller = state.controller;
    if (controller == null) return;

    final targetZoom = zoom.clamp(state.minZoom, state.maxZoom);

    await setZoomLevelUseCase(controller, targetZoom);
    _zoomIndicatorTimer?.cancel();
    state = state.copyWith(zoomLevel: targetZoom, showZoomIndicator: true);

    _zoomIndicatorTimer = Timer(const Duration(seconds: 1), () {
      state = state.copyWith(showZoomIndicator: false);
    });
  }

  Future<void> onTapToFocus(Offset normalizedPoint) async {
    final controller = state.controller;
    if (controller == null) return;
    await setFocusPointUseCase(controller, normalizedPoint);
  }

  void selectFilter(FilterType filter) {
    state = state.copyWith(filter: filter);
  }

  Future<void> onCaptureTap(BuildContext context) async {
    if (state.captureMode == CaptureMode.photo) {
      await _takePhoto(context);
    } else {
      await _toggleRecording(context);
    }
  }

  Future<void> _takePhoto(BuildContext context) async {
    final controller = state.controller;
    if (controller == null ||
        !controller.value.isInitialized ||
        state.isTakingPhoto) {
      return;
    }

    try {
      state = state.copyWith(isTakingPhoto: true);
      final photoFile = await cameraRepository.takePicture(controller);

      final savedPath = await savePhotoUseCase(
        imagePath: photoFile.path,
        filterMatrix: state.filter.matrix,
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.photoSavedToGallery(savedPath)),
          backgroundColor: AppColors.accentPink,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.errorTakingPhoto(e.toString()))),
      );
    } finally {
      state = state.copyWith(isTakingPhoto: false);
    }
  }

  Future<void> _toggleRecording(BuildContext context) async {
    if (state.isRecording) {
      await _stopRecording(context);
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    final controller = state.controller;
    if (controller == null || !controller.value.isInitialized) return;

    await startRecordingUseCase(controller);
    await WakelockPlus.enable();

    state = state.copyWith(isRecording: true, elapsed: Duration.zero);
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(
        elapsed: state.elapsed + const Duration(seconds: 1),
      );
    });
  }

  Future<void> _stopRecording(BuildContext context) async {
    final controller = state.controller;
    if (controller == null) return;

    _recordingTimer?.cancel();
    await WakelockPlus.disable();

    final result = await stopRecordingUseCase(controller, state.elapsed);
    final savedPath = await saveVideoUseCase(result.filePath);

    state = state.copyWith(isRecording: false, elapsed: Duration.zero);

    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => VideoPreviewScreen(
          videoPath: savedPath,
          appliedFilter: state.filter,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _zoomIndicatorTimer?.cancel();
    state.controller?.dispose();
    super.dispose();
  }
}