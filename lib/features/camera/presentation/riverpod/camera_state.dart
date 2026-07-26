import 'package:camera/camera.dart';
import 'package:flutter_camera_app/features/camera/domain/entities/filter_type.dart';

enum CameraLifecycleStatus { loading, ready, permissionDenied, error }
enum CaptureMode { photo, video }

class CameraState {
  final CameraLifecycleStatus status;
  final CaptureMode captureMode;
  final List<CameraDescription> cameras;
  final CameraController? controller;
  final int cameraIndex;
  final FlashMode flashMode;
  final double zoomLevel;
  final double minZoom;
  final double maxZoom;
  final bool showZoomIndicator;
  final FilterType filter;
  final bool isRecording;
  final bool isTakingPhoto;
  final Duration elapsed;
  final String? errorMessage;

  const CameraState({
    this.status = CameraLifecycleStatus.loading,
    this.captureMode = CaptureMode.video,
    this.cameras = const [],
    this.controller,
    this.cameraIndex = 0,
    this.flashMode = FlashMode.off,
    this.zoomLevel = 1.0,
    this.minZoom = 1.0,
    this.maxZoom = 1.0,
    this.showZoomIndicator = false,
    this.filter = FilterType.none,
    this.isRecording = false,
    this.isTakingPhoto = false,
    this.elapsed = Duration.zero,
    this.errorMessage,
  });

  bool get isFrontCamera =>
      cameras.isNotEmpty &&
          cameras[cameraIndex].lensDirection == CameraLensDirection.front;

  CameraState copyWith({
    CameraLifecycleStatus? status,
    CaptureMode? captureMode,
    List<CameraDescription>? cameras,
    CameraController? controller,
    int? cameraIndex,
    FlashMode? flashMode,
    double? zoomLevel,
    double? minZoom,
    double? maxZoom,
    bool? showZoomIndicator,
    FilterType? filter,
    bool? isRecording,
    bool? isTakingPhoto,
    Duration? elapsed,
    String? errorMessage,
  }) {
    return CameraState(
      status: status ?? this.status,
      captureMode: captureMode ?? this.captureMode,
      cameras: cameras ?? this.cameras,
      controller: controller ?? this.controller,
      cameraIndex: cameraIndex ?? this.cameraIndex,
      flashMode: flashMode ?? this.flashMode,
      zoomLevel: zoomLevel ?? this.zoomLevel,
      minZoom: minZoom ?? this.minZoom,
      maxZoom: maxZoom ?? this.maxZoom,
      showZoomIndicator: showZoomIndicator ?? this.showZoomIndicator,
      filter: filter ?? this.filter,
      isRecording: isRecording ?? this.isRecording,
      isTakingPhoto: isTakingPhoto ?? this.isTakingPhoto,
      elapsed: elapsed ?? this.elapsed,
      errorMessage: errorMessage,
    );
  }
}