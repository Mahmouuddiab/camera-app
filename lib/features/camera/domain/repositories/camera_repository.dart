import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart' show Offset;
import 'package:image/image.dart' as img;
import '../entities/recording_result_entity.dart';

abstract class CameraRepository {
  Future<List<CameraDescription>> getAvailableCameras();

  Future<CameraController> initializeCamera({
    required List<CameraDescription> cameras,
    required int cameraIndex,
    required CameraController? previousController,
  });

  Future<void> setFlashMode(CameraController controller, FlashMode mode);

  Future<void> setZoomLevel(CameraController controller, double zoom);

  Future<void> setFocusPoint(CameraController controller, Offset point);

  Future<void> startRecording(CameraController controller);

  Future<RecordingResultEntity> stopRecording(
      CameraController controller,
      Duration elapsed,
      );

  Future<String> saveVideoLocally(String temporaryPath);

  Future<XFile> takePicture(CameraController controller);

  Future<String> savePhoto(String temporaryPath);

  Future<String> saveFilteredPhoto(String imagePath, List<double> matrix) async {
    final bytes = await File(imagePath).readAsBytes();
    final originalImage = img.decodeImage(bytes);

    if (originalImage == null) return imagePath;

    // Apply matrix transformation to pixel RGB values
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

    // Save the modified image back over the temp file or to a new file
    final filteredBytes = img.encodeJpg(originalImage, quality: 90);
    final filteredFile = File(imagePath);
    await filteredFile.writeAsBytes(filteredBytes);

    // Save to gallery via your gal / media store implementation
    return filteredFile.path;
  }

  void disposeController(CameraController? controller);
}