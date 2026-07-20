import 'package:chopper/chopper.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/proxyman_forward_proxy.dart';
import '../../features/characters/data/location_api_service.dart';
import '../../features/characters/data/rick_and_morty_api_service.dart';
import '../../features/characters/domain/character_repository.dart';
import '../../features/characters/domain/location_repository.dart';
import '../../features/characters/domain/use_cases.dart';
import '../../features/favorites/domain/favorites_repository.dart';
import '../../features/favorites/domain/favorites_use_cases.dart';
import 'injection.config.dart';

@module
abstract class CoreModule {
  @preResolve
  Future<SharedPreferences> get preferences => SharedPreferences.getInstance();
  @lazySingleton
  ChopperClient get chopperClient => ChopperClient(
    baseUrl: Uri.parse('https://rickandmortyapi.com/api'),
    services: [RickAndMortyApiService.create(), LocationApiService.create()],
    converter: const JsonConverter(),
    errorConverter: const JsonConverter(),
    client: configuredProxymanHttpClient(),
  );

  @lazySingleton
  RickAndMortyApiService rickAndMortyApiService(ChopperClient client) =>
      client.getService<RickAndMortyApiService>();

  @lazySingleton
  LocationApiService locationApiService(ChopperClient client) =>
      client.getService<LocationApiService>();
}

@injectableInit
Future<GetIt> configureDependencies(GetIt getIt) async {
  await getIt.init();
  final repository = getIt<CharacterRepository>();
  getIt
    ..registerSingleton<GetCharacters>(GetCharacters(repository))
    ..registerSingleton<GetCharacter>(GetCharacter(repository))
    ..registerSingleton<GetLocation>(GetLocation(getIt<LocationRepository>()))
    ..registerSingleton<LoadFavorites>(
      LoadFavorites(getIt<FavoritesRepository>()),
    )
    ..registerSingleton<SaveFavorites>(
      SaveFavorites(getIt<FavoritesRepository>()),
    );
  return getIt;
}
