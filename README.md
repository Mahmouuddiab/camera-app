# Flutter-Camera-App

A camera module built for the Flutter Developer technical assessment:
front/back camera switching, video recording, flash, zoom, tap-to-focus,
real-time filters/effects, and a post-recording preview.

## Setup

This folder ships only the `lib/` source (plus `pubspec.yaml`) so it can
be dropped into a fresh Flutter project without carrying pre-generated
Android/iOS build files that may not match your local toolchain.

```bash
# 1. Scaffold the native android/ and ios/ folders in place
flutter create --project-name flutter_camera_app .

# 2. Get packages
flutter pub get

# 3. Add native permission entries — see PERMISSIONS_SNIPPETS.md

# 4. Run on a real device (camera plugin does not work on most simulators)
flutter run
```

> **Note:** run on a **physical device**. The iOS Simulator has no camera
> hardware, and the Android emulator's virtual camera doesn't support
> video recording reliably.

## Architecture

Clean Architecture, feature-first, matching a Riverpod + Dio-style stack:

```
lib/
  core/
    theme/            AppColors, shared visual constants
    utils/             PermissionHelper, AppStrings
  features/
    camera/
      domain/
        entities/       CameraSettingsEntity, FilterType, RecordingResultEntity
        repositories/    CameraRepository (abstract contract)
        usecases/        One class per action, each exposing call()
      data/
        data source/     CameraDataSource, VideoStorageDataSource
                         (thin wrappers around the `camera` plugin and
                          filesystem/gallery persistence)
        repositories/    CameraRepositoryImpl
      presentation/
        riverpod/       camera_notifier.dart, camera_providers.dart, camera_state.dart
        screens/        camera_screen.dart, video_preview_screen.dart
        widgets/        camera_controls.dart, filter_selector.dart, 
                        recording_timer_widget.dart, zoom_slider.dart
```

- Entities are plain Dart classes — no domain-model wrapping.
- Use cases return plain `Future<T>` (no `Either`), each with a `.call()`.
- The `data source` folder name intentionally keeps the space.
- All presentation state (state class, `StateNotifier`, Riverpod
  providers, and the screen widget) lives in `camera_screen.dart`; only
  purely presentational sub-widgets are split out for readability.

## How each requirement is implemented

| Requirement | Implementation |
|---|---|
| Front/back switch | `CameraNotifier.switchCamera()` re-initializes the controller with the next `CameraDescription` |
| Video recording | `camera` plugin's `startVideoRecording` / `stopVideoRecording`, wrapped in use cases |
| Flash control | `cycleFlash()` steps through off → auto → torch; hidden for the front camera (no hardware flash) |
| Zoom | Pinch gesture (`onScaleUpdate`) mapped to `setZoomLevel`, clamped to the device's min/max |
| Tap to focus | Tap position normalized to `[0,1]` and passed to `setFocusPoint` / `setExposurePoint` |
| Permission handling | `PermissionHelper` requests camera + microphone before boot; dedicated UI states for denied/error |
| Recording timer | `Timer.periodic` in the notifier, rendered by `RecordingTimerWidget` |
| Video preview | `VideoPreviewScreen` plays the saved file with `video_player`, same filter reapplied |
| Save locally | `VideoStorageDataSource` copies the temp file into app documents, then best-effort exports to the gallery via `gal` |
| Filters/effects | `FilterType` entity carries a 4x5 `ColorFilter.matrix` per filter, applied live over `CameraPreview` (and again over the saved playback) via `ColorFiltered` |

### Filters approach & trade-off

Filters are applied as GPU-accelerated `ColorFilter` matrices over the
live preview and the played-back file — this gives real-time, judder-free
filtering with zero extra dependencies. It does **not** burn the filter
into the actual video *file* bytes (the saved `.mp4` is unfiltered). For
a production video pipeline, that would mean piping frames
through `ffmpeg_kit_flutter` (colorchannelmixer filter) or a native
GPUImage/Metal shader pass during/after export — noted here as the next
step rather than implemented, to keep the recording path lag-free within
the assessment window.

## State management

`flutter_riverpod` (`StateNotifier` + `StateNotifierProvider`), consistent
with the rest of the codebase.

## Known limitations / next steps

- Filters are preview/playback-only (see above).
- Gallery browsing button is wired in the UI but not implemented (marked
  optional in the spec).
- No automated widget/golden tests included given the 3-day scope;
  `flutter_lints` is included for static analysis.

