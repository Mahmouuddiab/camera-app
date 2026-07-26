abstract class AppStrings {
  static const String defaultError = 'Something went wrong.';
  static const String photoMode = 'PHOTO';
  static const String videoMode = 'VIDEO';
  static String zoomLabel(int value) => '${value}x';
  static const String permissionDeniedMessage =
      'Camera & microphone access is required to capture photos and record videos.';
  static const String tryAgain = 'Try again';
  static const String openSettings = 'Open settings';
  static const String retry = 'Retry';
  static const String previewTitle = 'Preview';
  static const String retakeButton = 'Retake';
  static const String doneButton = 'Done';
  static String savedToPath(String path) => 'Saved to: $path';
  static const String noCamerasFound = 'No cameras found on this device.';
  static String photoSavedToGallery(String path) =>
      'Photo saved to gallery! ($path)';
  static String errorTakingPhoto(String error) => 'Error taking photo: $error';
}
