import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

import 'bomb_glass.dart';

LiquidGlassSettings _settings(BuildContext context, {bool clear = false}) =>
    clear ? LiquidGlassSettings.ios27Clear() : LiquidGlassSettings.ios27Regular(brightness: Theme.of(context).brightness);

// Ombra di esempio del README del pacchetto: fa leggere il vetro anche su sfondi piatti.
const _shadows = [BoxShadow(color: Color(0x24000000), offset: Offset(0, 6), blurRadius: 20)];

/// A Liquid Glass backing for floating controls (round buttons, search pill,
/// chips). Returns [child] untouched when [kBombGlassEnabled] is false.
///
/// By default each surface owns its layer (one backdrop sample per control), so
/// keep the number of surfaces per screen small. With [BombGlassSurface.auto]
/// the surface joins the nearest [BombGlassLayer] above it and only creates its
/// own when there is none.
class BombGlassSurface extends StatelessWidget {
  const BombGlassSurface({super.key, required this.borderRadius, this.clear = false, required this.child})
    : _auto = false,
      tint = null;

  /// Circle of the given [diameter]; the child should be laid out at that size.
  const BombGlassSurface.circle({super.key, required double diameter, this.clear = false, required this.child})
    : borderRadius = diameter / 2,
      _auto = false,
      tint = null;

  /// Shares the layer of an enclosing [BombGlassLayer]. A non-null [tint]
  /// colors the glass (its alpha sets how strongly).
  const BombGlassSurface.auto({super.key, required this.borderRadius, this.tint, required this.child})
    : _auto = true,
      clear = false;

  final double borderRadius;
  final Color? tint;

  /// Clear glass (almost no wash): for controls over the video, where the glass
  /// cannot sample the picture (it lives in a native surface below Flutter's).
  final bool clear;
  final bool _auto;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!kBombGlassEnabled) return child;
    final shape = LiquidRoundedSuperellipse(borderRadius: borderRadius);
    if (_auto) {
      return LiquidGlass.auto(
        settings: _settings(context),
        shape: shape,
        shadows: _shadows,
        appearance: tint == null
            ? null
            : LiquidGlassAppearance.ios27Regular(brightness: Theme.of(context).brightness, tint: tint!),
        child: child,
      );
    }
    return LiquidGlass.withOwnLayer(
      settings: _settings(context, clear: clear),
      shape: shape,
      shadows: _shadows,
      appearance: clear ? const LiquidGlassAppearance.ios27Clear() : null,
      child: child,
    );
  }
}

/// One shared backdrop sample for several [BombGlassSurface.auto] shapes (e.g. a
/// row of chips). Returns [child] untouched when [kBombGlassEnabled] is false.
class BombGlassLayer extends StatelessWidget {
  const BombGlassLayer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!kBombGlassEnabled) return child;
    return LiquidGlassLayer(settings: _settings(context), child: child);
  }
}
