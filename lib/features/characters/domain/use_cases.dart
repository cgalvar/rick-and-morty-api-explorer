import 'character_repository.dart';
import 'entities.dart';
import 'location_repository.dart';

class GetCharacters {
  const GetCharacters(this._repository);
  final CharacterRepository _repository;
  Future<CharacterPage> call({
    int page = 1,
    String name = '',
    CharacterStatus? status,
  }) => _repository.getCharacters(page: page, name: name, status: status);
}

class GetCharacter {
  const GetCharacter(this._repository);
  final CharacterRepository _repository;
  Future<Character> call(int id) => _repository.getCharacter(id);
}

class GetLocation {
  const GetLocation(this._repository);
  final LocationRepository _repository;

  Future<LocationDetail> call(int id) => _repository.getLocation(id);
}
