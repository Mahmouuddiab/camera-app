import 'package:camera/camera.dart';
import '../repositories/camera_repository.dart';

class SetFlashModeUseCase {
  final CameraRepository repository;
  SetFlashModeUseCase(this.repository);

  Future<void> call(CameraController controller, FlashMode mode) {
    return repository.setFlashMode(controller, mode);
  }
}
