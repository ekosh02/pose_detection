import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../pose_detection_screen/view.dart';

class PreviewController {
  void onOpenCameraPressed(BuildContext context) {
    if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const PoseDetectionScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Camera is not supported on this platform yet'),
        ),
      );
    }
  }
}
