import 'package:flutter/material.dart';
import 'package:three_dart/three_dart.dart';
import 'package:three_dart_jsm/three_dart_jsm/loaders/fbx_loader.dart';

abstract class ModelLoader {
  bool isLoading = true;
  Object3D? loadedModel;
  PerspectiveCamera? camera;
  Size? size;

  Future<Object3D?> loadModel(String? path);

  ModelLoader initialize(BuildContext context, String? path) {
    final perspectiveCamera = PerspectiveCamera(75, 1, 0.1, 1000);
    perspectiveCamera.position = Vector3(0, 0, 5);
    final contextSize = MediaQuery.of(context).size;
    camera = perspectiveCamera;
    size = contextSize;
    isLoading = false;
    return this;
  }
}

class ObjectViewLoader extends ModelLoader {
  @override
  Future<Object3D?> loadModel(String? path) async {
    final model = Mesh(
      BoxGeometry(1, 1, 1),
      MeshBasicMaterial({
        'color': Color(0x00ff00),
      }),
    );
    return model;
  }
}

class FBXModelViewLoader extends ModelLoader {
  @override
  Future<Object3D?> loadModel(String? path) async {
    if (path == null) return null;
    final loader = FBXLoader(null, size!.width.toInt(), size!.height.toInt());
    final model = await loader.loadAsync(path);
    return model;
  }
}
