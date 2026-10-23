import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

/// Master switch for the BombGlass effect. Build with
/// `--dart-define=BOMB_GLASS=false` to get the stock Plezy navigation bar.
const bool kBombGlassEnabled = bool.fromEnvironment('BOMB_GLASS', defaultValue: true);

bool _precacheStarted = false;

/// Loads the glass shaders the first time glass is about to be built.
/// Lazy on purpose: `lib/main.dart` is a hot upstream file and stays untouched.
void bombGlassPrecacheOnce() {
  if (_precacheStarted) return;
  _precacheStarted = true;
  LiquidGlass.precache();
}
