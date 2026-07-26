import '../repositories/camera_repository.dart';

class SaveVideoUseCase {
  final CameraRepository repository;
  SaveVideoUseCase(this.repository);

  Future<String> call(String temporaryPath) {
    return repository.saveVideoLocally(temporaryPath);
  }
}
