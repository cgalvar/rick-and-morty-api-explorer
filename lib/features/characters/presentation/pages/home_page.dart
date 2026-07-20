import 'dart:async';
import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/presentation/app_icon_set.dart';
import '../../../../core/router/app_router.dart';
import '../../domain/entities.dart';
import '../characters_bloc.dart';
import '../widgets.dart';
import '../../../favorites/presentation/favorites_cubit.dart';
import '../../../theme/presentation/theme_cubit.dart';

part '../widgets/home/character_results_grid.dart';
part '../widgets/home/character_search_filters.dart';
part '../widgets/home/character_state_views.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final search = TextEditingController();
  Timer? _initialLoadingTimer;
  late bool _initialLoadingMinimumElapsed;

  @override
  void initState() {
    super.initState();
    final initialState = context.read<CharactersBloc>().state;
    _initialLoadingMinimumElapsed =
        !(initialState.loading && initialState.items.isEmpty);
    if (!_initialLoadingMinimumElapsed) {
      _initialLoadingTimer = Timer(const Duration(milliseconds: 350), () {
        if (mounted) setState(() => _initialLoadingMinimumElapsed = true);
      });
    }
  }

  @override
  void dispose() {
    _initialLoadingTimer?.cancel();
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CharactersBloc>();
    const filters = <(CharacterStatus?, String)>[
      (null, 'Todos'),
      (CharacterStatus.alive, 'Alive'),
      (CharacterStatus.dead, 'Dead'),
      (CharacterStatus.unknown, 'Unknown'),
    ];
    return Scaffold(
      body: BlocListener<FavoritesCubit, FavoritesState>(
        listenWhen: (previous, current) =>
            current.error != null && previous.error != current.error,
        listener: (context, state) => ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.error!))),
        child: BlocBuilder<CharactersBloc, CharactersState>(
          builder: (context, state) {
            final showLoading =
                (state.loading && state.items.isEmpty) ||
                !_initialLoadingMinimumElapsed;
            return Stack(
              children: [
                RefreshIndicator(
                  onRefresh: bloc.refresh,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      _appBar(context),
                      _SearchAndFilters(
                        search: search,
                        bloc: bloc,
                        filters: filters,
                      ),
                      ..._contentSlivers(context, state, bloc),
                    ],
                  ),
                ),
                if (showLoading)
                  Positioned.fill(
                    child: AbsorbPointer(
                      child: ColoredBox(
                        color: Theme.of(context).colorScheme.surface,
                        child: const _LoadingFieldGuide(),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  SliverAppBar _appBar(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final headerSurface = DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.82),
        border: Border(
          bottom: BorderSide(
            color: colors.outlineVariant.withValues(alpha: 0.56),
          ),
        ),
      ),
      child: const FlexibleSpaceBar(
        titlePadding: EdgeInsetsDirectional.only(
          start: 16,
          end: 72,
          bottom: 16,
        ),
        title: Text('Personajes'),
      ),
    );
    return SliverAppBar(
      pinned: true,
      expandedHeight: 104,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      actions: [
        IconButton.filledTonal(
          tooltip: 'Cambiar tema',
          onPressed: () => context.read<ThemeCubit>().toggle(),
          icon: Icon(AppIcons.resolve(AppIcon.themeToggle)),
        ),
        const SizedBox(width: 12),
      ],
      flexibleSpace: ClipRect(
        child: kIsWeb
            ? headerSurface
            : BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: headerSurface,
              ),
      ),
    );
  }

  List<Widget> _contentSlivers(
    BuildContext context,
    CharactersState state,
    CharactersBloc bloc,
  ) {
    if (state.loading && state.items.isEmpty) {
      return const [SliverFillRemaining(child: SizedBox.shrink())];
    }
    if (state.error != null && state.items.isEmpty) {
      return [
        SliverFillRemaining(
          child: AsyncStateView(
            message: state.error!,
            onRetry: () => bloc.add(const RetryRequested()),
          ),
        ),
      ];
    }
    if (state.empty)
      return const [SliverFillRemaining(child: _EmptyFieldGuide())];
    return [
      SliverLayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.crossAxisExtent;
          final columns = width >= 1024
              ? 3
              : width >= 600
              ? 2
              : 1;
          final gutter = width >= 1024
              ? 32.0
              : width >= 600
              ? 24.0
              : 16.0;
          final horizontalPadding = width > 1280
              ? ((width - 1280) / 2).clamp(gutter, double.infinity).toDouble()
              : gutter;
          return SliverPadding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              8,
              horizontalPadding,
              gutter,
            ),
            sliver: _AnimatedResultsGrid(
              key: const ValueKey('animated-results-grid'),
              items: state.items,
              query: state.query,
              status: state.status,
              loading: state.loading,
              loadingMore: state.loadingMore,
              paginationError: state.items.isEmpty ? null : state.error,
              loadingStates: bloc.stream.map((state) => state.loading),
              onLoadMore: () => bloc.add(const NextPageRequested()),
              onRetry: () => bloc.add(const NextPageRequested()),
              onOpen: (character) => context.router.push(
                CharacterDetailRoute(
                  id: character.id,
                  initialCharacter: character,
                ),
              ),
              columns: columns,
            ),
          );
        },
      ),
    ];
  }
}
