import 'package:flutter/material.dart';
import 'controller.dart';
import 'widgets/camera_preview.dart';
import 'widgets/error_message.dart';
import 'widgets/loading_indicator.dart';

class PoseDetectionScreen extends StatefulWidget {
  const PoseDetectionScreen({super.key});

  @override
  State<PoseDetectionScreen> createState() => _PoseDetectionScreenState();
}

class _PoseDetectionScreenState extends State<PoseDetectionScreen> {
  final _controller = PoseDetectionController();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _controller.initCamera(context);
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _controller.initializeFuture == null
          ? const LoadingIndicator()
          : FutureBuilder<void>(
              future: _controller.initializeFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    _controller.cameraController != null &&
                    _controller.cameraController!.value.isInitialized) {
                  return CameraPreviewWidget(
                    cameraController: _controller.cameraController!,
                  );
                } else if (snapshot.hasError) {
                  return const ErrorMessage();
                } else {
                  return const LoadingIndicator();
                }
              },
            ),
    );
  }
}
