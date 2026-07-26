import 'package:camera/camera.dart';
import '../repositories/camera_repository.dart';

class StartRecordingUseCase {
  final CameraRepository repository;
  StartRecordingUseCase(this.repository);

  Future<void> call(CameraController controller) {
    return repository.startRecording(controller);
  }
}
