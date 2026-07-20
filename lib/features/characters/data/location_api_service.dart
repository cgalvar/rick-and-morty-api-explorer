import 'package:chopper/chopper.dart';

part 'location_api_service.chopper.dart';

@ChopperApi(baseUrl: '/location')
abstract class LocationApiService extends ChopperService {
  static LocationApiService create([ChopperClient? client]) =>
      _$LocationApiService(client);

  @GET(path: '/{id}')
  Future<Response<Map<String, dynamic>>> detail(@Path('id') int id);
}
