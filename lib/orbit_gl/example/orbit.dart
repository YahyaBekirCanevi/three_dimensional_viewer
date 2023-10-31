import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three_dart.dart' as three;
import 'package:three_dart_jsm/three_dart_jsm.dart' as three_jsm;

class MiscControlsOrbitController {
  late FlutterGlPlugin three3dRender;
  late three.WebGLRenderer? renderer;
  late three.Scene scene;
  late three.Camera camera;
  late double width;
  late double height;
  late double dpr;
  late int amount;
  bool verbose = true;
  bool disposed = false;
  late three.WebGLRenderTarget renderTarget;
  dynamic sourceTexture;
  late three_jsm.OrbitControls controls;
  Size? screenSize;

  final GlobalKey<three_jsm.DomLikeListenableState> _globalKey =
      GlobalKey<three_jsm.DomLikeListenableState>();

  Future<void> initPlatformState() async {
    width = screenSize!.width;
    height = screenSize!.height - 60;
    three3dRender = FlutterGlPlugin();

    Map<String, dynamic> options = {
      "antialias": true,
      "alpha": false,
      "width": width.toInt(),
      "height": height.toInt(),
      "dpr": dpr
    };

    await three3dRender.initialize(options: options);

    Future.delayed(const Duration(milliseconds: 100), () async {
      await three3dRender.prepareContext();
      await initScene();
    });
  }

  Future<void> initSize(BuildContext context) async {
    if (screenSize != null) {
      return;
    }

    final mqd = MediaQuery.of(context);
    screenSize = mqd.size;
    dpr = mqd.devicePixelRatio;
    await initPlatformState();
  }

  Future<void> render() async {
    int t = DateTime.now().millisecondsSinceEpoch;
    final gl = three3dRender.gl;
    renderer!.render(scene, camera);
    int t1 = DateTime.now().millisecondsSinceEpoch;
    if (verbose) {
      print("render cost: ${t1 - t} "
          "memory: ${renderer!.info.memory} "
          "render: ${renderer!.info.render}");
    }
    gl.flush();
    if (verbose) print(" render: sourceTexture: $sourceTexture ");
    if (!kIsWeb) {
      await three3dRender.updateTexture(sourceTexture);
    }
  }

  void initRenderer() {
    Map<String, dynamic> options = {
      "width": width,
      "height": height,
      "gl": three3dRender.gl,
      "antialias": true,
      "canvas": three3dRender.element
    };
    renderer = three.WebGLRenderer(options);
    renderer!.setPixelRatio(dpr);
    renderer!.setSize(width, height, false);
    renderer!.shadowMap.enabled = false;

    if (!kIsWeb) {
      var pars = three.WebGLRenderTargetOptions({
        "minFilter": three.LinearFilter,
        "magFilter": three.LinearFilter,
        "format": three.RGBAFormat
      });
      renderTarget = three.WebGLRenderTarget(
          (width * dpr).toInt(), (height * dpr).toInt(), pars);
      renderTarget.samples = 4;
      renderer!.setRenderTarget(renderTarget);
      sourceTexture = renderer!.getRenderTargetGLTexture(renderTarget);
    }
  }

  Future<void> initScene() async {
    initRenderer();
    await initPage();
  }

  Future<void> initPage() async {
    scene = three.Scene();
    scene.background = three.Color(0xcccccc);
    scene.fog = three.FogExp2(0xcccccc, 0.002);

    camera = three.PerspectiveCamera(60, width / height, 1, 1000);
    camera.position.set(400, 200, 0);

    // controls
    controls = three_jsm.OrbitControls(camera, _globalKey);
    controls.enableDamping = true;
    controls.dampingFactor = 0.05;
    controls.screenSpacePanning = false;
    controls.minDistance = 10;
    controls.maxDistance = 1000;
    controls.maxPolarAngle = three.Math.pi / 2;

    // world
    var geometry = three.CylinderGeometry(0, 10, 30, 4, 1);
    var material =
        three.MeshPhongMaterial({"color": 0xffffff, "flatShading": true});

    for (var i = 0; i < 500; i++) {
      var mesh = three.Mesh(geometry, material);
      mesh.position.x = three.Math.random() * 1600 - 800;
      mesh.position.y = 0;
      mesh.position.z = three.Math.random() * 1600 - 800;
      mesh.updateMatrix();
      mesh.matrixAutoUpdate = false;
      scene.add(mesh);
    }

    var dirLight1 = three.DirectionalLight(0xffffff);
    dirLight1.position.set(1, 1, 1);
    scene.add(dirLight1);

    var dirLight2 = three.DirectionalLight(0x002288);
    dirLight2.position.set(-1, -1, -1);
    scene.add(dirLight2);

    var ambientLight = three.AmbientLight(0x222222);
    scene.add(ambientLight);

    await animate();
  }

  Future<void> animate() async {
    if (disposed) {
      return;
    }
    render();
    Future.delayed(const Duration(milliseconds: 40), () async {
      await animate();
    });
  }

  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            three_jsm.DomLikeListenable(
              key: _globalKey,
              builder: (BuildContext context) {
                return Container(
                  width: width,
                  height: height,
                  color: Colors.black,
                  child: Builder(
                    builder: (BuildContext context) {
                      if (kIsWeb) {
                        return three3dRender.isInitialized
                            ? HtmlElementView(
                                viewType: three3dRender.textureId!.toString())
                            : Container();
                      } else {
                        return three3dRender.isInitialized
                            ? Texture(textureId: three3dRender.textureId!)
                            : Container();
                      }
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

class MiscControlsOrbit extends HookWidget {
  const MiscControlsOrbit({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = useMemoized(() => MiscControlsOrbitController());

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
            child: controller.build(context),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.render,
        child: const Text("render"),
      ),
    );
  }
}
