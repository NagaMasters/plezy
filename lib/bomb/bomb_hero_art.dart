import '../media/media_item.dart';
import '../media/media_kind.dart';

/// Below this aspect ratio the Discover hero is taller than wide (a phone in
/// portrait), where a 2:3 poster fits; wider heroes keep the stock backdrops.
const double _portraitHeroAspectRatio = 1.0;

String? _seasonCover(MediaItem item, double containerAspectRatio) {
  if (item.kind != MediaKind.episode || containerAspectRatio >= _portraitHeroAspectRatio) return null;
  final path = item.parentThumbPath;
  return path == null || path.isEmpty ? null : path;
}

/// Rotation list for a hero page: an episode's season cover alone (so the page
/// holds still on it) when one is available, otherwise [stock].
List<String> bombHeroRotationPaths(MediaItem item, double containerAspectRatio, List<String> stock) {
  final cover = _seasonCover(item, containerAspectRatio);
  return cover == null ? stock : [cover];
}

/// Fallback candidates for a hero page: the season cover first, then [stock],
/// so the usual art still shows if the cover fails to load.
List<String> bombHeroArtCandidates(MediaItem item, double containerAspectRatio, List<String> stock) {
  final cover = _seasonCover(item, containerAspectRatio);
  return cover == null ? stock : [cover, ...stock.where((p) => p != cover)];
}
