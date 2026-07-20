import 'package:chopper/chopper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:soriana_character_explorer/core/error/app_failure.dart';
import 'package:soriana_character_explorer/features/characters/data/character_remote_data_source.dart';
import 'package:soriana_character_explorer/features/characters/data/rick_and_morty_api_service.dart';
import 'package:soriana_character_explorer/features/characters/data/location_api_service.dart';
import 'package:soriana_character_explorer/features/characters/domain/entities.dart';

class _Service extends Mock implements RickAndMortyApiService {}

class _LocationService extends Mock implements LocationApiService {}

void main() {
  late _Service service;
  late _LocationService locationService;
  late CharacterRemoteDataSource source;
  final character = <String, dynamic>{
    'id': 1,
    'name': 'Rick',
    'status': 'Alive',
    'species': 'Human',
    'gender': 'Male',
    'type': '',
    'image': 'https://image',
    'origin': {
      'name': 'Earth',
      'url': 'https://rickandmortyapi.com/api/location/1',
    },
    'location': {
      'name': 'Citadel',
      'url': 'https://rickandmortyapi.com/api/location/3',
    },
    'episode': ['episode/1', 'episode/2'],
  };

  setUp(() {
    service = _Service();
    locationService = _LocationService();
    source = CharacterRemoteDataSource(service, locationService);
  });

  test('maps a page and sends active query parameters', () async {
    when(() => service.list(page: 2, name: 'rick', status: 'alive')).thenAnswer(
      (_) async => Response(http.Response('', 200), {
        'info': {'next': 'next'},
        'results': [character],
      }),
    );

    final page = await source.list(
      page: 2,
      name: 'rick',
      status: CharacterStatus.alive,
    );

    expect(page.hasNext, isTrue);
    expect(page.items.single.name, 'Rick');
    expect(page.items.single.episodeCount, 2);
    expect(page.items.single.origin.id, 1);
    expect(page.items.single.location.id, 3);
    verify(
      () => service.list(page: 2, name: 'rick', status: 'alive'),
    ).called(1);
  });

  test('does not create location IDs from blank or malformed URLs', () async {
    final malformed = Map<String, dynamic>.from(character)
      ..['origin'] = {'name': 'Earth', 'url': ''}
      ..['location'] = {'name': 'Citadel', 'url': 'https://api.test/planet/3'};
    when(
      () => service.detail(1),
    ).thenAnswer((_) async => Response(http.Response('', 200), malformed));

    final result = await source.detail(1);

    expect(result.origin.id, isNull);
    expect(result.location.id, isNull);
  });

  test('maps a location detail and its resident count', () async {
    when(() => locationService.detail(20)).thenAnswer(
      (_) async => Response(http.Response('', 200), {
        'id': 20,
        'name': 'Earth (Replacement Dimension)',
        'type': 'Planet',
        'dimension': 'Replacement Dimension',
        'residents': ['a', 'b'],
      }),
    );

    final location = await source.locationDetail(20);

    expect(location.name, 'Earth (Replacement Dimension)');
    expect(location.type, 'Planet');
    expect(location.dimension, 'Replacement Dimension');
    expect(location.residentCount, 2);
  });

  test('maps a malformed successful list payload to invalidResponse', () async {
    when(() => service.list(page: 1, name: null, status: null)).thenAnswer(
      (_) async => Response(http.Response('', 200), <String, dynamic>{
        'info': <String, dynamic>{},
      }),
    );

    await expectLater(
      source.list(page: 1, name: '', status: null),
      throwsA(
        isA<AppFailure>().having(
          (failure) => failure.kind,
          'kind',
          AppFailureKind.invalidResponse,
        ),
      ),
    );
  });

  test(
    'maps a malformed successful detail payload to invalidResponse',
    () async {
      when(
        () => service.detail(1),
      ).thenAnswer((_) async => Response(http.Response('', 200), {'id': 1}));

      await expectLater(
        source.detail(1),
        throwsA(
          isA<AppFailure>().having(
            (failure) => failure.kind,
            'kind',
            AppFailureKind.invalidResponse,
          ),
        ),
      );
    },
  );

  test(
    'maps a malformed successful location payload to invalidResponse',
    () async {
      when(
        () => locationService.detail(20),
      ).thenAnswer((_) async => Response(http.Response('', 200), {'id': 20}));

      await expectLater(
        source.locationDetail(20),
        throwsA(
          isA<AppFailure>().having(
            (failure) => failure.kind,
            'kind',
            AppFailureKind.invalidResponse,
          ),
        ),
      );
    },
  );

  test('maps non-string successful map keys to invalidResponse', () async {
    when(() => service.list(page: 1, name: null, status: null)).thenAnswer(
      (_) async => Response(http.Response('', 200), <String, dynamic>{
        'info': <dynamic, dynamic>{1: 'bad'},
        'results': <dynamic>[],
      }),
    );

    await expectLater(
      source.list(page: 1, name: '', status: null),
      throwsA(
        isA<AppFailure>().having(
          (failure) => failure.kind,
          'kind',
          AppFailureKind.invalidResponse,
        ),
      ),
    );
  });

  test('keeps a location 404 as a recoverable NotFoundFailure', () async {
    when(
      () => locationService.detail(20),
    ).thenAnswer((_) async => Response(http.Response('', 404), null));

    await expectLater(
      source.locationDetail(20),
      throwsA(
        isA<NotFoundFailure>().having(
          (failure) => failure.kind,
          'kind',
          AppFailureKind.locationNotFound,
        ),
      ),
    );
  });

  test('maps a 404 to NotFoundFailure', () async {
    when(
      () => service.list(page: 1, name: null, status: null),
    ).thenAnswer((_) async => Response(http.Response('', 404), null));

    await expectLater(
      source.list(page: 1, name: '', status: null),
      throwsA(isA<NotFoundFailure>()),
    );
  });

  test('keeps a detail 404 as NotFoundFailure', () async {
    when(
      () => service.detail(1),
    ).thenAnswer((_) async => Response(http.Response('', 404), null));

    await expectLater(source.detail(1), throwsA(isA<NotFoundFailure>()));
  });

  test('maps transport failures to a user-facing AppFailure', () async {
    when(
      () => service.list(page: 1, name: null, status: null),
    ).thenThrow(http.ClientException('network unavailable'));

    await expectLater(
      source.list(page: 1, name: '', status: null),
      throwsA(
        isA<AppFailure>().having(
          (failure) => failure.kind,
          'kind',
          AppFailureKind.offline,
        ),
      ),
    );
  });
}
