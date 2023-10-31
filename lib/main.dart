import 'package:flutter/material.dart';
import 'package:three_dimensional_viewer/orbit_gl/src/misc_controls_orbit_page.dart';

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
