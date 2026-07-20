import 'package:injectable/injectable.dart';

import '../domain/entities.dart';
import '../domain/location_repository.dart';
import 'character_remote_data_source.dart';

@Injectable(as: LocationRepository)
class LocationRepositoryImpl implements LocationRepository {
  LocationRepositoryImpl(this._source);

  final CharacterRemoteDataSource _source;

  @override
  Future<LocationDetail> getLocation(int id) => _source.locationDetail(id);
}
