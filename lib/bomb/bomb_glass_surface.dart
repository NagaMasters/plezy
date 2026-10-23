import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

import 'bomb_glass.dart';

/// A Liquid Glass backing for floating controls (round buttons, search pill,
/// chips). Returns [child] untouched when [kBombGlassEnabled] is false.
///
/// Each surface owns its layer (one backdrop sample per control), so keep the
/// number of surfaces per screen small; group many shapes under one layer
/// instead if a screen needs more.
class BombGlassSurface extends StatelessWidget {
  const BombGlassSurface({super.key, required this.borderRadius, required this.child});

  /// Circle of the given [diameter]; the child should be laid out at that size.
  const BombGlassSurface.circle({super.key, required double diameter, required this.child})
    : borderRadius = diameter / 2;

  final double borderRadius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!kBombGlassEnabled) return child;
    return LiquidGlass.withOwnLayer(
      settings: LiquidGlassSettings.ios27Regular(brightness: Theme.of(context).brightness),
      shape: LiquidRoundedSuperellipse(borderRadius: borderRadius),
      child: child,
    );
  }
}
