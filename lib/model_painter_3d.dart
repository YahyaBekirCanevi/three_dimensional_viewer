import 'package:flutter/material.dart';
import 'package:three_dart/extra/console.dart';
import 'package:three_dart/three_dart.dart';

class ModelPainter3D extends CustomPainter {
  final Object3D? model;
  final PerspectiveCamera? camera;
  final Size? stateSize;

  ModelPainter3D(this.model, this.camera, this.stateSize);

  @override
  void paint(Canvas canvas, Size size) {
    if (model != null && camera != null && stateSize != null) {
      final scene = Scene();
      scene.add(model!);

      final renderer = WebGLRenderer({
        'canvas': canvas,
        //'gl': gl, // Pass the WebGL rendering context
        'width': stateSize!.width.toInt(),
        'height': stateSize!.height.toInt(),
        'antialias': true,
      });
      renderer.render(scene, camera!);
      console.info('rendered');
      Paint paint = Paint();
      paint.color = Colors.red;
      paint.strokeWidth = 100.0;
      canvas.drawRect(const Rect.fromLTWH(0, 0, 100, 100), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
