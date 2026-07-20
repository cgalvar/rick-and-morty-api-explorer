import 'entities.dart';

abstract class LocationRepository {
  Future<LocationDetail> getLocation(int id);
}
