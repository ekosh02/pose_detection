import 'dart:io';
import 'dart:ui';
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
    required this.headBlur,
  });

  final List<Pose> poses;
  final Size imageSize;
  final bool cameraVisible;
  final bool headBlur;

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
                return Stack(
                  children: [
                    if (headBlur && poses.isNotEmpty)
                      _buildHeadBlurOverlay(constraints.biggest),
                    CustomPaint(
                      size: constraints.biggest,
                      painter: PosePainterUtil(
                        poses: poses,
                        imageSize: imageSize,
                        canvasSize: constraints.biggest,
                        mirrorHorizontal: Platform.isAndroid,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeadBlurOverlay(Size canvasSize) {
    // Calculate head position and size based on pose landmarks
    final headLandmarks = [
      PoseLandmarkType.nose,
      PoseLandmarkType.leftEye,
      PoseLandmarkType.rightEye,
      PoseLandmarkType.leftEar,
      PoseLandmarkType.rightEar,
    ];

    final headPoints = <Offset>[];
    for (final pose in poses) {
      for (final landmarkType in headLandmarks) {
        final landmark = pose.landmarks[landmarkType];
        if (landmark != null) {
          final point = _translatePoint(landmark.x, landmark.y, imageSize, canvasSize);
          headPoints.add(point);
        }
      }
    }

    if (headPoints.isEmpty) return const SizedBox.shrink();

    // Calculate bounds
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (final point in headPoints) {
      minX = minX < point.dx ? minX : point.dx;
      minY = minY < point.dy ? minY : point.dy;
      maxX = maxX > point.dx ? maxX : point.dx;
      maxY = maxY > point.dy ? maxY : point.dy;
    }

    final centerX = (minX + maxX) / 2;
    final centerY = (minY + maxY) / 2;
    final width = maxX - minX;
    final height = maxY - minY;
    final radius = ((width + height) / 2) * 0.8; // Slightly smaller than bounds

    return Positioned(
      left: centerX - radius,
      top: centerY - radius,
      width: radius * 2,
      height: radius * 2,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            color: Colors.transparent,
          ),
        ),
      ),
    );
  }

  Offset _translatePoint(double x, double y, Size imageSize, Size canvasSize) {
    final imageAspect = imageSize.width / imageSize.height;
    final canvasAspect = canvasSize.width / canvasSize.height;

    final scale = imageAspect > canvasAspect
        ? canvasSize.width / imageSize.width
        : canvasSize.height / imageSize.height;
    final offsetX = imageAspect > canvasAspect
        ? 0.0
        : (canvasSize.width - imageSize.width * scale) / 2;
    final offsetY = imageAspect > canvasAspect
        ? (canvasSize.height - imageSize.height * scale) / 2
        : 0.0;

    final drawX = Platform.isAndroid ? imageSize.width - x : x;
    return Offset(drawX * scale + offsetX, y * scale + offsetY);
  }
}
