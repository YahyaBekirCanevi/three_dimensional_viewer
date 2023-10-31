import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:three_dimensional_viewer/orbit_gl/src/three_d_render_controller.dart';
import 'package:three_dart_jsm/three_dart_jsm.dart' as three_jsm;

class ThreeDRenderView extends HookWidget {
  final ThreeDRenderController controller;

  const ThreeDRenderView({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            ThreeDRenderWidget(controller: controller),
          ],
        ),
      ],
    );
  }
}

class ThreeDRenderWidget extends StatelessWidget {
  final ThreeDRenderController controller;

  const ThreeDRenderWidget({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return three_jsm.DomLikeListenable(
      key: controller.globalKey,
      builder: (_) {
        return Container(
          width: controller.width,
          height: controller.height,
          color: Colors.black,
          child: Builder(
            builder: (_) {
              if (!controller.three3dRender.isInitialized) {
                return Container();
              }
              final textureId = controller.three3dRender.textureId!;
              if (kIsWeb) {
                return HtmlElementView(viewType: textureId.toString());
              } else {
                return Texture(textureId: textureId);
              }
            },
          ),
        );
      },
    );
  }
}
