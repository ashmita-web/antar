import 'package:flutter/material.dart';

abstract final class AntarColors {
  static const primary = Color(0xFF2E3A87);
  static const accent = Color(0xFFF2994A);

  // Quadrant colors
  static const silentGap = Color(0xFF8E44AD);
  static const trueHotspot = Color(0xFFE74C3C);
  static const phantomDemand = Color(0xFFF39C12);
  static const stable = Color(0xFF27AE60);

  // Semantic
  static const error = Color(0xFFD32F2F);
  static const onPrimary = Colors.white;
}

abstract final class AntarIcons {
  static const silentGap = Icons.hearing_disabled;
  static const trueHotspot = Icons.local_fire_department;
  static const phantomDemand = Icons.build;
  static const stable = Icons.check_circle;
}

enum Quadrant {
  silentGap('Silent Gap', AntarColors.silentGap, AntarIcons.silentGap),
  trueHotspot('True Hotspot', AntarColors.trueHotspot, AntarIcons.trueHotspot),
  phantomDemand(
    'Phantom Demand',
    AntarColors.phantomDemand,
    AntarIcons.phantomDemand,
  ),
  stable('Stable', AntarColors.stable, AntarIcons.stable);

  const Quadrant(this.label, this.color, this.icon);
  final String label;
  final Color color;
  final IconData icon;
}

abstract final class AntarSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

abstract final class AntarRadius {
  static const card = 20.0;
  static const chip = 12.0;
  static const button = 12.0;
  static const sheet = 24.0;
}
