import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import 'controller.dart';

class PreviewScreen extends StatelessWidget {
  PreviewScreen({super.key});

  final _controller = PreviewController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => _controller.onOpenCameraPressed(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonBackground,
            foregroundColor: AppColors.buttonForeground,
          ),
          child: const Text('Open camera'),
        ),
      ),
    );
  }
}
