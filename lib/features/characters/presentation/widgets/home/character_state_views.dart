part of 'package:soriana_character_explorer/features/characters/presentation/pages/home_page.dart';

class _LoadingFieldGuide extends StatelessWidget {
  const _LoadingFieldGuide();

  @override
  Widget build(BuildContext context) => Center(
    child: Semantics(
      label: 'Cargando personajes',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 38,
            height: 38,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          const SizedBox(height: 16),
          Text(
            'Abriendo el portal…',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    ),
  );
}

class _EmptyFieldGuide extends StatelessWidget {
  const _EmptyFieldGuide();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Semantics(
        liveRegion: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              AppIcons.resolve(AppIcon.emptyGlobe),
              size: 48,
              color: colors.secondary,
            ),
            const SizedBox(height: 12),
            Text(
              'Sin resultados',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            const Text('No encontramos señales en este universo.'),
          ],
        ),
      ),
    );
  }
}
