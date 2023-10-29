import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three_dart.dart' as three;
import 'package:three_dart_jsm/three_dart_jsm.dart' as three_jsm;

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

class ThreeDRenderController {
  late FlutterGlPlugin three3dRender;
  late three.WebGLRenderer? renderer;
  late three.Scene scene;
  late three.Camera camera;
  late double width;
  late double height;
  late double dpr;
  bool disposed = false;
  Size? screenSize;

  final GlobalKey<three_jsm.DomLikeListenableState> globalKey =
      GlobalKey<three_jsm.DomLikeListenableState>();

  Future<void> initSize(BuildContext context) async {
    if (screenSize != null) {
      return;
    }

    final mqd = MediaQuery.of(context);
    screenSize = mqd.size;
    dpr = mqd.devicePixelRatio;
    await initPlatformState();
  }

  Future<void> initPlatformState() async {
    width = screenSize!.width;
    height = screenSize!.height - 60;
    three3dRender = FlutterGlPlugin();

    Map<String, dynamic> options = {
      "antialias": true,
      "alpha": false,
      "width": width.toInt(),
      "height": height.toInt(),
      "dpr": dpr,
    };

    await three3dRender.initialize(options: options);
    Future.delayed(const Duration(milliseconds: 100), () async {
      await three3dRender.prepareContext();

      initScene();
    });
  }

  Future<void> render() async {
    final gl = three3dRender.gl;
    renderer!.render(scene, camera);
    gl.flush();
    if (!disposed) {
      Future.delayed(const Duration(milliseconds: 40), () async {
        await render();
      });
    }
  }

  void initRenderer() {
    Map<String, dynamic> options = {
      "width": width,
      "height": height,
      "gl": three3dRender.gl,
      "antialias": true,
      "canvas": three3dRender.element,
    };
    renderer = three.WebGLRenderer(options);
    renderer!.setPixelRatio(dpr);
    renderer!.setSize(width, height, false);
    renderer!.shadowMap.enabled = false;
  }

  Future<void> initScene() async {
    initRenderer();
    await initPage();
  }

  Future<void> initPage() async {
    scene = three.Scene();
    scene.background = three.Color(0xcccccc);
    scene.fog = three.FogExp2(0xcccccc, 0.002);

    camera = three.PerspectiveCamera(75, width / height, 1, 1000);
    camera.position.set(400, 200, 0);

    // controls
    final controls = ThreeDRenderControls(camera, globalKey);
    controls.enableDamping = true;
    controls.dampingFactor = 0.05;
    controls.screenSpacePanning = false;
    controls.minDistance = 10;
    controls.maxDistance = 1000;
    controls.maxPolarAngle = three.Math.pi / 2;

    // world
    final geometry = three.CylinderGeometry(0, 10, 30, 4, 1);
    final material =
        three.MeshPhongMaterial({"color": 0xffffff, "flatShading": true});

    for (var i = 0; i < 500; i++) {
      final mesh = three.Mesh(geometry, material);
      mesh.position.x = three.Math.random() * 1600 - 800;
      mesh.position.y = 0;
      mesh.position.z = three.Math.random() * 1600 - 800;
      mesh.updateMatrix();
      mesh.matrixAutoUpdate = false;
      scene.add(mesh);
    }

    final dirLight1 = three.DirectionalLight(0xffffff);
    dirLight1.position.set(1, 1, 1);
    scene.add(dirLight1);

    final dirLight2 = three.DirectionalLight(0x002288);
    dirLight2.position.set(-1, -1, -1);
    scene.add(dirLight2);

    final ambientLight = three.AmbientLight(0x222222);
    scene.add(ambientLight);

    await animate();
  }

  Future<void> animate() async {
    if (disposed) {
      return;
    }
    await render();
    Future.delayed(const Duration(milliseconds: 40), () async {
      await animate();
    });
  }
}

class ThreeDRenderControls extends three_jsm.OrbitControls {
  ThreeDRenderControls(three.Camera camera,
      GlobalKey<three_jsm.DomLikeListenableState> globalKey)
      : super(camera, globalKey);
}

class ThreeDRenderView extends StatelessWidget {
  final ThreeDRenderController controller;

  const ThreeDRenderView({Key? key, required this.controller})
      : super(key: key);

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
      builder: (BuildContext context) {
        return Container(
          width: controller.width,
          height: controller.height,
          color: Colors.black,
          child: Builder(
            builder: (BuildContext context) {
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
