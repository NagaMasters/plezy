import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

import 'bomb_glass.dart';

/// Landscape counterpart of [BombGlassNavBar]: wraps the mobile navigation rail
/// in a floating vertical Liquid Glass capsule. Returns [child] untouched when
/// [kBombGlassEnabled] is false.
class BombGlassRail extends StatefulWidget {
  const BombGlassRail({super.key, required this.child});

  final Widget child;

  @override
  State<BombGlassRail> createState() => _BombGlassRailState();
}

class _BombGlassRailState extends State<BombGlassRail> {
  static const double _margin = 12;
  static const double _initialRadius = 40;

  final _childKey = GlobalKey();
  double _radius = _initialRadius;

  @override
  void initState() {
    super.initState();
    if (kBombGlassEnabled) bombGlassPrecacheOnce();
  }

  void _scheduleMeasure() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final box = _childKey.currentContext?.findRenderObject();
      if (box is! RenderBox || !box.hasSize) return;
      // A vertical capsule: the rounded ends have the radius of half the width.
      final radius = box.size.width / 2;
      if (radius > 0 && (radius - _radius).abs() > 0.5) setState(() => _radius = radius);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!kBombGlassEnabled) return widget.child;
    _scheduleMeasure();

    final theme = Theme.of(context);
    final insets = MediaQuery.paddingOf(context);
    final railTheme = NavigationRailTheme.of(context).copyWith(
      backgroundColor: Colors.transparent,
      elevation: 0,
      indicatorColor: theme.colorScheme.onSurface.withValues(alpha: 0.12),
      indicatorShape: const StadiumBorder(),
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(_margin + insets.left, _margin + insets.top, _margin, _margin + insets.bottom),
      child: LiquidGlassLayer(
        settings: LiquidGlassSettings.ios27Regular(brightness: theme.brightness),
        child: LiquidGlass(
          shape: LiquidRoundedSuperellipse(borderRadius: _radius),
          shadows: const [BoxShadow(color: Color(0x24000000), offset: Offset(0, 6), blurRadius: 20)],
          child: NavigationRailTheme(
            data: railTheme,
            // The capsule sits inside the insets, so the rail must not add them again.
            child: MediaQuery.removePadding(
              context: context,
              removeLeft: true,
              removeTop: true,
              removeBottom: true,
              child: KeyedSubtree(key: _childKey, child: widget.child),
            ),
          ),
        ),
      ),
    );
  }
}
