// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'location_api_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$LocationApiService extends LocationApiService {
  _$LocationApiService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = LocationApiService;

  @override
  Future<Response<Map<String, dynamic>>> detail(int id) {
    final Uri $url = Uri.parse('/location/${id}');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }
}
