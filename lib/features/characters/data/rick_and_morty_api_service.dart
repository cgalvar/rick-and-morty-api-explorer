import 'package:chopper/chopper.dart';

part 'rick_and_morty_api_service.chopper.dart';

@ChopperApi(baseUrl: '/character')
abstract class RickAndMortyApiService extends ChopperService {
  static RickAndMortyApiService create([ChopperClient? client]) =>
      _$RickAndMortyApiService(client);

  @GET()
  Future<Response<Map<String, dynamic>>> list({
    @Query('page') required int page,
    @Query('name') String? name,
    @Query('status') String? status,
  });

  @GET(path: '/{id}')
  Future<Response<Map<String, dynamic>>> detail(@Path('id') int id);
}
