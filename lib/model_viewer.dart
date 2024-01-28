import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:simple_3d/simple_3d.dart';
import 'package:simple_3d_renderer/simple_3d_renderer.dart';
import 'package:util_simple_3d/util_simple_3d.dart';

class ModelViewer3D extends HookWidget {
  const ModelViewer3D({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    List<Sp3dObj> objs = [];
    var world = useState<Sp3dWorld?>(null);
    var isLoaded = useState(false);

    void loadImage() async {
      world.value = Sp3dWorld(objs);
      world.value!.initImages().then((_) => isLoaded.value = true);
    }

    useEffect(() {
      // Create Sp3dObj.
      Sp3dObj obj = UtilSp3dGeometry.cube(50, 50, 50, 4, 4, 4);
      obj.materials.add(FSp3dMaterial.green.deepCopy());
      obj.fragments[0].faces[0].materialIndex = 1;
      obj.materials[0] = FSp3dMaterial.grey.deepCopy()
        ..strokeColor = const Color.fromARGB(255, 0, 0, 255);
      obj.rotate(Sp3dV3D(1, 1, 0).nor(), 30 * 3.14 / 180);
      objs.add(obj);

      Future.delayed(const Duration(milliseconds: 100), () => loadImage());
      return () {};
    }, []);

    return Builder(builder: (context) {
      if (!isLoaded.value || world.value == null) {
        return const Center(
          child: SizedBox.square(
            dimension: 100,
            child: CircularProgressIndicator(),
          ),
        );
      }
      return Sp3dRenderer(
        size,
        Sp3dV2D(size.width * .5, size.height * .5),
        world.value!,
        // If you want to reduce distortion, shoot from a distance at high magnification.
        Sp3dCamera(Sp3dV3D(0, 0, 3000), 6000),
        Sp3dLight(Sp3dV3D(0, 0, -1), syncCam: true),
      );
    });
  }
}
