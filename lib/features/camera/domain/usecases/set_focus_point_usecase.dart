import 'package:camera/camera.dart';
import 'package:flutter/material.dart' show Offset;
import '../repositories/camera_repository.dart';

class SetFocusPointUseCase {
  final CameraRepository repository;
  SetFocusPointUseCase(this.repository);

  Future<void> call(CameraController controller, Offset point) {
    return repository.setFocusPoint(controller, point);
  }
}
