import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

import 'bomb_glass.dart';

/// Wraps Plezy's portrait bottom navigation area (offline banner + NavigationBar)
/// in a single floating Liquid Glass pill. Returns [child] untouched when
/// [kBombGlassEnabled] is false.
class BombGlassNavBar extends StatefulWidget {
  const BombGlassNavBar({super.key, required this.child});

  final Widget child;

  @override
  State<BombGlassNavBar> createState() => _BombGlassNavBarState();
}

class _BombGlassNavBarState extends State<BombGlassNavBar> {
  static const double _horizontalMargin = 16;
  static const double _bottomMargin = 8;
  static const double _cornerRadius = 28;

  @override
  void initState() {
    super.initState();
    if (kBombGlassEnabled) bombGlassPrecacheOnce();
  }

  @override
  Widget build(BuildContext context) {
    if (!kBombGlassEnabled) return widget.child;

    final brightness = Theme.of(context).brightness;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final navTheme = NavigationBarTheme.of(context).copyWith(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(_horizontalMargin, 0, _horizontalMargin, _bottomMargin + bottomInset),
      child: LiquidGlassLayer(
        settings: LiquidGlassSettings.ios27Regular(brightness: brightness),
        child: LiquidGlass(
          shape: const LiquidRoundedSuperellipse(borderRadius: _cornerRadius),
          child: NavigationBarTheme(
            data: navTheme,
            // The pill sits above the system inset, so the bar must not add it again.
            child: MediaQuery.removePadding(context: context, removeBottom: true, child: widget.child),
          ),
        ),
      ),
    );
  }
}
