import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:pose_detection/constants/app_colors.dart';
import '../utils/pose_painter_util.dart';
import '../../../constants/app_constants.dart';

class CameraOverlayWidget extends StatelessWidget {
  const CameraOverlayWidget({
    super.key,
    required this.poses,
    required this.imageSize,
    required this.cameraVisible,
  });

  final List<Pose> poses;
  final Size imageSize;
  final bool cameraVisible;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (!cameraVisible)
          Center(
            child: AspectRatio(
              aspectRatio: AppConstants.cameraAspectRatio,
              child: Container(
                color: AppColors.background,
                child: const Center(
                  child: Text(
                    'Камера скрыта\nТочки позы активны',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        Center(
          child: AspectRatio(
            aspectRatio: AppConstants.cameraAspectRatio,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return CustomPaint(
                  size: constraints.biggest,
                  painter: PosePainterUtil(
                    poses: poses,
                    imageSize: imageSize,
                    canvasSize: constraints.biggest,
                    mirrorHorizontal: Platform.isAndroid,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
