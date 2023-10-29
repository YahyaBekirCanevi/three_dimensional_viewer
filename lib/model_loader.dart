import 'package:flutter/material.dart';
import 'package:three_dart/three_dart.dart';
import 'package:three_dart_jsm/three_dart_jsm/loaders/fbx_loader.dart';

class ModelLoader {
  bool isLoading = true;
  Object3D? loadedModel;
  PerspectiveCamera? camera;
  Size? size;

  Future<void> loadModel(String? path) {
    return Future.value();
  }

  ModelLoader(BuildContext context, String? path) {
    final perspectiveCamera = PerspectiveCamera(75, 1, 0.1, 1000);
    perspectiveCamera.position = Vector3(0, 0, 5);
    final contextSize = MediaQuery.of(context).size;
    camera = perspectiveCamera;
    size = contextSize;
    loadModel(path);
  }

  Map<String, dynamic> toJson() {
    return {
      'isLoading': isLoading,
      'loadedModel': loadedModel.toString(),
      'camera': camera.toString(),
      'size': size
    };
  }
}

class ObjectViewLoader extends ModelLoader {
  ObjectViewLoader(super.context, super.path);

  final Color color = Color(0x00ff00);

  @override
  Future<void> loadModel(String? path) async {
    final model = Mesh(
      BoxGeometry(1, 1, 1),
      MeshBasicMaterial({'color': color}),
    );
    loadedModel = model;
    isLoading = false;
  }
}

class FBXModelViewLoader extends ModelLoader {
  FBXModelViewLoader(super.context, super.path);

  @override
  Future<void> loadModel(String? path) async {
    if (path == null) return;
    final loader = FBXLoader(null, size!.width.toInt(), size!.height.toInt());
    final model = await loader.loadAsync(path);
    loadedModel = model;
    isLoading = false;
  }
}
