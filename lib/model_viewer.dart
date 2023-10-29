// ignore_for_file: no_logic_in_create_state

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:three_dart/three_dart.dart';
import 'package:three_dimensional_viewer/model_loader.dart';
import 'package:three_dimensional_viewer/model_painter_3d.dart';
import 'package:three_dimensional_viewer/view_type.dart';

class ModelViewer3D extends HookWidget {
  final String? path;
  final ViewType viewType;
  late ModelLoader state;

  ModelViewer3D({super.key, this.path, required this.viewType}) {
    if (viewType == ViewType.fbxmodelViewer) {
      state = FBXModelViewLoader();
    } else if (viewType == ViewType.objectViewer) {
      state = ObjectViewLoader();
    }
  }

  void updateCameraPosition(Offset delta) {
    const sensitivity = 0.01;
    Vector3 position = state.camera!.position;
    position.x -= delta.dx * sensitivity;
    position.z -= delta.dy * sensitivity;
    state.camera!.position = position;
  }

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      state = state.initialize(context, path);
      state.loadModel(path);
      return () {};
    }, [state.isLoading, state.loadedModel]);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.loadedModel == null) {
      return const Center(
        child: Text('No model loaded'),
      );
    }
    return Center(
      child: AspectRatio(
        aspectRatio: 1.0,
        child: GestureDetector(
          onPanUpdate: (details) => updateCameraPosition(details.delta),
          child: CustomPaint(
            size: state.size!,
            painter: ModelPainter3D(state.loadedModel, state.camera),
          ),
        ),
      ),
    );
  }
}
