import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/presentation/app_icon_set.dart';
import '../../../../core/router/app_router.dart';
import '../../domain/entities.dart';
import '../../domain/use_cases.dart';
import '../detail_cubit.dart';
import '../widgets.dart';
import '../../../favorites/presentation/favorites_cubit.dart';

@RoutePage()
class CharacterDetailPage extends StatelessWidget {
  const CharacterDetailPage({
    super.key,
    @PathParam('id') required this.id,
    this.initialCharacter,
  });

  final int id;
  final Character? initialCharacter;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) => DetailCubit(context.read<GetCharacter>())..load(id),
    child: Scaffold(
      appBar: AppBar(
        title: BlocBuilder<DetailCubit, DetailState>(
          builder: (_, state) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(state.character?.name ?? initialCharacter?.name ?? 'Perfil'),
              const Text(
                'ARCHIVO DE PERSONAJE',
                style: TextStyle(fontSize: 10),
              ),
            ],
          ),
        ),
      ),
      body: BlocBuilder<DetailCubit, DetailState>(
        builder: (context, state) {
          if (state.loading && initialCharacter == null) {
            return const _DetailLoading();
          }
          if (state.error != null) {
            return AsyncStateView(
              message: state.error!,
              onRetry: () => context.read<DetailCubit>().load(id),
            );
          }
          return _CharacterProfile(
            character: state.character ?? initialCharacter!,
          );
        },
      ),
    ),
  );
}

class _CharacterProfile extends StatelessWidget {
  const _CharacterProfile({required this.character});

  final Character character;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: const Alignment(0, .45),
          colors: [
            colors.primaryContainer.withValues(alpha: 0.48),
            colors.surface,
          ],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 600;
          final padding = constraints.maxWidth >= 1024
              ? 32.0
              : wide
              ? 24.0
              : 16.0;
          final imageSize = wide ? 330.0 : 252.0;
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(padding, 16, padding, 36),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: wide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _PortalPortrait(
                            character: character,
                            size: imageSize,
                          ),
                          const SizedBox(width: 32),
                          Expanded(child: _ProfilePanel(character: character)),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                            child: _PortalPortrait(
                              character: character,
                              size: imageSize,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _ProfilePanel(character: character),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PortalPortrait extends StatelessWidget {
  const _PortalPortrait({required this.character, required this.size});

  final Character character;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Hero(
      tag: 'character-${character.id}',
      child: Semantics(
        image: true,
        label: 'Retrato de ${character.name}',
        child: Container(
          width: size,
          height: size,
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
              colors: [
                colors.secondary,
                colors.tertiary,
                colors.primary,
                colors.secondary,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: colors.secondary.withValues(alpha: 0.3),
                blurRadius: 32,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.surface,
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
                    size: 88,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfilePanel extends StatelessWidget {
  const _ProfilePanel({required this.character});

  final Character character;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SUJETO #${character.id.toString().padLeft(3, '0')}',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colors.secondary,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            character.name,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 12),
          StatusBadge(status: character.status),
          const SizedBox(height: 24),
          _FactGrid(character: character),
          const SizedBox(height: 24),
          _LocationLinks(character: character),
          const SizedBox(height: 24),
          BlocBuilder<FavoritesCubit, FavoritesState>(
            builder: (context, favorites) {
              final favorite = favorites.ids.contains(character.id);
              final favoriteIcon = AppIcons.resolve(
                favorite
                    ? AppIcon.favoriteSelected
                    : AppIcon.favoriteUnselected,
              );
              return Semantics(
                button: true,
                label: favorite ? 'Quitar de favoritos' : 'Agregar a favoritos',
                child: FilledButton.icon(
                  onPressed: () =>
                      context.read<FavoritesCubit>().toggle(character.id),
                  icon: Icon(favoriteIcon),
                  label: Text(
                    favorite ? 'Guardado en favoritos' : 'Guardar en favoritos',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LocationLinks extends StatelessWidget {
  const _LocationLinks({required this.character});

  final Character character;

  @override
  Widget build(BuildContext context) {
    final links = [
      ('Ver origen', character.origin),
      ('Ver ubicación actual', character.location),
    ].where((link) => link.$2.id != null).toList(growable: false);
    if (links.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final link in links)
          OutlinedButton.icon(
            onPressed: () =>
                context.router.push(LocationDetailRoute(id: link.$2.id!)),
            icon: Icon(AppIcons.resolve(AppIcon.location)),
            label: Text(link.$1),
          ),
      ],
    );
  }
}

class _FactGrid extends StatelessWidget {
  const _FactGrid({required this.character});

  final Character character;

  @override
  Widget build(BuildContext context) {
    final facts = <(IconData, String, String)>[
      (AppIcons.resolve(AppIcon.species), 'Especie', character.species),
      (AppIcons.resolve(AppIcon.gender), 'Género', character.gender),
      if (character.type.isNotEmpty)
        (AppIcons.resolve(AppIcon.type), 'Tipo', character.type),
      (AppIcons.resolve(AppIcon.origin), 'Origen', character.origin.name),
      (
        AppIcons.resolve(AppIcon.location),
        'Ubicación actual',
        character.location.name,
      ),
      (
        AppIcons.resolve(AppIcon.episodes),
        'Episodios',
        '${character.episodeCount} registrados',
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: facts.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: constraints.maxWidth >= 500 ? 2 : 1,
          childAspectRatio: constraints.maxWidth >= 500 ? 3.1 : 4.4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (context, index) {
          final fact = facts[index];
          final colors = Theme.of(context).colorScheme;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withValues(alpha: 0.62),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Icon(fact.$1, color: colors.secondary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fact.$2.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        fact.$3,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DetailLoading extends StatelessWidget {
  const _DetailLoading();

  @override
  Widget build(BuildContext context) => Center(
    child: Semantics(
      label: 'Cargando perfil del personaje',
      child: const CircularProgressIndicator(),
    ),
  );
}
