import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'back_button.dart';

class CameraPreviewWidget extends StatelessWidget {
  const CameraPreviewWidget({super.key, required this.cameraController});

  final CameraController cameraController;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: AspectRatio(
            aspectRatio: 3 / 4,
            child: CameraPreview(cameraController),
          ),
        ),
        const BackButtonWidget(),
      ],
    );
  }
}
