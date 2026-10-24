import 'package:flutter/material.dart';

import 'bomb_glass.dart';
import 'bomb_glass_surface.dart';

/// Corner radius of a glass sheet.
const double bombSheetRadius = 28;

const double _sheetMargin = 16;
const double _sheetEdgeGap = 12;

/// Turns an overlay sheet into a floating Liquid Glass panel: off the screen edges,
/// all corners rounded, strong blur and wash. Returns [child] untouched when
/// [kBombGlassEnabled] is false. [child] must paint no background of its own and use
/// [bombSheetRadius] for its corners, and must not pad for the system inset: the
/// panel already sits above it.
class BombGlassSheet extends StatelessWidget {
  const BombGlassSheet({super.key, required this.isTop, required this.child});

  /// A sheet that slides down from the top instead of up from the bottom.
  final bool isTop;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!kBombGlassEnabled) return child;
    final insets = MediaQuery.paddingOf(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        _sheetMargin,
        isTop ? _sheetEdgeGap + insets.top : 0,
        _sheetMargin,
        isTop ? 0 : _sheetEdgeGap + insets.bottom,
      ),
      child: BombGlassSurface(borderRadius: bombSheetRadius, tintAmount: 1, child: child),
    );
  }
}
