import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class ModelViewer3D extends HookWidget {
  final String? path;

  const ModelViewer3D({super.key, this.path});

  @override
  Widget build(BuildContext context) {
    return const ModelViewer(
      backgroundColor: Color.fromARGB(0xFF, 0xEE, 0xEE, 0xEE),
      src: 'https://modelviewer.dev/shared-assets/models/Astronaut.glb',
      alt: 'A 3D model of an astronaut',
      autoRotate: true,
      disableZoom: true,
      //iosSrc: 'https://modelviewer.dev/shared-assets/models/Astronaut.usdz',
    );
  }
}
