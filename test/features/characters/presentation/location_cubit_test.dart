import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soriana_character_explorer/core/error/app_failure.dart';
import 'package:soriana_character_explorer/features/characters/domain/entities.dart';
import 'package:soriana_character_explorer/features/characters/domain/use_cases.dart';
import 'package:soriana_character_explorer/features/characters/presentation/location_cubit.dart';

class _GetLocation extends Mock implements GetLocation {}

void main() {
  late _GetLocation getLocation;
  const location = LocationDetail(
    id: 20,
    name: 'Earth',
    type: 'Planet',
    dimension: 'Dimension C-137',
    residentCount: 4,
  );

  setUp(() => getLocation = _GetLocation());

  blocTest<LocationCubit, LocationState>(
    'loads a location',
    build: () {
      when(() => getLocation(20)).thenAnswer((_) async => location);
      return LocationCubit(getLocation);
    },
    act: (cubit) => cubit.load(20),
    expect: () => [
      isA<LocationState>().having((state) => state.loading, 'loading', true),
      isA<LocationState>()
          .having((state) => state.location, 'location', same(location))
          .having((state) => state.loading, 'loading', false),
    ],
  );

  blocTest<LocationCubit, LocationState>(
    'retries the same ID after an error',
    build: () {
      when(
        () => getLocation(20),
      ).thenAnswer((_) async => throw const AppFailure(AppFailureKind.offline));
      return LocationCubit(getLocation);
    },
    act: (cubit) async {
      await cubit.load(20);
      await cubit.retry();
    },
    verify: (_) => verify(() => getLocation(20)).called(2),
  );
}
