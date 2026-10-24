import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

import 'bomb_glass.dart';

LiquidGlassSettings _settings(BuildContext context, {double tintAmount = 0}) =>
    LiquidGlassSettings.ios27Regular(brightness: Theme.of(context).brightness, tintAmount: tintAmount);

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
  const BombGlassSurface({
    super.key,
    required this.borderRadius,
    this.clear = false,
    this.tintAmount = 0,
    required this.child,
  }) : _auto = false,
       tint = null;

  /// Circle of the given [diameter]; the child should be laid out at that size.
  const BombGlassSurface.circle({super.key, required double diameter, this.clear = false, required this.child})
    : borderRadius = diameter / 2,
      tintAmount = 0,
      _auto = false,
      tint = null;

  /// Shares the layer of an enclosing [BombGlassLayer]. A non-null [tint]
  /// colors the glass (its alpha sets how strongly).
  const BombGlassSurface.auto({super.key, required this.borderRadius, this.tint, required this.child})
    : _auto = true,
      tintAmount = 0,
      clear = false;

  final double borderRadius;
  final Color? tint;

  /// Position of iOS 27's Liquid Glass slider, 0 (clear) to 1 (tinted): more wash and a
  /// stronger blur. Only for the surface that owns its layer.
  final double tintAmount;

  /// For controls over the video: the picture lives in a native surface below
  /// Flutter's, so real glass would sample only transparency and paint an opaque
  /// body. This draws a see-through "glass" instead (faint veil, lit rim) that
  /// does not read the backdrop.
  final bool clear;
  final bool _auto;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!kBombGlassEnabled) return child;
    if (clear) return _OverVideoGlass(borderRadius: borderRadius, child: child);
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
      settings: _settings(context, tintAmount: tintAmount),
      shape: shape,
      shadows: _shadows,
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

/// See-through glass look for controls over the video. Does not sample the
/// backdrop, so the video shows through. The alphas below are our own choice.
class _OverVideoGlass extends StatelessWidget {
  const _OverVideoGlass({required this.borderRadius, required this.child});

  final double borderRadius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0x33FFFFFF), Color(0x0DFFFFFF)],
        ),
        border: Border.all(color: const Color(0x4DFFFFFF), width: 1),
      ),
      child: ClipRRect(borderRadius: radius, child: child),
    );
  }
}
