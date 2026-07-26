import 'package:camera/camera.dart';
import '../entities/recording_result_entity.dart';
import '../repositories/camera_repository.dart';

class StopRecordingUseCase {
  final CameraRepository repository;
  StopRecordingUseCase(this.repository);

  Future<RecordingResultEntity> call(
    CameraController controller,
    Duration elapsed,
  ) {
    return repository.stopRecording(controller, elapsed);
  }
}
