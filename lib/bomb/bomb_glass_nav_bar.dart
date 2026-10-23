import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

import 'bomb_glass.dart';

/// Wraps Plezy's portrait bottom navigation area (offline banner + NavigationBar)
/// in a single floating Liquid Glass capsule. Returns [child] untouched when
/// [kBombGlassEnabled] is false.
///
/// The capsule's corner radius follows the measured height, so it stays a true
/// stadium whatever the bar is showing (labels on/off, offline banner). The
/// selection is a second capsule behind the whole selected destination (icon and
/// label together); Material's own indicator only wraps the icon, so it is
/// turned off and the selected index is read from the NavigationBar below.
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
  static const double _selectionInset = 6;

  final _childKey = GlobalKey();
  double _radius = _barHeight / 2;
  int? _selectedIndex;
  int _destinationCount = 0;
  double _navBarHeight = _barHeight;

  @override
  void initState() {
    super.initState();
    if (kBombGlassEnabled) bombGlassPrecacheOnce();
  }

  NavigationBar? _findNavigationBar(Element root, void Function(Element) onFound) {
    NavigationBar? found;
    void visit(Element e) {
      if (found != null) return;
      final w = e.widget;
      if (w is NavigationBar) {
        found = w;
        onFound(e);
        return;
      }
      e.visitChildren(visit);
    }

    root.visitChildren(visit);
    return found;
  }

  void _scheduleMeasure() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final ctx = _childKey.currentContext;
      final box = ctx?.findRenderObject();
      if (ctx == null || box is! RenderBox || !box.hasSize) return;

      Element? navElement;
      final nav = _findNavigationBar(ctx as Element, (e) => navElement = e);
      final navBox = navElement?.renderObject;

      final radius = box.size.height / 2;
      final selected = nav?.selectedIndex;
      final count = nav?.destinations.length ?? 0;
      final navHeight = navBox is RenderBox && navBox.hasSize ? navBox.size.height : _navBarHeight;

      if ((radius - _radius).abs() > 0.5 ||
          selected != _selectedIndex ||
          count != _destinationCount ||
          (navHeight - _navBarHeight).abs() > 0.5) {
        setState(() {
          _radius = radius;
          _selectedIndex = selected;
          _destinationCount = count;
          _navBarHeight = navHeight;
        });
      }
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
      indicatorColor: Colors.transparent,
    );
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final selected = _selectedIndex;

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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = _destinationCount > 0 ? constraints.maxWidth / _destinationCount : 0.0;
                  final slot = selected == null ? 0 : (isRtl ? _destinationCount - 1 - selected : selected);
                  return Stack(
                    children: [
                      if (selected != null && itemWidth > 0)
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          left: slot * itemWidth + _selectionInset,
                          width: itemWidth - 2 * _selectionInset,
                          bottom: _selectionInset,
                          height: _navBarHeight - 2 * _selectionInset,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(_radius),
                            ),
                          ),
                        ),
                      KeyedSubtree(key: _childKey, child: widget.child),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
