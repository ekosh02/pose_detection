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

  Future<void> initCamera() async {
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
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    final initFuture = controller.initialize();
    cameraController = controller;
    initializeFuture = initFuture;

    await initFuture;

    controller.startImageStream(_processCameraImage);
  }

  Future<void> _processCameraImage(CameraImage image) async {
    final result = _convertCameraImageToInputImage(image);
    if (result == null) return;

    final inputImage = result.$1;
    final logicalSize = result.$2;
    imageSizeNotifier.value = logicalSize;

    try {
      final poses = await _poseDetector.processImage(inputImage);
      posesNotifier.value = poses;
    } catch (e) {
      posesNotifier.value = [];
    }
  }

  (InputImage, Size)? _convertCameraImageToInputImage(CameraImage image) {
    final camera = cameraController?.description;
    if (camera == null) return null;

    final rotationResult = _getRotation(camera);
    if (rotationResult == null) return null;
    final (rotation, rotationDegrees) = rotationResult;

    final width = image.width.toDouble();
    final height = image.height.toDouble();
    final logicalSize = _logicalSize(
      width: width,
      height: height,
      rotationDegrees: rotationDegrees,
    );

    if (Platform.isAndroid && image.planes.length == 3) {
      final nv21 = _yuv420ToNv21(image);
      if (nv21 == null) return null;
      final inputImage = InputImage.fromBytes(
        bytes: nv21,
        metadata: InputImageMetadata(
          size: Size(width, height),
          rotation: rotation,
          format: InputImageFormat.nv21,
          bytesPerRow: image.width,
        ),
      );
      return (inputImage, logicalSize);
    }

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null || image.planes.length != 1) return null;
    final plane = image.planes.first;

    final inputImage = InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(width, height),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
    return (inputImage, logicalSize);
  }

  (InputImageRotation, int)? _getRotation(CameraDescription camera) {
    final sensorOrientation = camera.sensorOrientation;
    if (Platform.isIOS) {
      final rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
      if (rotation == null) return null;
      return (rotation, sensorOrientation);
    }
    if (Platform.isAndroid) {
      var degrees =
          _orientations[cameraController!.value.deviceOrientation] ?? 0;
      if (camera.lensDirection == CameraLensDirection.front) {
        degrees = (sensorOrientation + degrees) % 360;
      } else {
        degrees = (sensorOrientation - degrees + 360) % 360;
      }
      final rotation = InputImageRotationValue.fromRawValue(degrees);
      if (rotation == null) return null;
      return (rotation, degrees);
    }
    return null;
  }

  Size _logicalSize({
    required double width,
    required double height,
    required int rotationDegrees,
  }) {
    if (Platform.isIOS) return Size(width, height);
    final isRotated90or270 = rotationDegrees == 90 || rotationDegrees == 270;
    return isRotated90or270 ? Size(height, width) : Size(width, height);
  }

  static Uint8List? _yuv420ToNv21(CameraImage image) {
    if (image.planes.length != 3) return null;
    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];
    final width = image.width;
    final height = image.height;
    final ySize = width * height;
    final uvSize = width * height ~/ 2;
    final nv21 = Uint8List(ySize + uvSize);

    final yBytes = yPlane.bytes;
    final yRowStride = yPlane.bytesPerRow;
    final yPixelStride = yPlane.bytesPerPixel ?? 1;
    for (int row = 0; row < height; row++) {
      for (int col = 0; col < width; col++) {
        nv21[row * width + col] = yBytes[row * yRowStride + col * yPixelStride];
      }
    }

    final uBytes = uPlane.bytes;
    final vBytes = vPlane.bytes;
    final uRowStride = uPlane.bytesPerRow;
    final vRowStride = vPlane.bytesPerRow;
    final uPixelStride = uPlane.bytesPerPixel ?? 1;
    final vPixelStride = vPlane.bytesPerPixel ?? 1;
    int uvIndex = ySize;
    for (int row = 0; row < height ~/ 2; row++) {
      for (int col = 0; col < width ~/ 2; col++) {
        final v = vBytes[row * vRowStride + col * vPixelStride];
        final u = uBytes[row * uRowStride + col * uPixelStride];
        nv21[uvIndex++] = v;
        nv21[uvIndex++] = u;
      }
    }
    return nv21;
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
