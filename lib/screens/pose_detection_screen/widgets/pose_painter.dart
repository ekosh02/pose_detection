import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PosePainter extends CustomPainter {
  final List<Pose> poses;
  final Size imageSize;
  final Size canvasSize;
  final Duration animationDuration;

  static final Map<PoseLandmarkType, Offset> _previousPositions = {};
  static DateTime? _lastUpdateTime;

  PosePainter({
    required this.poses,
    required this.imageSize,
    required this.canvasSize,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = Colors.red.withValues(alpha: 0.5)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final currentTime = DateTime.now();
    if (poses.isEmpty) {
      final testPoints = [
        Offset(canvasSize.width * 0.3, canvasSize.height * 0.3),
        Offset(canvasSize.width * 0.7, canvasSize.height * 0.3),
        Offset(canvasSize.width * 0.5, canvasSize.height * 0.5),
        Offset(canvasSize.width * 0.3, canvasSize.height * 0.7),
        Offset(canvasSize.width * 0.7, canvasSize.height * 0.7),
      ];

      for (final point in testPoints) {
        canvas.drawCircle(point, 8, paint);
      }
      return;
    }

    for (final pose in poses) {
      _drawPose(canvas, pose, paint, linePaint, currentTime);
    }

    _updatePreviousPositions(poses, currentTime);
    _lastUpdateTime = currentTime;
  }

  void _drawPose(
    Canvas canvas,
    Pose pose,
    Paint paint,
    Paint linePaint,
    DateTime currentTime,
  ) {
    final keyLandmarks = [
      PoseLandmarkType.nose,
      PoseLandmarkType.leftEye,
      PoseLandmarkType.rightEye,
      PoseLandmarkType.leftEar,
      PoseLandmarkType.rightEar,
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.leftElbow,
      PoseLandmarkType.rightElbow,
      PoseLandmarkType.leftWrist,
      PoseLandmarkType.rightWrist,
      PoseLandmarkType.leftHip,
      PoseLandmarkType.rightHip,
      PoseLandmarkType.leftKnee,
      PoseLandmarkType.rightKnee,
      PoseLandmarkType.leftAnkle,
      PoseLandmarkType.rightAnkle,
    ];

    for (final landmarkType in keyLandmarks) {
      final landmark = pose.landmarks[landmarkType];
      if (landmark != null) {
        final currentPoint = _translatePoint(landmark.x, landmark.y);
        final animatedPoint = _getAnimatedPoint(
          landmarkType,
          currentPoint,
          currentTime,
        );
        canvas.drawCircle(animatedPoint, 6, paint);
      }
    }

    _drawConnections(canvas, pose, linePaint, currentTime);
  }

  Offset _getAnimatedPoint(
    PoseLandmarkType landmarkType,
    Offset currentPoint,
    DateTime currentTime,
  ) {
    final previousPoint = _previousPositions[landmarkType];

    if (previousPoint == null) {
      _previousPositions[landmarkType] = currentPoint;
      return currentPoint;
    }

    if (_lastUpdateTime == null) {
      return currentPoint;
    }
    final timeDiff = currentTime.difference(_lastUpdateTime!).inMilliseconds;
    final progress = (timeDiff / animationDuration.inMilliseconds).clamp(
      0.0,
      1.0,
    );
    final animatedPoint = Offset.lerp(previousPoint, currentPoint, progress)!;
    return animatedPoint;
  }

  void _drawConnections(
    Canvas canvas,
    Pose pose,
    Paint linePaint,
    DateTime currentTime,
  ) {
    final connections = [
      [PoseLandmarkType.nose, PoseLandmarkType.leftEye],
      [PoseLandmarkType.nose, PoseLandmarkType.rightEye],
      [PoseLandmarkType.leftEye, PoseLandmarkType.leftEar],
      [PoseLandmarkType.rightEye, PoseLandmarkType.rightEar],
      [PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder],
      [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow],
      [PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist],
      [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow],
      [PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist],
      [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip],
      [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip],
      [PoseLandmarkType.leftHip, PoseLandmarkType.rightHip],
      [PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee],
      [PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle],
      [PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee],
      [PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle],
    ];

    for (final connection in connections) {
      final startLandmark = pose.landmarks[connection[0]];
      final endLandmark = pose.landmarks[connection[1]];

      if (startLandmark != null && endLandmark != null) {
        final startPoint = _translatePoint(startLandmark.x, startLandmark.y);
        final endPoint = _translatePoint(endLandmark.x, endLandmark.y);

        final animatedStartPoint = _getAnimatedPoint(
          connection[0],
          startPoint,
          currentTime,
        );
        final animatedEndPoint = _getAnimatedPoint(
          connection[1],
          endPoint,
          currentTime,
        );

        canvas.drawLine(animatedStartPoint, animatedEndPoint, linePaint);
      }
    }
  }

  Offset _translatePoint(double x, double y) {
    final imageAspectRatio = imageSize.width / imageSize.height;
    final canvasAspectRatio = canvasSize.width / canvasSize.height;

    double scale;
    double offsetX = 0;
    double offsetY = 0;

    if (imageAspectRatio > canvasAspectRatio) {
      scale = canvasSize.width / imageSize.width;
      offsetY = (canvasSize.height - imageSize.height * scale) / 2;
    } else {
      scale = canvasSize.height / imageSize.height;
      offsetX = (canvasSize.width - imageSize.width * scale) / 2;
    }

    final translatedX = x * scale + offsetX;
    final translatedY = y * scale + offsetY;

    return Offset(translatedX, translatedY);
  }

  void _updatePreviousPositions(List<Pose> poses, DateTime currentTime) {
    if (poses.isEmpty) return;
    final pose = poses.first;
    final keyLandmarks = [
      PoseLandmarkType.nose,
      PoseLandmarkType.leftEye,
      PoseLandmarkType.rightEye,
      PoseLandmarkType.leftEar,
      PoseLandmarkType.rightEar,
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.leftElbow,
      PoseLandmarkType.rightElbow,
      PoseLandmarkType.leftWrist,
      PoseLandmarkType.rightWrist,
      PoseLandmarkType.leftHip,
      PoseLandmarkType.rightHip,
      PoseLandmarkType.leftKnee,
      PoseLandmarkType.rightKnee,
      PoseLandmarkType.leftAnkle,
      PoseLandmarkType.rightAnkle,
    ];

    for (final landmarkType in keyLandmarks) {
      final landmark = pose.landmarks[landmarkType];
      if (landmark != null) {
        final point = _translatePoint(landmark.x, landmark.y);
        _previousPositions[landmarkType] = point;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
