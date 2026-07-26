# Native permission entries

This project is a `lib/` source drop-in. After running `flutter create .`
in this folder (see README), add the following native entries.

## Android — `android/app/src/main/AndroidManifest.xml`

Add inside `<manifest>`, above `<application>`:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
    android:maxSdkVersion="28" />
<uses-feature android:name="android.hardware.camera" android:required="true" />
<uses-feature android:name="android.hardware.camera.autofocus" android:required="false" />
```

In `android/app/build.gradle`, make sure `minSdkVersion` is at least `21`
(the `camera` plugin requirement).

## iOS — `ios/Runner/Info.plist`

Add these keys:

```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to record your videos.</string>
<key>NSMicrophoneUsageDescription</key>
<string>We need microphone access to record audio with your videos.</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>We save your recorded videos to your photo library.</string>
```

Also bump the deployment target to iOS 12+ in `ios/Podfile` and
`ios/Runner.xcodeproj` (required by `camera` / `video_player`).
