import 'package:camera/camera.dart';
import '../repositories/camera_repository.dart';

class InitializeCameraUseCase {
  final CameraRepository repository;
  InitializeCameraUseCase(this.repository);

  Future<CameraController> call({
    required List<CameraDescription> cameras,
    required int cameraIndex,
    required CameraController? previousController,
  }) {
    return repository.initializeCamera(
      cameras: cameras,
      cameraIndex: cameraIndex,
      previousController: previousController,
    );
  }
}
