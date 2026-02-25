import 'package:flutter/material.dart';

import 'controller.dart';

class PreviewScreen extends StatelessWidget {
  PreviewScreen({super.key});

  final _controller = PreviewController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pose Detection'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _controller.onOpenCameraPressed(context),
          child: const Text('Open camera'),
        ),
      ),
    );
  }
}

