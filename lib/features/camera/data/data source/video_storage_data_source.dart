import 'dart:io';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';

class VideoStorageDataSource {
  Future<String> persistToAppStorage(String temporaryPath) async {
    final directory = await getApplicationDocumentsDirectory();
    final videosDir = Directory('${directory.path}/recorded_videos');
    if (!await videosDir.exists()) {
      await videosDir.create(recursive: true);
    }

    final fileName =
        'video_${DateTime.now().millisecondsSinceEpoch}.mp4';
    final destinationPath = '${videosDir.path}/$fileName';

    final sourceFile = File(temporaryPath);
    await sourceFile.copy(destinationPath);

    return destinationPath;
  }

  Future<void> saveToGallery(String filePath) async {
    final hasAccess = await Gal.hasAccess();
    if (!hasAccess) {
      final granted = await Gal.requestAccess();
      if (!granted) return;
    }
    await Gal.putVideo(filePath);
  }

  Future<String> persistPhotoToAppStorage(String temporaryPath) async {
    final directory = await getApplicationDocumentsDirectory();
    final photosDir = Directory('${directory.path}/captured_photos');
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }

    final fileName = 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final destinationPath = '${photosDir.path}/$fileName';

    final sourceFile = File(temporaryPath);
    await sourceFile.copy(destinationPath);

    return destinationPath;
  }

  Future<void> savePhotoToGallery(String filePath) async {
    final hasAccess = await Gal.hasAccess();
    if (!hasAccess) {
      final granted = await Gal.requestAccess();
      if (!granted) return;
    }
    await Gal.putImage(filePath);
  }
}