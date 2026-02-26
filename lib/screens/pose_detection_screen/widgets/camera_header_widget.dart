import 'package:flutter/material.dart';
import '../../../widgets/custom_icon_button.dart';

class CameraHeaderWidget extends StatelessWidget {
  const CameraHeaderWidget({
    super.key,
    required this.onBackPressed,
    required this.onToggleCameraVisibility,
    required this.onToggleHeadBlur,
    required this.cameraVisible,
    required this.headBlur,
  });

  final VoidCallback onBackPressed;
  final VoidCallback onToggleCameraVisibility;
  final VoidCallback onToggleHeadBlur;
  final bool cameraVisible;
  final bool headBlur;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 20,
          child: CustomIconButton(
            onPressed: onBackPressed,
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Назад',
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          right: 20,
          child: CustomIconButton(
            onPressed: onToggleCameraVisibility,
            icon: Icon(cameraVisible ? Icons.visibility : Icons.visibility_off),
            tooltip: cameraVisible ? 'Скрыть камеру' : 'Показать камеру',
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          right: 80,
          child: CustomIconButton(
            onPressed: onToggleHeadBlur,
            icon: Icon(headBlur ? Icons.face : Icons.face_retouching_off),
            tooltip: headBlur ? 'Отключить размытие головы' : 'Включить размытие головы',
          ),
        ),
      ],
    );
  }
}
