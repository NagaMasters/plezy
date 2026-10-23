import 'package:flutter/material.dart';

import '../media/catalog_item_ref.dart';
import '../media/media_item.dart';
import '../media/media_kind.dart';
import '../screens/media_detail_screen.dart';
import '../utils/media_navigation_helper.dart';

/// Makes a title in the player header tappable: it leaves the player the usual
/// way ([onBack], which stops playback and reports progress) and then opens the
/// series page ([series] true) or the episode's page (the show page positioned
/// on that episode, exactly what the app does for an episode card). For a movie
/// both lines open the movie page.
class BombPlayerTitleLink extends StatelessWidget {
  const BombPlayerTitleLink({
    super.key,
    required this.metadata,
    required this.onBack,
    required this.child,
    this.series = false,
  });

  final MediaItem metadata;
  final VoidCallback? onBack;
  final bool series;
  final Widget child;

  bool get _enabled =>
      !metadata.isCatalogItem &&
      (metadata.kind == MediaKind.movie || (metadata.kind == MediaKind.episode && !series) || _hasSeries);

  bool get _hasSeries => series && metadata.kind == MediaKind.episode && metadata.grandparentId != null;

  Future<void> _open(BuildContext context) async {
    final navigator = Navigator.of(context);
    final exit = onBack;
    if (exit != null) {
      // The player's back handler is async (progress report, teardown) even though it is passed as a VoidCallback.
      final pending = (exit as dynamic)();
      if (pending is Future) await pending;
    } else {
      navigator.pop(true);
    }
    if (!navigator.mounted) return;

    final target = mediaDetailNavigationTargetFor(metadata);
    navigator.push(
      _hasSeries
          ? mediaDetailRoute(metadata: target.metadata)
          : mediaDetailRoute(
              metadata: target.metadata,
              initialSeasonIndex: target.initialSeasonIndex,
              initialSeasonId: target.initialSeasonId,
              initialEpisodeId: target.initialEpisodeId,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_enabled) return child;
    return GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => _open(context), child: child);
  }
}
