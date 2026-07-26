import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  PermissionHelper._();

  static Future<bool> requestCameraAndMic() async {
    final statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    return statuses[Permission.camera]!.isGranted &&
        statuses[Permission.microphone]!.isGranted;
  }

  static Future<bool> get isCameraPermanentlyDenied async =>
      Permission.camera.isPermanentlyDenied;

  static Future<void> openSettings() => openAppSettings();
}
