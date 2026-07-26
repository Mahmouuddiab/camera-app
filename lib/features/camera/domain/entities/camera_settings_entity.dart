import 'package:camera/camera.dart';

class CameraSettingsEntity {
  final int cameraIndex;
  final bool isFrontCamera;
  final FlashMode flashMode;
  final double zoomLevel;
  final double minZoom;
  final double maxZoom;

  const CameraSettingsEntity({
    required this.cameraIndex,
    required this.isFrontCamera,
    required this.flashMode,
    required this.zoomLevel,
    required this.minZoom,
    required this.maxZoom,
  });

  CameraSettingsEntity copyWith({
    int? cameraIndex,
    bool? isFrontCamera,
    FlashMode? flashMode,
    double? zoomLevel,
    double? minZoom,
    double? maxZoom,
  }) {
    return CameraSettingsEntity(
      cameraIndex: cameraIndex ?? this.cameraIndex,
      isFrontCamera: isFrontCamera ?? this.isFrontCamera,
      flashMode: flashMode ?? this.flashMode,
      zoomLevel: zoomLevel ?? this.zoomLevel,
      minZoom: minZoom ?? this.minZoom,
      maxZoom: maxZoom ?? this.maxZoom,
    );
  }
}
