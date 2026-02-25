import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PoseDetectionController {
  CameraController? cameraController;
  Future<void>? initializeFuture;
  final PoseDetector _poseDetector = PoseDetector(
    options: PoseDetectorOptions(),
  );
  final ValueNotifier<List<Pose>> posesNotifier = ValueNotifier([]);
  final ValueNotifier<Size> imageSizeNotifier = ValueNotifier(Size(640, 480));
  final ValueNotifier<bool> cameraVisibleNotifier = ValueNotifier(true);

  List<Pose> get poses => posesNotifier.value;
  Size get imageSize => imageSizeNotifier.value;
  bool get cameraVisible => cameraVisibleNotifier.value;

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

      controller.startImageStream(_processCameraImage);
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Camera error: $error')));
    }
  }

  Future<void> _processCameraImage(CameraImage image) async {
    final inputImage = _convertCameraImageToInputImage(image);
    if (inputImage == null) return;

    imageSizeNotifier.value = Size(
      image.width.toDouble(),
      image.height.toDouble(),
    );

    try {
      final poses = await _poseDetector.processImage(inputImage);
      posesNotifier.value = poses;
    } catch (e) {
      posesNotifier.value = [];
    }
  }

  InputImage? _convertCameraImageToInputImage(CameraImage image) {
    final camera = cameraController?.description;
    if (camera == null) return null;

    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation =
          _orientations[cameraController!.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;

    if (image.planes.length != 1) return null;
    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  static final Map<DeviceOrientation, int> _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  void toggleCameraVisibility() {
    cameraVisibleNotifier.value = !cameraVisibleNotifier.value;
  }

  void dispose() {
    cameraController?.stopImageStream();
    cameraController?.dispose();
    _poseDetector.close();
    posesNotifier.dispose();
    imageSizeNotifier.dispose();
    cameraVisibleNotifier.dispose();
  }
}
