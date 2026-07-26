import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart' show Offset;
import 'package:image/image.dart' as img;

import '../../domain/entities/recording_result_entity.dart';
import '../../domain/repositories/camera_repository.dart';
import '../data source/camera_data_source.dart';
import '../data source/video_storage_data_source.dart';

class CameraRepositoryImpl implements CameraRepository {
  final CameraDataSource cameraDataSource;
  final VideoStorageDataSource videoStorageDataSource;

  CameraRepositoryImpl({
    required this.cameraDataSource,
    required this.videoStorageDataSource,
  });

  @override
  Future<List<CameraDescription>> getAvailableCameras() {
    return cameraDataSource.fetchAvailableCameras();
  }

  @override
  Future<CameraController> initializeCamera({
    required List<CameraDescription> cameras,
    required int cameraIndex,
    required CameraController? previousController,
  }) async {
    await cameraDataSource.dispose(previousController);
    return cameraDataSource.createController(
      description: cameras[cameraIndex],
    );
  }

  @override
  Future<void> setFlashMode(CameraController controller, FlashMode mode) {
    return cameraDataSource.setFlashMode(controller, mode);
  }

  @override
  Future<void> setZoomLevel(CameraController controller, double zoom) {
    return cameraDataSource.setZoomLevel(controller, zoom);
  }

  @override
  Future<void> setFocusPoint(CameraController controller, Offset point) async {
    await cameraDataSource.setFocusPoint(controller, point);
    await cameraDataSource.setExposurePoint(controller, point);
  }

  @override
  Future<void> startRecording(CameraController controller) {
    return cameraDataSource.startVideoRecording(controller);
  }

  @override
  Future<RecordingResultEntity> stopRecording(
      CameraController controller,
      Duration elapsed,
      ) async {
    final file = await cameraDataSource.stopVideoRecording(controller);
    return RecordingResultEntity(filePath: file.path, duration: elapsed);
  }

  @override
  Future<String> saveVideoLocally(String temporaryPath) async {
    final savedPath =
    await videoStorageDataSource.persistToAppStorage(temporaryPath);
    try {
      await videoStorageDataSource.saveToGallery(savedPath);
    } catch (_) {}
    return savedPath;
  }

  @override
  Future<XFile> takePicture(CameraController controller) {
    return cameraDataSource.takePicture(controller);
  }

  @override
  Future<String> savePhoto(String temporaryPath) async {
    final savedPath =
    await videoStorageDataSource.persistPhotoToAppStorage(temporaryPath);
    try {
      await videoStorageDataSource.savePhotoToGallery(savedPath);
    } catch (_) {}
    return savedPath;
  }

  @override
  Future<String> saveFilteredPhoto(String imagePath, List<double> matrix) async {
    final bytes = await File(imagePath).readAsBytes();
    final originalImage = img.decodeImage(bytes);

    if (originalImage != null && matrix.length >= 20) {
      for (final pixel in originalImage) {
        final r = pixel.r;
        final g = pixel.g;
        final b = pixel.b;
        final a = pixel.a;

        final newR = (matrix[0] * r + matrix[1] * g + matrix[2] * b + matrix[3] * a + matrix[4]).clamp(0, 255);
        final newG = (matrix[5] * r + matrix[6] * g + matrix[7] * b + matrix[8] * a + matrix[9]).clamp(0, 255);
        final newB = (matrix[10] * r + matrix[11] * g + matrix[12] * b + matrix[13] * a + matrix[14]).clamp(0, 255);

        pixel.r = newR;
        pixel.g = newG;
        pixel.b = newB;
      }

      final filteredBytes = img.encodeJpg(originalImage, quality: 90);
      await File(imagePath).writeAsBytes(filteredBytes);
    }

    // Persist and save to gallery using existing storage data source
    return savePhoto(imagePath);
  }

  @override
  void disposeController(CameraController? controller) {
    cameraDataSource.dispose(controller);
  }
}