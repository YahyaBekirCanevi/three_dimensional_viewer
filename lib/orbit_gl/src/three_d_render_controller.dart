import 'package:flutter/material.dart';
import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three_dart.dart' as three;
import 'package:three_dart_jsm/three_dart_jsm.dart' as three_jsm;

/* three.BufferGeometry geometry = three.CylinderGeometry(0, 10, 30, 4, 1);
    await addMesh(List.filled(1, geometry)); */

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
  int renderTime = 0;

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
    three3dRender = FlutterGlPlugin();
    width = screenSize!.width;
    height = screenSize!.height - 60;

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
      initRenderer();
      await initScene();
      await animate();
    });
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

  Future<void> render() async {
    int t = DateTime.now().millisecondsSinceEpoch;
    final gl = three3dRender.gl;
    renderer!.render(scene, camera);
    renderTime = DateTime.now().millisecondsSinceEpoch - t;
    gl.flush();
  }

  Future<void> initScene() async {
    scene = three.Scene();
    scene.background = three.Color(0xcccccc);
    scene.fog = three.FogExp2(0xcccccc, 0.00002);

    camera = three.PerspectiveCamera(75, width / height, 1, 1000);
    camera.position.set(400, 200, 0);

    final controls = ThreeDRenderControls(camera, globalKey);
    controls.enableDamping = true;
    controls.dampingFactor = 0.05;
    controls.screenSpacePanning = false;
    controls.minDistance = 10;
    controls.maxDistance = 1000;
    controls.maxPolarAngle = three.Math.pi / 2;

    final dirLight1 = three.DirectionalLight(0xffffff);
    dirLight1.position.set(1, 1, 1);
    scene.add(dirLight1);

    final dirLight2 = three.DirectionalLight(0x002288);
    dirLight2.position.set(-1, -1, -1);
    scene.add(dirLight2);

    final ambientLight = three.AmbientLight(0x222222);
    scene.add(ambientLight);
  }

  Future<void> addMesh(List<three.BufferGeometry> geometryList) async {
    //final geometry = three.CylinderGeometry(0, 10, 30, 4, 1);
    final material =
        three.MeshPhongMaterial({"color": 0xffffff, "flatShading": true});
    for (var geometry in geometryList) {
      final mesh = three.Mesh(geometry, material);
      mesh.position.x = three.Math.random() * 1600 - 800;
      mesh.position.y = 0;
      mesh.position.z = three.Math.random() * 1600 - 800;
      mesh.updateMatrix();
      mesh.matrixAutoUpdate = false;
      scene.add(mesh);
    }
  }

  Future<void> animate() async {
    if (disposed) {
      return;
    }
    await render();
    Future.delayed(const Duration(milliseconds: 100), () async {
      await animate();
    });
  }
}

class ThreeDRenderControls extends three_jsm.OrbitControls {
  ThreeDRenderControls(three.Camera camera,
      GlobalKey<three_jsm.DomLikeListenableState> globalKey)
      : super(camera, globalKey);
}
