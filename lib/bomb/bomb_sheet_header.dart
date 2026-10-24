import 'package:flutter/material.dart';

import 'bomb_glass.dart';
import 'bomb_glass_surface.dart';

/// Width the back arrow in a sheet header occupies: the stock glyph, or the glass
/// circle that holds it.
double bombBackGlyphWidth(double stockWidth) => kBombGlassEnabled ? 40 : stockWidth;

/// The sheet header's back arrow on a Liquid Glass circle. Returns [icon]
/// untouched when [kBombGlassEnabled] is false.
Widget bombBackGlyph(Widget icon) {
  if (!kBombGlassEnabled) return icon;
  return SizedBox.square(
    dimension: 40,
    child: BombGlassSurface.circle(
      diameter: 40,
      child: Center(child: icon),
    ),
  );
}
