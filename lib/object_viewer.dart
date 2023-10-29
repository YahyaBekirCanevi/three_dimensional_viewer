import 'package:flutter/material.dart';
import 'package:three_dimensional_viewer/model_viewer.dart';
import 'package:three_dimensional_viewer/view_type.dart';

class ObjectViewer extends StatelessWidget {
  const ObjectViewer({super.key});

  final ViewType viewType = ViewType.objectViewer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ModelViewer3D(
        viewType: viewType,
      ),
    );
  }
}
