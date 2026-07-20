import 'entities.dart';

abstract class CharacterRepository {
  Future<CharacterPage> getCharacters({
    int page = 1,
    String name = '',
    CharacterStatus? status,
  });
  Future<Character> getCharacter(int id);
}
