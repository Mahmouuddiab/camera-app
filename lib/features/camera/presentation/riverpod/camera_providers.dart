import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/data source/camera_data_source.dart';
import '../../data/data source/video_storage_data_source.dart';
import '../../data/repositories/camera_repository_impl.dart';
import '../../domain/repositories/camera_repository.dart';
import '../../domain/usecases/get_available_cameras_usecase.dart';
import '../../domain/usecases/initialize_camera_usecase.dart';
import '../../domain/usecases/save_photo_usecase.dart';
import '../../domain/usecases/save_video_usecase.dart';
import '../../domain/usecases/set_flash_mode_usecase.dart';
import '../../domain/usecases/set_focus_point_usecase.dart';
import '../../domain/usecases/set_zoom_level_usecase.dart';
import '../../domain/usecases/start_recording_usecase.dart';
import '../../domain/usecases/stop_recording_usecase.dart';
import 'camera_notifier.dart';
import 'camera_state.dart';

final cameraDataSourceProvider = Provider((ref) => CameraDataSource());

final videoStorageDataSourceProvider = Provider(
      (ref) => VideoStorageDataSource(),
);

final cameraRepositoryProvider = Provider<CameraRepository>((ref) {
  return CameraRepositoryImpl(
    cameraDataSource: ref.watch(cameraDataSourceProvider),
    videoStorageDataSource: ref.watch(videoStorageDataSourceProvider),
  );
});

final savePhotoUseCaseProvider = Provider((ref) {
  return SavePhotoUseCase(ref.watch(cameraRepositoryProvider));
});

final cameraNotifierProvider =
StateNotifierProvider<CameraNotifier, CameraState>((ref) {
  final repository = ref.watch(cameraRepositoryProvider);
  return CameraNotifier(
    getAvailableCamerasUseCase: GetAvailableCamerasUseCase(repository),
    initializeCameraUseCase: InitializeCameraUseCase(repository),
    setFlashModeUseCase: SetFlashModeUseCase(repository),
    setZoomLevelUseCase: SetZoomLevelUseCase(repository),
    setFocusPointUseCase: SetFocusPointUseCase(repository),
    startRecordingUseCase: StartRecordingUseCase(repository),
    stopRecordingUseCase: StopRecordingUseCase(repository),
    saveVideoUseCase: SaveVideoUseCase(repository),
    savePhotoUseCase: ref.watch(savePhotoUseCaseProvider),
    cameraRepository: repository,
  );
});