import 'package:camera/camera.dart';
import 'package:flutter/material.dart' show Offset;

/// Thin wrapper around the `camera` plugin. Nothing here knows about
/// Riverpod or the UI — it only talks to the plugin API.
class CameraDataSource {
  Future<List<CameraDescription>> fetchAvailableCameras() {
    return availableCameras();
  }

  Future<CameraController> createController({
    required CameraDescription description,
  }) async {
    final controller = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: true,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    await controller.initialize();
    return controller;
  }

  Future<void> setFlashMode(CameraController controller, FlashMode mode) {
    return controller.setFlashMode(mode);
  }

  Future<void> setZoomLevel(CameraController controller, double zoom) {
    return controller.setZoomLevel(zoom);
  }

  Future<void> setFocusPoint(CameraController controller, Offset point) {
    return controller.setFocusPoint(point);
  }

  Future<void> setExposurePoint(CameraController controller, Offset point) {
    return controller.setExposurePoint(point);
  }

  Future<void> startVideoRecording(CameraController controller) {
    return controller.startVideoRecording();
  }

  Future<XFile> stopVideoRecording(CameraController controller) {
    return controller.stopVideoRecording();
  }

  Future<XFile> takePicture(CameraController controller) {
    return controller.takePicture();
  }

  Future<void> dispose(CameraController? controller) async {
    await controller?.dispose();
  }
}