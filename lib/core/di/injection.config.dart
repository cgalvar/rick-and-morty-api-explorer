// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:chopper/chopper.dart' as _i31;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;
import 'package:soriana_character_explorer/core/di/injection.dart' as _i375;
import 'package:soriana_character_explorer/features/characters/data/character_remote_data_source.dart'
    as _i399;
import 'package:soriana_character_explorer/features/characters/data/character_repository_impl.dart'
    as _i808;
import 'package:soriana_character_explorer/features/characters/data/location_api_service.dart'
    as _i505;
import 'package:soriana_character_explorer/features/characters/data/location_repository_impl.dart'
    as _i655;
import 'package:soriana_character_explorer/features/characters/data/rick_and_morty_api_service.dart'
    as _i758;
import 'package:soriana_character_explorer/features/characters/domain/character_repository.dart'
    as _i139;
import 'package:soriana_character_explorer/features/characters/domain/location_repository.dart'
    as _i1016;
import 'package:soriana_character_explorer/features/favorites/data/favorites_local_data_source.dart'
    as _i653;
import 'package:soriana_character_explorer/features/favorites/domain/favorites_repository.dart'
    as _i680;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final coreModule = _$CoreModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => coreModule.preferences,
      preResolve: true,
    );
    gh.lazySingleton<_i31.ChopperClient>(() => coreModule.chopperClient);
    gh.lazySingleton<_i758.RickAndMortyApiService>(
      () => coreModule.rickAndMortyApiService(gh<_i31.ChopperClient>()),
    );
    gh.lazySingleton<_i505.LocationApiService>(
      () => coreModule.locationApiService(gh<_i31.ChopperClient>()),
    );
    gh.lazySingleton<_i680.FavoritesRepository>(
      () => _i653.FavoritesLocalDataSource(gh<_i460.SharedPreferences>()),
    );
    gh.factory<_i399.CharacterRemoteDataSource>(
      () => _i399.CharacterRemoteDataSource(
        gh<_i758.RickAndMortyApiService>(),
        gh<_i505.LocationApiService>(),
      ),
    );
    gh.factory<_i1016.LocationRepository>(
      () => _i655.LocationRepositoryImpl(gh<_i399.CharacterRemoteDataSource>()),
    );
    gh.factory<_i139.CharacterRepository>(
      () =>
          _i808.CharacterRepositoryImpl(gh<_i399.CharacterRemoteDataSource>()),
    );
    return this;
  }
}

class _$CoreModule extends _i375.CoreModule {}
