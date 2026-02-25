import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../controller.dart';
import 'pose_painter.dart';

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
                    if (cameraVisible)
                      Center(
                        child: AspectRatio(
                          aspectRatio: 3 / 4,
                          child: CameraPreview(widget.cameraController),
                        ),
                      ),
                    if (!cameraVisible)
                      Center(
                        child: AspectRatio(
                          aspectRatio: 3 / 4,
                          child: Container(
                            color: Colors.grey[900],
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
                        aspectRatio: 3 / 4,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return CustomPaint(
                              size: constraints.biggest,
                              painter: PosePainter(
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

                    Positioned(
                      top: MediaQuery.of(context).padding.top + 16,
                      left: 20,
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 30,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                          padding: const EdgeInsets.all(12),
                        ),
                        tooltip: 'Назад',
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 16,
                      right: 20,
                      child: IconButton(
                        onPressed: widget.controller.toggleCameraVisibility,
                        icon: Icon(
                          cameraVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.white,
                          size: 30,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                          padding: const EdgeInsets.all(12),
                        ),
                        tooltip: cameraVisible
                            ? 'Скрыть камеру'
                            : 'Показать камеру',
                      ),
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
