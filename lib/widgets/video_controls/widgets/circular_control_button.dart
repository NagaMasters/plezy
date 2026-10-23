import 'package:flutter/material.dart';
import 'package:plezy/widgets/app_icon.dart';
import '../../../bomb/bomb_glass.dart'; // BOMB
import '../../../bomb/bomb_glass_surface.dart'; // BOMB

/// A circular semi-transparent button used in the mobile video controls.
///
/// Renders an [AppIcon] inside an [IconButton] on a black circle with 50%
/// opacity. Disabled buttons grey out the icon.
class CircularControlButton extends StatelessWidget {
  final String semanticLabel;
  final IconData icon;
  final double iconSize;
  final VoidCallback? onPressed;

  const CircularControlButton({
    super.key,
    required this.semanticLabel,
    required this.icon,
    required this.iconSize,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;
    return BombGlassSurface( // BOMB
      borderRadius: 100,
      child: Container(
      decoration: kBombGlassEnabled ? null : BoxDecoration(color: Colors.black.withValues(alpha: 0.5), shape: BoxShape.circle), // BOMB
      child: Semantics(
        label: semanticLabel,
        button: true,
        enabled: isEnabled,
        onTap: onPressed,
        excludeSemantics: true,
        child: IconButton(
          icon: AppIcon(
            icon,
            fill: 1,
            color: isEnabled ? Colors.white : Colors.white.withValues(alpha: 0.3),
            size: iconSize,
          ),
          iconSize: iconSize,
          onPressed: onPressed,
        ),
      ),
      ), // BOMB
    );
  }
}
