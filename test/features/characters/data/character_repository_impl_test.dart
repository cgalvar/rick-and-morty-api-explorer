import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soriana_character_explorer/core/error/app_failure.dart';
import 'package:soriana_character_explorer/features/characters/data/character_remote_data_source.dart';
import 'package:soriana_character_explorer/features/characters/data/character_repository_impl.dart';
import 'package:soriana_character_explorer/features/characters/domain/entities.dart';

class _Source extends Mock implements CharacterRemoteDataSource {}

void main() {
  late _Source source;
  late CharacterRepositoryImpl repository;
  final page = CharacterPage([], true);

  setUp(() {
    source = _Source();
    repository = CharacterRepositoryImpl(source);
  });

  test('returns the remote page on success', () async {
    when(
      () => source.list(page: 3, name: 'rick', status: CharacterStatus.alive),
    ).thenAnswer((_) async => page);

    expect(
      await repository.getCharacters(
        page: 3,
        name: 'rick',
        status: CharacterStatus.alive,
      ),
      same(page),
    );
  });

  test('turns a list 404 into an empty page', () async {
    when(
      () => source.list(
        page: any(named: 'page'),
        name: any(named: 'name'),
        status: any(named: 'status'),
      ),
    ).thenThrow(const NotFoundFailure(AppFailureKind.charactersNotFound));

    final result = await repository.getCharacters();

    expect(result.items, isEmpty);
    expect(result.hasNext, isFalse);
  });

  test('keeps detail 404 and transport failures visible to callers', () async {
    when(() => source.detail(7)).thenAnswer(
      (_) async =>
          throw const NotFoundFailure(AppFailureKind.charactersNotFound),
    );
    await expectLater(
      repository.getCharacter(7),
      throwsA(isA<NotFoundFailure>()),
    );
    when(
      () => source.detail(8),
    ).thenAnswer((_) async => throw const AppFailure(AppFailureKind.offline));
    await expectLater(repository.getCharacter(8), throwsA(isA<AppFailure>()));
  });
}
