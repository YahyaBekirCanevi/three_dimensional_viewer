import 'package:flutter/material.dart';
import 'package:three_dimensional_viewer/model_viewer.dart';

class ObjectViewer extends StatelessWidget {
  const ObjectViewer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ModelViewer3D(),
    );
  }
}
