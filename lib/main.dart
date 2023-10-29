import 'package:flutter/material.dart';
import 'package:three_dimensional_viewer/object_viewer.dart';
import 'package:three_dimensional_viewer/orbit.dart';
import 'package:three_dimensional_viewer/orbit_v2.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MiscControlsOrbitPage(),
      //ObjectViewer(),
    );
  }
}
