import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:three_dart/three_dart.dart';
import 'package:three_dimensional_viewer/model_loader.dart';
import 'package:three_dimensional_viewer/model_painter_3d.dart';
import 'package:three_dimensional_viewer/view_type.dart';

class ModelViewer3D extends HookWidget {
  final String? path;
  final ViewType viewType;

  const ModelViewer3D({super.key, this.path, required this.viewType});

  void updateCameraPosition(ModelLoader state, Offset delta) {
    const sensitivity = 0.01;
    Vector3 position = state.camera!.position;
    position.x -= delta.dx * sensitivity;
    position.z -= delta.dy * sensitivity;
    state.camera!.position = position;
  }

  @override
  Widget build(BuildContext context) {
    final state = useState(viewType == ViewType.fbxmodelViewer
        ? FBXModelViewLoader(context, path)
        : ObjectViewLoader(context, path));

    if (state.value.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.value.loadedModel == null) {
      return const Center(
        child: Text('No model loaded'),
      );
    }
    return Column(
      children: [
        Text(
          state.value.toJson().toString(),
          style: const TextStyle(color: Colors.white),
        ),
        Expanded(
          child: Center(
            child: SizedBox.square(
              dimension: 300,
              child: CustomPaint(
                size: state.value.size! * 0.5,
                painter: ModelPainter3D(
                  state.value.loadedModel,
                  state.value.camera,
                  state.value.size,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
