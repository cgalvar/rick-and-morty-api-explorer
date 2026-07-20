import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soriana_character_explorer/core/error/app_failure.dart';
import 'package:soriana_character_explorer/features/characters/data/character_remote_data_source.dart';
import 'package:soriana_character_explorer/features/characters/data/location_repository_impl.dart';
import 'package:soriana_character_explorer/features/characters/domain/entities.dart';

class _Source extends Mock implements CharacterRemoteDataSource {}

void main() {
  test('delegates location details and preserves failures', () async {
    final source = _Source();
    final repository = LocationRepositoryImpl(source);
    const location = LocationDetail(
      id: 20,
      name: 'Earth',
      type: 'Planet',
      dimension: 'Dimension C-137',
      residentCount: 4,
    );
    when(() => source.locationDetail(20)).thenAnswer((_) async => location);
    expect(await repository.getLocation(20), same(location));
    verify(() => source.locationDetail(20)).called(1);
    when(
      () => source.locationDetail(21),
    ).thenAnswer((_) async => throw const AppFailure(AppFailureKind.offline));
    await expectLater(repository.getLocation(21), throwsA(isA<AppFailure>()));
  });
}
