import 'package:flutter/material.dart';
import 'package:flutter_camera_app/features/camera/presentation/screens/camera_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CameraScreen loads correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: CameraScreen(),
        ),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}