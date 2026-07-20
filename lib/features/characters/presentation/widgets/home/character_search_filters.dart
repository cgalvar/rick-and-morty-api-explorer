part of 'package:soriana_character_explorer/features/characters/presentation/pages/home_page.dart';

class _SearchAndFilters extends StatelessWidget {
  const _SearchAndFilters({
    required this.search,
    required this.bloc,
    required this.filters,
  });

  final TextEditingController search;
  final CharactersBloc bloc;
  final List<(CharacterStatus?, String)> filters;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final animationsDisabled = MediaQuery.disableAnimationsOf(context);
    final motionDuration = animationsDisabled
        ? Duration.zero
        : const Duration(milliseconds: 280);
    return SliverToBoxAdapter(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final gutter = constraints.maxWidth >= 1024
              ? 32.0
              : constraints.maxWidth >= 600
              ? 24.0
              : 16.0;
          final horizontalPadding = constraints.maxWidth > 1280
              ? ((constraints.maxWidth - 1280) / 2)
                    .clamp(gutter, double.infinity)
                    .toDouble()
              : gutter;
          return Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              8,
              horizontalPadding,
              4,
            ),
            child: Column(
              children: [
                Semantics(
                  textField: true,
                  label: 'Buscar personaje',
                  child: TextField(
                    controller: search,
                    onChanged: (value) => bloc.add(SearchChanged(value)),
                    decoration: InputDecoration(
                      hintText: 'Buscar personajes',
                      prefixIcon: Icon(AppIcons.resolve(AppIcon.search)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                BlocBuilder<CharactersBloc, CharactersState>(
                  buildWhen: (previous, current) =>
                      previous.status != current.status,
                  builder: (context, state) => SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: filters
                          .map(
                            (filter) => _FilterPill(
                              filter: filter,
                              selected: state.status == filter.$1,
                              colors: colors,
                              motionDuration: motionDuration,
                              animationsDisabled: animationsDisabled,
                              onSelected: () =>
                                  bloc.add(StatusChanged(filter.$1)),
                            ),
                          )
                          .toList(growable: false),
                    ),
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

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.filter,
    required this.selected,
    required this.colors,
    required this.motionDuration,
    required this.animationsDisabled,
    required this.onSelected,
  });

  final (CharacterStatus?, String) filter;
  final bool selected;
  final ColorScheme colors;
  final Duration motionDuration;
  final bool animationsDisabled;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: AnimatedSlide(
      duration: motionDuration,
      curve: Curves.easeOutCubic,
      offset: selected && !animationsDisabled
          ? const Offset(0, -0.08)
          : Offset.zero,
      child: AnimatedScale(
        duration: motionDuration,
        curve: Curves.easeOutBack,
        scale: selected && !animationsDisabled ? 1.06 : 1,
        child: FilterChip(
          avatar: filter.$1 == null
              ? Icon(AppIcons.resolve(AppIcon.allFilter), size: 16)
              : null,
          label: Text(filter.$2),
          selected: selected,
          onSelected: (_) => onSelected(),
          showCheckmark: false,
          selectedColor: colors.secondaryContainer,
          labelStyle: TextStyle(
            color: selected
                ? colors.onSecondaryContainer
                : colors.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ),
  );
}
