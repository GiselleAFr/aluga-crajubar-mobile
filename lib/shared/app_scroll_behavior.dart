import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Permite arrastar listas com o mouse e o touchpad (desktop e web),
/// além do toque. No celular, nada muda.
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<ui.PointerDeviceKind> get dragDevices => {
    ui.PointerDeviceKind.touch,
    ui.PointerDeviceKind.mouse,
    ui.PointerDeviceKind.stylus,
    ui.PointerDeviceKind.trackpad,
  };
}
