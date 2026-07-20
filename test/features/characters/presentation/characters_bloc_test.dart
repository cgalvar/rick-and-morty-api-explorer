import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soriana_character_explorer/core/error/app_failure.dart';
import 'package:soriana_character_explorer/features/characters/domain/entities.dart';
import 'package:soriana_character_explorer/features/characters/domain/use_cases.dart';
import 'package:soriana_character_explorer/features/characters/presentation/characters_bloc.dart';

class _GetCharacters extends Mock implements GetCharacters {}

Character character(int id) => Character(
  id: id,
  name: 'Character $id',
  status: CharacterStatus.alive,
  species: 'Human',
  gender: 'Male',
  type: '',
  image: '',
  origin: const CharacterLocation('Earth'),
  location: const CharacterLocation('Earth'),
  episodeCount: 1,
);

void main() {
  late _GetCharacters getCharacters;

  setUpAll(() => registerFallbackValue(CharacterStatus.alive));
  setUp(() => getCharacters = _GetCharacters());

  test(
    'rapid searches cancel superseded debounces and execute only the latest query',
    () async {
      when(
        () => getCharacters(
          page: any(named: 'page'),
          name: any(named: 'name'),
          status: any(named: 'status'),
        ),
      ).thenAnswer((_) async => CharacterPage([], false));
      final bloc = CharactersBloc(getCharacters);

      bloc
        ..add(const SearchChanged('rick'))
        ..add(const SearchChanged('morty'));
      await Future<void>.delayed(const Duration(milliseconds: 600));

      verify(
        () => getCharacters(page: 1, name: 'morty', status: null),
      ).called(1);
      verifyNever(() => getCharacters(page: 1, name: 'rick', status: null));
      await bloc.close();
    },
  );

  test('a status selection combines with the current search query', () async {
    when(
      () => getCharacters(
        page: any(named: 'page'),
        name: any(named: 'name'),
        status: any(named: 'status'),
      ),
    ).thenAnswer((_) async => CharacterPage([], false));
    final bloc = CharactersBloc(getCharacters);

    bloc.add(const SearchChanged('rick'));
    await Future<void>.delayed(const Duration(milliseconds: 600));
    bloc.add(const StatusChanged(CharacterStatus.alive));
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state.query, 'rick');
    expect(bloc.state.status, CharacterStatus.alive);
    verify(
      () => getCharacters(page: 1, name: 'rick', status: CharacterStatus.alive),
    ).called(1);
    await bloc.close();
  });

  test(
    'duplicate next-page events are guarded while a request is in flight',
    () async {
      final pending = Completer<CharacterPage>();
      when(() => getCharacters(page: 1, name: '', status: null)).thenAnswer(
        (_) async => CharacterPage(List.generate(20, character), true),
      );
      when(
        () => getCharacters(page: 2, name: '', status: null),
      ).thenAnswer((_) => pending.future);
      final bloc = CharactersBloc(getCharacters);

      bloc.add(const CharactersStarted());
      await Future<void>.delayed(Duration.zero);
      bloc
        ..add(const NextPageRequested())
        ..add(const NextPageRequested());
      await Future<void>.delayed(Duration.zero);

      verify(() => getCharacters(page: 2, name: '', status: null)).called(1);
      pending.complete(CharacterPage([], false));
      await Future<void>.delayed(Duration.zero);
      await bloc.close();
    },
  );

  test(
    'refresh clears an interrupted page load and pagination can continue',
    () async {
      final initialItems = List.generate(20, character);
      final refreshedItems = List.generate(
        20,
        (index) => character(index + 21),
      );
      final appendedItems = List.generate(20, (index) => character(index + 41));
      final stalePage = Completer<CharacterPage>();
      var firstPageCalls = 0;
      var secondPageCalls = 0;
      when(() => getCharacters(page: 1, name: '', status: null)).thenAnswer((
        _,
      ) async {
        firstPageCalls++;
        return CharacterPage(
          firstPageCalls == 1 ? initialItems : refreshedItems,
          true,
        );
      });
      when(() => getCharacters(page: 2, name: '', status: null)).thenAnswer((
        _,
      ) {
        secondPageCalls++;
        return secondPageCalls == 1
            ? stalePage.future
            : Future.value(CharacterPage(appendedItems, false));
      });
      final bloc = CharactersBloc(getCharacters);

      bloc.add(const CharactersStarted());
      await Future<void>.delayed(Duration.zero);
      bloc.add(const NextPageRequested());
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.loadingMore, isTrue);

      bloc.add(const RefreshRequested());
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.items, refreshedItems);
      expect(bloc.state.loadingMore, isFalse);

      stalePage.complete(CharacterPage([character(999)], false));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.items, refreshedItems);

      bloc.add(const NextPageRequested());
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.items, [...refreshedItems, ...appendedItems]);
      expect(bloc.state.loadingMore, isFalse);
      verify(() => getCharacters(page: 2, name: '', status: null)).called(2);
      await bloc.close();
    },
  );

  test(
    'a failed next page preserves results and an explicit retry appends it',
    () async {
      final firstPage = List.generate(20, character);
      final secondPage = List.generate(20, (index) => character(index + 21));
      var pageTwoAttempts = 0;
      when(
        () => getCharacters(page: 1, name: '', status: null),
      ).thenAnswer((_) async => CharacterPage(firstPage, true));
      when(() => getCharacters(page: 2, name: '', status: null)).thenAnswer((
        _,
      ) async {
        pageTwoAttempts++;
        if (pageTwoAttempts == 1)
          throw const AppFailure(AppFailureKind.unexpected);
        return CharacterPage(secondPage, false);
      });
      final bloc = CharactersBloc(getCharacters);

      bloc.add(const CharactersStarted());
      await Future<void>.delayed(Duration.zero);
      bloc.add(const NextPageRequested());
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.items, firstPage);
      expect(bloc.state.error, 'Ocurrió un error inesperado.');
      expect(bloc.state.loadingMore, isFalse);

      bloc.add(const NextPageRequested());
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.items, [...firstPage, ...secondPage]);
      expect(bloc.state.error, isNull);
      expect(bloc.state.hasNext, isFalse);
      verify(() => getCharacters(page: 2, name: '', status: null)).called(2);
      await bloc.close();
    },
  );

  test('refresh and retry request using active filters', () async {
    when(
      () => getCharacters(
        page: any(named: 'page'),
        name: any(named: 'name'),
        status: any(named: 'status'),
      ),
    ).thenAnswer((_) async => CharacterPage([], false));
    final bloc = CharactersBloc(getCharacters);

    bloc.add(const SearchChanged('rick'));
    await Future<void>.delayed(const Duration(milliseconds: 600));
    bloc.add(const StatusChanged(CharacterStatus.alive));
    await Future<void>.delayed(Duration.zero);
    bloc
      ..add(const RefreshRequested())
      ..add(const RetryRequested());
    await Future<void>.delayed(Duration.zero);

    verify(
      () => getCharacters(page: 1, name: 'rick', status: CharacterStatus.alive),
    ).called(greaterThanOrEqualTo(3));
    await bloc.close();
  });

  test(
    'refresh future waits for the active request and completes on success',
    () async {
      final pending = Completer<CharacterPage>();
      when(
        () => getCharacters(page: 1, name: '', status: null),
      ).thenAnswer((_) => pending.future);
      final bloc = CharactersBloc(getCharacters);

      final refresh = bloc.refresh();
      var completed = false;
      refresh.then((_) => completed = true);
      await Future<void>.delayed(Duration.zero);
      expect(completed, isFalse);

      pending.complete(CharacterPage([], false));
      await refresh;
      expect(bloc.state.loading, isFalse);
      await bloc.close();
    },
  );

  test(
    'refresh future completes after a typed failure and exposes its message',
    () async {
      when(
        () => getCharacters(page: 1, name: '', status: null),
      ).thenThrow(const AppFailure(AppFailureKind.offline));
      final bloc = CharactersBloc(getCharacters);

      await bloc.refresh();

      expect(bloc.state.error, 'Sin conexión. Revisa tu red.');
      await bloc.close();
    },
  );

  test('a newer refresh completes a superseded pending refresh', () async {
    final first = Completer<CharacterPage>();
    var calls = 0;
    when(() => getCharacters(page: 1, name: '', status: null)).thenAnswer((_) {
      calls++;
      return calls == 1 ? first.future : Future.value(CharacterPage([], false));
    });
    final bloc = CharactersBloc(getCharacters);

    final stale = bloc.refresh();
    await Future<void>.delayed(Duration.zero);
    final latest = bloc.refresh();
    await stale;
    await latest;

    expect(bloc.state.loading, isFalse);
    first.complete(CharacterPage([], false));
    await bloc.close();
  });

  test('uses explicit ready, empty, and failed primary states', () async {
    when(
      () => getCharacters(page: 1, name: '', status: null),
    ).thenAnswer((_) async => CharacterPage([character(1)], false));
    final bloc = CharactersBloc(getCharacters);

    bloc.add(const CharactersStarted());
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.phase, CharactersLoadState.ready);

    when(
      () => getCharacters(page: 1, name: '', status: null),
    ).thenAnswer((_) async => CharacterPage([], false));
    await bloc.refresh();
    expect(bloc.state.phase, CharactersLoadState.empty);

    when(
      () => getCharacters(page: 1, name: '', status: null),
    ).thenThrow(const AppFailure(AppFailureKind.offline));
    await bloc.refresh();
    expect(bloc.state.phase, CharactersLoadState.failed);
    await bloc.close();
  });
}
