import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soriana_character_explorer/core/presentation/theme_cubit.dart';
import 'package:soriana_character_explorer/features/characters/domain/character_repository.dart';
import 'package:soriana_character_explorer/features/characters/domain/entities.dart';
import 'package:soriana_character_explorer/features/characters/domain/use_cases.dart';
import 'package:soriana_character_explorer/features/characters/presentation/characters_bloc.dart';
import 'package:soriana_character_explorer/features/characters/presentation/pages/home_page.dart';
import 'package:soriana_character_explorer/features/favorites/domain/favorites_repository.dart';
import 'package:soriana_character_explorer/features/favorites/domain/favorites_use_cases.dart';
import 'package:soriana_character_explorer/features/favorites/presentation/favorites_cubit.dart';

class _CharacterRepository implements CharacterRepository {
  _CharacterRepository({this.deadPage, this.initialPage});

  final Completer<CharacterPage>? deadPage;
  final Completer<CharacterPage>? initialPage;

  @override
  Future<Character> getCharacter(int id) async => _character;

  @override
  Future<CharacterPage> getCharacters({
    int page = 1,
    String name = '',
    CharacterStatus? status,
  }) {
    if (page == 1 && name.isEmpty && status == null && initialPage != null) {
      return initialPage!.future;
    }
    if (status == CharacterStatus.alive) {
      return Future.value(CharacterPage([_aliveCharacter], false));
    }
    if (status == CharacterStatus.dead && deadPage != null)
      return deadPage!.future;
    return Future.value(CharacterPage([_character], false));
  }
}

class _FavoritesRepository implements FavoritesRepository {
  @override
  Future<Set<int>> read() async => {};

  @override
  Future<void> write(Set<int> ids) async {}
}

const _character = Character(
  id: 1,
  name: 'Rick',
  status: CharacterStatus.alive,
  species: 'Human',
  gender: 'Male',
  type: '',
  image: '',
  origin: CharacterLocation('Earth'),
  location: CharacterLocation('Earth'),
  episodeCount: 1,
);

const _aliveCharacter = Character(
  id: 2,
  name: 'Summer',
  status: CharacterStatus.alive,
  species: 'Human',
  gender: 'Female',
  type: '',
  image: '',
  origin: CharacterLocation('Earth'),
  location: CharacterLocation('Earth'),
  episodeCount: 1,
);

const _deadCharacter = Character(
  id: 3,
  name: 'Birdperson',
  status: CharacterStatus.dead,
  species: 'Alien',
  gender: 'Male',
  type: '',
  image: '',
  origin: CharacterLocation('Bird World'),
  location: CharacterLocation('Citadel'),
  episodeCount: 1,
);

void main() {
  Future<void> pumpHome(
    WidgetTester tester,
    double width, {
    bool disableAnimations = false,
    _CharacterRepository? repository,
    bool waitForInitialLoading = false,
  }) async {
    await tester.binding.setSurfaceSize(Size(width, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final characters = CharactersBloc(
      GetCharacters(repository ?? _CharacterRepository()),
    )..add(const CharactersStarted());
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(disableAnimations: disableAnimations),
          child: child!,
        ),
        home: MultiBlocProvider(
          providers: [
            BlocProvider<CharactersBloc>.value(value: characters),
            BlocProvider(
              create: (_) {
                final favorites = _FavoritesRepository();
                return FavoritesCubit(
                  LoadFavorites(favorites),
                  SaveFavorites(favorites),
                );
              },
            ),
            BlocProvider(create: (_) => ThemeCubit()),
          ],
          child: const HomePage(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    if (!waitForInitialLoading) {
      await tester.pump(const Duration(milliseconds: 350));
    }
    addTearDown(characters.close);
  }

  for (final expectation in <(double, int)>[(390, 1), (768, 2), (1280, 3)]) {
    testWidgets('uses ${expectation.$2} grid columns at ${expectation.$1}px', (
      tester,
    ) async {
      await pumpHome(tester, expectation.$1);

      final grid = tester.widget<SliverGrid>(find.byType(SliverGrid));
      final delegate =
          grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;

      expect(delegate.crossAxisCount, expectation.$2);
    });
  }

  testWidgets('keeps navigation and controls in the character scroll', (
    tester,
  ) async {
    await pumpHome(tester, 390);

    expect(find.byType(CustomScrollView), findsOneWidget);
    expect(find.byType(SliverAppBar), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(FilterChip), findsNWidgets(4));
  });

  testWidgets('keeps the initial loader visible through a fast response', (
    tester,
  ) async {
    final loadingSemantics = find.bySemanticsLabel(
      RegExp('Cargando personajes'),
    );
    final loadingOverlay = find.byWidgetPredicate(
      (widget) => widget is AbsorbPointer && widget.absorbing,
    );
    final initialPage = Completer<CharacterPage>();
    await pumpHome(
      tester,
      390,
      repository: _CharacterRepository(initialPage: initialPage),
      waitForInitialLoading: true,
    );

    expect(loadingSemantics, findsOneWidget);
    expect(loadingOverlay, findsOneWidget);

    initialPage.complete(CharacterPage([_character], false));
    await tester.pump();

    expect(loadingSemantics, findsOneWidget);
    expect(loadingOverlay, findsOneWidget);

    await tester.pump(const Duration(milliseconds: 350));
    expect(loadingSemantics, findsNothing);
    expect(
      find.byKey(const ValueKey('character-result-entry--all-1')),
      findsOneWidget,
    );
  });

  testWidgets('keeps the overlay while an initial request remains pending', (
    tester,
  ) async {
    final initialPage = Completer<CharacterPage>();
    await pumpHome(
      tester,
      390,
      repository: _CharacterRepository(initialPage: initialPage),
      waitForInitialLoading: true,
    );

    await tester.pump(const Duration(milliseconds: 350));

    expect(
      find.byWidgetPredicate(
        (widget) => widget is AbsorbPointer && widget.absorbing,
      ),
      findsOneWidget,
    );

    initialPage.complete(CharacterPage([_character], false));
    await tester.pump();
  });

  testWidgets('gives the newly selected filter a visible lift and pop', (
    tester,
  ) async {
    await pumpHome(tester, 390);

    await tester.tap(find.byType(FilterChip).at(1));
    await tester.pump();
    await tester.pump();

    final scales = tester
        .widgetList<AnimatedScale>(find.byType(AnimatedScale))
        .map((animation) => animation.scale)
        .toList(growable: false);
    expect(scales, contains(1.06));
    expect(
      tester
          .widgetList<AnimatedSlide>(find.byType(AnimatedSlide))
          .any((animation) => animation.offset == const Offset(0, -0.08)),
      isTrue,
    );
  });

  testWidgets('keeps filter transforms neutral when motion is disabled', (
    tester,
  ) async {
    await pumpHome(tester, 390, disableAnimations: true);

    await tester.tap(find.byType(FilterChip).at(1));
    await tester.pump();

    expect(
      tester
          .widgetList<AnimatedScale>(find.byType(AnimatedScale))
          .every((animation) => animation.scale == 1),
      isTrue,
    );
    expect(
      tester
          .widgetList<AnimatedSlide>(find.byType(AnimatedSlide))
          .every((animation) => animation.offset == Offset.zero),
      isTrue,
    );
  });

  testWidgets('swaps result identity immediately when motion is disabled', (
    tester,
  ) async {
    await pumpHome(tester, 390, disableAnimations: true);

    await tester.tap(find.byType(FilterChip).at(1));
    await tester.pump();
    await tester.pump();

    expect(
      find.byKey(const ValueKey('character-result-entry--all-1')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('character-result-entry--alive-2')),
      findsOneWidget,
    );
  });

  testWidgets('exits the old list before entering a replacement', (
    tester,
  ) async {
    await pumpHome(tester, 390);

    await tester.tap(find.byType(FilterChip).at(1));
    await tester.pump();
    await tester.pump();

    expect(
      find.byKey(const ValueKey('character-result-exit--all-1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('character-result-entry--alive-2')),
      findsNothing,
    );

    await tester.pump(const Duration(milliseconds: 379));
    expect(
      find.byKey(const ValueKey('character-result-entry--alive-2')),
      findsNothing,
    );

    await tester.pump(const Duration(milliseconds: 1));
    expect(
      find.byKey(const ValueKey('character-result-exit--all-1')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('character-result-entry--alive-2')),
      findsOneWidget,
    );
  });

  testWidgets('does not resurrect a pending result after a newer filter', (
    tester,
  ) async {
    final deadPage = Completer<CharacterPage>();
    await pumpHome(
      tester,
      390,
      repository: _CharacterRepository(deadPage: deadPage),
    );

    await tester.tap(find.byType(FilterChip).at(1));
    await tester.pump();
    await tester.pump();
    await tester.tap(find.byType(FilterChip).at(2));
    await tester.pump();
    await tester.pump();

    await tester.pump(const Duration(milliseconds: 380));
    expect(
      find.byKey(const ValueKey('character-result-entry--alive-2')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('character-result-entry--all-1')),
      findsNothing,
    );

    deadPage.complete(CharacterPage([_deadCharacter], false));
    await tester.pump();
    expect(
      find.byKey(const ValueKey('character-result-entry--dead-3')),
      findsOneWidget,
    );
  });

  testWidgets('cancels the exit callback when the grid is disposed', (
    tester,
  ) async {
    await pumpHome(tester, 390);
    await tester.tap(find.byType(FilterChip).at(1));
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.takeException(), isNull);
  });
}
