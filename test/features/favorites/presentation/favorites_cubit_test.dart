import 'package:bloc_test/bloc_test.dart';
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soriana_character_explorer/features/favorites/domain/favorites_repository.dart';
import 'package:soriana_character_explorer/features/favorites/domain/favorites_use_cases.dart';
import 'package:soriana_character_explorer/features/favorites/presentation/favorites_cubit.dart';

class _FavoritesRepository extends Mock implements FavoritesRepository {}

void main() {
  late _FavoritesRepository repository;

  setUp(() => repository = _FavoritesRepository());

  FavoritesCubit buildCubit() =>
      FavoritesCubit(LoadFavorites(repository), SaveFavorites(repository));

  blocTest<FavoritesCubit, FavoritesState>(
    'loads IDs and writes a toggled favorite',
    build: () {
      when(() => repository.read()).thenAnswer((_) async => {1});
      when(() => repository.write(any())).thenAnswer((_) async {});
      return buildCubit();
    },
    act: (cubit) async {
      await cubit.load();
      await cubit.toggle(2);
    },
    expect: () => [
      isA<FavoritesState>().having((state) => state.ids, 'ids', {1}),
      isA<FavoritesState>().having((state) => state.ids, 'ids', {1, 2}),
    ],
    verify: (_) => verify(() => repository.write({1, 2})).called(1),
  );

  blocTest<FavoritesCubit, FavoritesState>(
    'keeps old IDs and exposes an error when persistence fails',
    build: () {
      when(() => repository.write(any())).thenThrow(Exception('disk full'));
      return buildCubit();
    },
    seed: () => FavoritesState({1}),
    act: (cubit) => cubit.toggle(2),
    expect: () => [
      isA<FavoritesState>()
          .having((state) => state.ids, 'ids', {1})
          .having((state) => state.error, 'error', isNotNull),
    ],
  );

  blocTest<FavoritesCubit, FavoritesState>(
    'keeps existing IDs and exposes an error when loading fails',
    build: () {
      when(() => repository.read()).thenThrow(Exception('read failed'));
      return buildCubit();
    },
    seed: () => FavoritesState({1}),
    act: (cubit) => cubit.load(),
    expect: () => [
      isA<FavoritesState>()
          .having((state) => state.ids, 'ids', {1})
          .having((state) => state.error, 'error', isNotNull),
    ],
  );

  test('rapid toggles are queued and persist every intended state', () async {
    final firstWrite = Completer<void>();
    when(() => repository.write({1})).thenAnswer((_) => firstWrite.future);
    when(() => repository.write({1, 2})).thenAnswer((_) async {});
    final cubit = buildCubit();

    final one = cubit.toggle(1);
    final two = cubit.toggle(2);
    await Future<void>.delayed(Duration.zero);
    verify(() => repository.write({1})).called(1);
    firstWrite.complete();
    await Future.wait([one, two]);

    expect(cubit.state.ids, {1, 2});
    verify(() => repository.write({1, 2})).called(1);
    await cubit.close();
  });

  test('load then toggle executes in invocation order', () async {
    final pendingRead = Completer<Set<int>>();
    when(() => repository.read()).thenAnswer((_) => pendingRead.future);
    when(() => repository.write({1, 2})).thenAnswer((_) async {});
    final cubit = buildCubit();

    final load = cubit.load();
    final toggle = cubit.toggle(2);
    await Future<void>.delayed(Duration.zero);
    verify(() => repository.read()).called(1);
    verifyNever(() => repository.write(any()));
    pendingRead.complete({1});
    await Future.wait([load, toggle]);

    expect(cubit.state.ids, {1, 2});
    verify(() => repository.write({1, 2})).called(1);
    await cubit.close();
  });
}
