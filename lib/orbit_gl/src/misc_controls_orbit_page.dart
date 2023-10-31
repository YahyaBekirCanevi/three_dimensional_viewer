import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:three_dimensional_viewer/orbit_gl/src/three_d_render_controller.dart';
import 'package:three_dimensional_viewer/orbit_gl/src/three_d_render_view.dart';

class MiscControlsOrbitPage extends HookWidget {
  const MiscControlsOrbitPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = useMemoized(() => ThreeDRenderController());

    return Scaffold(
      body: FutureBuilder(
        future: controller.initSize(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return SingleChildScrollView(
            child: ThreeDRenderView(controller: controller),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.render,
        child: const Text("Render"),
      ),
    );
  }
}
