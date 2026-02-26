import 'package:flutter/material.dart';
import 'package:pose_detection/constants/app_colors.dart';
import 'controllers/pose_detection_controller.dart';
import 'widgets/camera_preview_widget.dart';
import 'widgets/error_message_widget.dart';
import 'widgets/loading_indicator_widget.dart';

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
    try {
      await _controller.initCamera();
      if (!mounted) return;
      setState(() {});
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Camera error: $error')));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _controller.initializeFuture == null
          ? const LoadingIndicatorWidget()
          : FutureBuilder<void>(
              future: _controller.initializeFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    _controller.cameraController != null &&
                    _controller.cameraController!.value.isInitialized) {
                  return CameraPreviewWidget(
                    cameraController: _controller.cameraController!,
                    controller: _controller,
                  );
                } else if (snapshot.hasError) {
                  return const ErrorMessageWidget();
                } else {
                  return const LoadingIndicatorWidget();
                }
              },
            ),
    );
  }
}
