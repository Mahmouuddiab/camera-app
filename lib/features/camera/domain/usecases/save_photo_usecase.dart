import 'package:flutter_camera_app/features/camera/domain/repositories/camera_repository.dart';

class SavePhotoUseCase {
  final CameraRepository repository;

  SavePhotoUseCase(this.repository);

  Future<String> call({
    required String imagePath,
    List<double>? filterMatrix,
  }) async {
    if (filterMatrix != null && filterMatrix.isNotEmpty) {
      return repository.saveFilteredPhoto(imagePath, filterMatrix);
    }
    return repository.savePhoto(imagePath);
  }
}