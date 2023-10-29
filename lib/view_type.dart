enum ViewType {
  fbxmodelViewer,
  objectViewer;

  String get name {
    switch (this) {
      case ViewType.fbxmodelViewer:
        return 'FBX Model Viewer';
      case ViewType.objectViewer:
        return 'Object Viewer';
    }
  }
}
