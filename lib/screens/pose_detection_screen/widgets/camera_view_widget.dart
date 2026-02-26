import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';

class CameraViewWidget extends StatelessWidget {
  const CameraViewWidget({super.key, required this.cameraController});

  final CameraController cameraController;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: AppConstants.cameraAspectRatio,
        child: CameraPreview(cameraController),
      ),
    );
  }
}
