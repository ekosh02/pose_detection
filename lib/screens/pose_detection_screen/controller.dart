import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class PoseDetectionController {
  CameraController? cameraController;
  Future<void>? initializeFuture;

  Future<void> initCamera(BuildContext context) async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw CameraException('no_camera', 'No available cameras');
      }

      final frontCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      final initFuture = controller.initialize();
      cameraController = controller;
      initializeFuture = initFuture;

      await initFuture;
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Camera error: $error')));
    }
  }

  void dispose() {
    cameraController?.dispose();
  }
}
