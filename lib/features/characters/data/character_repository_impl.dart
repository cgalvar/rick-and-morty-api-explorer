import 'package:injectable/injectable.dart';
import '../../../core/error/app_failure.dart';
import '../domain/character_repository.dart';
import '../domain/entities.dart';
import 'character_remote_data_source.dart';

@Injectable(as: CharacterRepository)
class CharacterRepositoryImpl implements CharacterRepository {
  CharacterRepositoryImpl(this._source);
  final CharacterRemoteDataSource _source;
  @override
  Future<CharacterPage> getCharacters({
    int page = 1,
    String name = '',
    CharacterStatus? status,
  }) async {
    try {
      return await _source.list(page: page, name: name, status: status);
    } on NotFoundFailure {
      return CharacterPage([], false);
    }
  }

  @override
  Future<Character> getCharacter(int id) => _source.detail(id);
}
