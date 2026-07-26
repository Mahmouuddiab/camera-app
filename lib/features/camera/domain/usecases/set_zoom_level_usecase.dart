import 'package:camera/camera.dart';
import '../repositories/camera_repository.dart';

class SetZoomLevelUseCase {
  final CameraRepository repository;
  SetZoomLevelUseCase(this.repository);

  Future<void> call(CameraController controller, double zoom) {
    return repository.setZoomLevel(controller, zoom);
  }
}
