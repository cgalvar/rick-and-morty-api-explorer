import 'package:flutter/widgets.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

/// Semantic icon roles used by the presentation layer.
enum AppIcon {
  lostSignal,
  retry,
  statusIndicator,
  favoriteSelected,
  favoriteUnselected,
  userPlaceholder,
  themeToggle,
  search,
  allFilter,
  emptyGlobe,
  species,
  gender,
  type,
  origin,
  location,
  episodes,
}

abstract final class AppIcons {
  static IconData resolve(AppIcon icon) => switch (icon) {
    AppIcon.lostSignal => PhosphorIconsRegular.broadcast,
    AppIcon.retry => PhosphorIconsRegular.arrowClockwise,
    AppIcon.statusIndicator => PhosphorIconsFill.circle,
    AppIcon.favoriteSelected => PhosphorIconsFill.heart,
    AppIcon.favoriteUnselected => PhosphorIconsRegular.heart,
    AppIcon.userPlaceholder => PhosphorIconsRegular.user,
    AppIcon.themeToggle => PhosphorIconsRegular.circleHalf,
    AppIcon.search => PhosphorIconsRegular.magnifyingGlass,
    AppIcon.allFilter => PhosphorIconsRegular.infinity,
    AppIcon.emptyGlobe => PhosphorIconsRegular.globeX,
    AppIcon.species => PhosphorIconsRegular.dna,
    AppIcon.gender => PhosphorIconsRegular.genderIntersex,
    AppIcon.type => PhosphorIconsRegular.tag,
    AppIcon.origin => PhosphorIconsRegular.globe,
    AppIcon.location => PhosphorIconsRegular.mapPin,
    AppIcon.episodes => PhosphorIconsRegular.filmStrip,
  };
}
