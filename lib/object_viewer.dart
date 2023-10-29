import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:three_dimensional_viewer/model_viewer.dart';
import 'package:three_dimensional_viewer/view_type.dart';

class ObjectViewer extends HookWidget {
  const ObjectViewer({super.key});

  final ViewType viewType = ViewType.objectViewer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(viewType.name),
      ),
      body: ModelViewer3D(
        viewType: viewType,
      ),
    );
  }
}
