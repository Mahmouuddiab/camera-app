import 'package:flutter/material.dart';
import 'package:flutter_camera_app/core/theme/app_colors.dart';

class ZoomIndicator extends StatelessWidget {
  final double zoom;

  const ZoomIndicator({super.key, required this.zoom});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.controlBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${zoom.toStringAsFixed(1)}x',
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
