import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_camera_app/core/theme/app_colors.dart';

class TopControlsBar extends StatelessWidget {
  final FlashMode flashMode;
  final VoidCallback onFlashTap;
  final VoidCallback onGalleryTap;

  const TopControlsBar({
    super.key,
    required this.flashMode,
    required this.onFlashTap,
    required this.onGalleryTap,
  });

  IconData get _flashIcon {
    switch (flashMode) {
      case FlashMode.off:
        return Icons.flash_off;
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
      case FlashMode.torch:
        return Icons.flash_on;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _RoundIconButton(icon: _flashIcon, onTap: onFlashTap),
          _RoundIconButton(
            icon: Icons.photo_library_outlined,
            onTap: onGalleryTap,
          ),
        ],
      ),
    );
  }
}

class BottomControlsBar extends StatelessWidget {
  final bool isRecording;
  final VoidCallback onRecordTap;
  final VoidCallback onSwitchCameraTap;

  const BottomControlsBar({
    super.key,
    required this.isRecording,
    required this.onRecordTap,
    required this.onSwitchCameraTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(width: 56), // balances the switch-camera button
        const Spacer(),
        _RecordButton(isRecording: isRecording, onTap: onRecordTap),
        const Spacer(),
        _RoundIconButton(
          icon: Icons.cameraswitch_outlined,
          onTap: onSwitchCameraTap,
          size: 56,
        ),
      ],
    );
  }
}

class _RecordButton extends StatelessWidget {
  final bool isRecording;
  final VoidCallback onTap;

  const _RecordButton({required this.isRecording, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 78,
        height: 78,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
        ),
        padding: const EdgeInsets.all(6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isRecording
                ? AppColors.recordActive
                : AppColors.recordIdle,
            shape: isRecording ? BoxShape.rectangle : BoxShape.circle,
            borderRadius: isRecording ? BorderRadius.circular(10) : null,
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;

  const _RoundIconButton({
    required this.icon,
    required this.onTap,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: AppColors.controlBackground,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 22),
      ),
    );
  }
}
