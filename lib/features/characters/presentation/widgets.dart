import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/presentation/app_icon_set.dart';
import '../../favorites/presentation/favorites_cubit.dart';
import '../domain/entities.dart';

extension CharacterStatusLabel on CharacterStatus {
  String get label => switch (this) {
    CharacterStatus.alive => 'Alive',
    CharacterStatus.dead => 'Dead',
    CharacterStatus.unknown => 'Unknown',
  };
}

class AsyncStateView extends StatelessWidget {
  const AsyncStateView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Semantics(
        liveRegion: true,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 360),
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest.withValues(alpha: 0.74),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: colors.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: 0.12),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                AppIcons.resolve(AppIcon.lostSignal),
                color: colors.secondary,
                size: 42,
              ),
              const SizedBox(height: 16),
              Text(
                'Señal interdimensional perdida',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onRetry,
                icon: Icon(AppIcons.resolve(AppIcon.retry)),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final CharacterStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final (color, background) = switch (status) {
      CharacterStatus.alive => (colors.tertiary, colors.tertiaryContainer),
      CharacterStatus.dead => (colors.error, colors.errorContainer),
      CharacterStatus.unknown => (
        colors.outline,
        colors.surfaceContainerHighest,
      ),
    };
    return Semantics(
      label: 'Estado: ${status.label}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              AppIcons.resolve(AppIcon.statusIndicator),
              color: color,
              size: 9,
            ),
            const SizedBox(width: 6),
            Text(
              status.label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CharacterCard extends StatelessWidget {
  const CharacterCard({
    super.key,
    required this.character,
    required this.onOpen,
  });

  final Character character;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final motionDuration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 220);
    return Semantics(
      button: true,
      label:
          '${character.name}, ${character.status.label}, ${character.species}',
      child: AnimatedContainer(
        duration: motionDuration,
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.surfaceContainerHighest.withValues(alpha: 0.92),
              colors.surface.withValues(alpha: 0.9),
            ],
          ),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.8),
          ),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: onOpen,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _CharacterThumbnail(character: character, size: 104),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          character.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                              ),
                        ),
                        const SizedBox(height: 8),
                        StatusBadge(status: character.status),
                        const SizedBox(height: 8),
                        Text(
                          '${character.species} · ${character.gender}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  BlocBuilder<FavoritesCubit, FavoritesState>(
                    builder: (context, state) {
                      final selected = state.ids.contains(character.id);
                      final favoriteIcon = AppIcons.resolve(
                        selected
                            ? AppIcon.favoriteSelected
                            : AppIcon.favoriteUnselected,
                      );
                      return Semantics(
                        label: selected
                            ? 'Quitar ${character.name} de favoritos'
                            : 'Agregar ${character.name} a favoritos',
                        button: true,
                        child: IconButton.filledTonal(
                          tooltip: 'Favorito',
                          onPressed: () => context
                              .read<FavoritesCubit>()
                              .toggle(character.id),
                          icon: Icon(favoriteIcon),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CharacterThumbnail extends StatelessWidget {
  const _CharacterThumbnail({required this.character, required this.size});

  final Character character;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Hero(
      tag: 'character-${character.id}',
      child: Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [colors.secondary, colors.primary, colors.tertiary],
          ),
          boxShadow: [
            BoxShadow(
              color: colors.secondary.withValues(alpha: 0.24),
              blurRadius: 16,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: character.image,
            fit: BoxFit.cover,
            placeholder: (context, imageUrl) => Shimmer.fromColors(
              baseColor: colors.surfaceContainerHighest,
              highlightColor: colors.surface,
              child: const ColoredBox(color: Colors.white),
            ),
            errorWidget: (context, imageUrl, error) => ColoredBox(
              color: colors.primaryContainer,
              child: Icon(
                AppIcons.resolve(AppIcon.userPlaceholder),
                color: colors.onPrimaryContainer,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
