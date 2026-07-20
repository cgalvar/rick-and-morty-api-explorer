// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'rick_and_morty_api_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$RickAndMortyApiService extends RickAndMortyApiService {
  _$RickAndMortyApiService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = RickAndMortyApiService;

  @override
  Future<Response<Map<String, dynamic>>> list({
    required int page,
    String? name,
    String? status,
  }) {
    final Uri $url = Uri.parse('/character');
    final Map<String, dynamic> $params = <String, dynamic>{
      'page': page,
      'name': name,
      'status': status,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> detail(int id) {
    final Uri $url = Uri.parse('/character/${id}');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }
}
