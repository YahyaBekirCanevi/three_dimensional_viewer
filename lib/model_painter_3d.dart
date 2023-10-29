import 'package:flutter/material.dart';
import 'package:three_dart/three_dart.dart';

class ModelPainter3D extends CustomPainter {
  final Object3D? model;
  final PerspectiveCamera? camera;

  ModelPainter3D(this.model, this.camera);

  @override
  void paint(Canvas canvas, Size size) {
    if (model != null && camera != null) {
      final scene = Scene();
      scene.add(model!);

      final renderer = WebGLRenderer({'canvas': canvas, 'antialias': true});
      renderer.setSize(size.width, size.height);
      renderer.render(scene, camera!);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
