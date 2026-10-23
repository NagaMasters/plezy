import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

import 'bomb_glass.dart';

/// Wraps Plezy's portrait bottom navigation area (offline banner + NavigationBar)
/// in a single floating Liquid Glass capsule. Returns [child] untouched when
/// [kBombGlassEnabled] is false.
///
/// The capsule's corner radius follows the measured height, so it stays a true
/// stadium whatever the bar is showing (labels on/off, offline banner).
class BombGlassNavBar extends StatefulWidget {
  const BombGlassNavBar({super.key, required this.child});

  final Widget child;

  @override
  State<BombGlassNavBar> createState() => _BombGlassNavBarState();
}

class _BombGlassNavBarState extends State<BombGlassNavBar> {
  static const double _horizontalMargin = 24;
  static const double _bottomMargin = 12;
  static const double _barHeight = 64;
  static const double _initialRadius = _barHeight / 2;

  final _childKey = GlobalKey();
  double _radius = _initialRadius;

  @override
  void initState() {
    super.initState();
    if (kBombGlassEnabled) {
      bombGlassPrecacheOnce();
      _scheduleMeasure();
    }
  }

  void _scheduleMeasure() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final box = _childKey.currentContext?.findRenderObject();
      if (box is! RenderBox || !box.hasSize) return;
      final radius = box.size.height / 2;
      if ((radius - _radius).abs() > 0.5) setState(() => _radius = radius);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!kBombGlassEnabled) return widget.child;
    _scheduleMeasure();

    final theme = Theme.of(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final navTheme = NavigationBarTheme.of(context).copyWith(
      height: _barHeight,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      indicatorColor: theme.colorScheme.onSurface.withValues(alpha: 0.12),
      indicatorShape: const StadiumBorder(),
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(_horizontalMargin, 0, _horizontalMargin, _bottomMargin + bottomInset),
      child: LiquidGlassLayer(
        settings: LiquidGlassSettings.ios27Regular(brightness: theme.brightness),
        child: LiquidGlass(
          shape: LiquidRoundedSuperellipse(borderRadius: _radius),
          shadows: const [BoxShadow(color: Color(0x24000000), offset: Offset(0, 6), blurRadius: 20)],
          child: NavigationBarTheme(
            data: navTheme,
            // The capsule sits above the system inset, so the bar must not add it again.
            child: MediaQuery.removePadding(
              context: context,
              removeBottom: true,
              child: KeyedSubtree(key: _childKey, child: widget.child),
            ),
          ),
        ),
      ),
    );
  }
}
