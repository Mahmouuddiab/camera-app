import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_colors.dart';
import 'features/camera/presentation/screens/camera_screen.dart';

void main() {
  runApp(const ProviderScope(child: FlutterCameraApp()));
}

class FlutterCameraApp extends StatelessWidget {
  const FlutterCameraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Camera App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ThemeData.dark().colorScheme.copyWith(
              primary: AppColors.accentPink,
              secondary: AppColors.accentCyan,
            ),
      ),
      home: const CameraScreen(),
    );
  }
}
