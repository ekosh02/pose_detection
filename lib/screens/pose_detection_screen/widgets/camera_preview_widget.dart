import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../controllers/pose_detection_controller.dart';
import 'camera_header_widget.dart';
import 'camera_overlay_widget.dart';
import 'camera_view_widget.dart';

class CameraPreviewWidget extends StatefulWidget {
  const CameraPreviewWidget({
    super.key,
    required this.cameraController,
    required this.controller,
  });

  final CameraController cameraController;
  final PoseDetectionController controller;

  @override
  State<CameraPreviewWidget> createState() => _CameraPreviewWidgetState();
}

class _CameraPreviewWidgetState extends State<CameraPreviewWidget> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Pose>>(
      valueListenable: widget.controller.posesNotifier,
      builder: (context, poses, child) {
        return ValueListenableBuilder<Size>(
          valueListenable: widget.controller.imageSizeNotifier,
          builder: (context, imageSize, child) {
            return ValueListenableBuilder<bool>(
              valueListenable: widget.controller.cameraVisibleNotifier,
              builder: (context, cameraVisible, child) {
                return Stack(
                  children: [
                    if (cameraVisible) ...[
                      CameraViewWidget(
                        cameraController: widget.cameraController,
                      ),
                    ],
                    CameraOverlayWidget(
                      poses: poses,
                      imageSize: imageSize,
                      cameraVisible: cameraVisible,
                    ),

                    CameraHeaderWidget(
                      onBackPressed: () => Navigator.of(context).pop(),
                      onToggleCameraVisibility:
                          widget.controller.toggleCameraVisibility,
                      cameraVisible: cameraVisible,
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
