import 'dart:async';

import 'package:chopper/chopper.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import '../../../core/error/app_failure.dart';
import '../domain/entities.dart';
import 'location_api_service.dart';
import 'rick_and_morty_api_service.dart';

@injectable
class CharacterRemoteDataSource {
  CharacterRemoteDataSource(this._service, this._locationService);
  final RickAndMortyApiService _service;
  final LocationApiService _locationService;

  Future<CharacterPage> list({
    required int page,
    required String name,
    required CharacterStatus? status,
  }) => _guard(() async {
    final response = await _service
        .list(
          page: page,
          name: name.isEmpty ? null : name,
          status: status?.name,
        )
        .timeout(const Duration(seconds: 10));
    if (!response.isSuccessful) throw _failure(response.statusCode);
    final body = _mapValue(response.body);
    final results = _list(body['results']);
    final info = _mapValue(body['info']);
    return CharacterPage(
      results.map((item) => _character(_mapValue(item))).toList(),
      info['next'] != null,
    );
  });

  Future<Character> detail(int id) => _guard(() async {
    final response = await _service
        .detail(id)
        .timeout(const Duration(seconds: 10));
    if (!response.isSuccessful) throw _failure(response.statusCode);
    return _character(_mapValue(response.body));
  });

  Future<LocationDetail> locationDetail(int id) => _guard(() async {
    final response = await _locationService
        .detail(id)
        .timeout(const Duration(seconds: 10));
    if (!response.isSuccessful) throw _locationFailure(response.statusCode);
    final body = _mapValue(response.body);
    return LocationDetail(
      id: _int(body['id']),
      name: _string(body['name']),
      type: _string(body['type']),
      dimension: _string(body['dimension']),
      residentCount: _list(body['residents']).length,
    );
  });

  Future<T> _guard<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on AppFailure {
      rethrow;
    } on FormatException {
      throw const AppFailure(AppFailureKind.invalidResponse);
    } on TimeoutException {
      throw const AppFailure(AppFailureKind.timeout);
    } on http.ClientException {
      throw const AppFailure(AppFailureKind.offline);
    } on ChopperException {
      throw const AppFailure(AppFailureKind.offline);
    } catch (_) {
      throw const AppFailure(AppFailureKind.unexpected);
    }
  }

  Character _character(Map<String, dynamic> value) {
    final origin = _mapValue(value['origin']);
    final location = _mapValue(value['location']);
    return Character(
      id: _int(value['id']),
      name: _string(value['name']),
      status: _status(_string(value['status'])),
      species: _string(value['species']),
      gender: _string(value['gender']),
      type: _string(value['type']),
      image: _string(value['image']),
      origin: CharacterLocation(
        _string(origin['name']),
        id: _locationId(origin['url']),
      ),
      location: CharacterLocation(
        _string(location['name']),
        id: _locationId(location['url']),
      ),
      episodeCount: _list(value['episode']).length,
    );
  }

  Map<String, dynamic> _mapValue(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      if (value.keys.any((key) => key is! String)) {
        throw const FormatException('Expected string map keys');
      }
      return Map<String, dynamic>.from(value);
    }
    throw const FormatException('Expected map');
  }

  List<dynamic> _list(Object? value) {
    if (value is List) return value;
    throw const FormatException('Expected list');
  }

  String _string(Object? value) {
    if (value is String) return value;
    throw const FormatException('Expected string');
  }

  int _int(Object? value) {
    if (value is int) return value;
    throw const FormatException('Expected int');
  }

  CharacterStatus _status(String value) => switch (value.toLowerCase()) {
    'alive' => CharacterStatus.alive,
    'dead' => CharacterStatus.dead,
    _ => CharacterStatus.unknown,
  };

  int? _locationId(Object? value) {
    if (value is! String || value.isEmpty) return null;
    final segments = Uri.tryParse(value)?.pathSegments;
    if (segments == null ||
        segments.length < 2 ||
        segments[segments.length - 2] != 'location')
      return null;
    return int.tryParse(segments.last);
  }

  AppFailure _failure(int statusCode) => statusCode == 404
      ? const NotFoundFailure(AppFailureKind.charactersNotFound)
      : statusCode >= 500
      ? const AppFailure(AppFailureKind.serverUnavailable)
      : const AppFailure(AppFailureKind.unexpected);

  AppFailure _locationFailure(int statusCode) => statusCode == 404
      ? const NotFoundFailure(AppFailureKind.locationNotFound)
      : statusCode >= 500
      ? const AppFailure(AppFailureKind.serverUnavailable)
      : const AppFailure(AppFailureKind.unexpected);
}
