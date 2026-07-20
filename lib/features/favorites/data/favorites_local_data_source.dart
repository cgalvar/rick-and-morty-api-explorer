import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/favorites_repository.dart';

@LazySingleton(as: FavoritesRepository)
class FavoritesLocalDataSource implements FavoritesRepository {
  FavoritesLocalDataSource(this._prefs);
  final SharedPreferences _prefs;
  static const _key = 'favorite_character_ids';
  @override
  Future<Set<int>> read() async => (_prefs.getStringList(_key) ?? const [])
      .map(int.tryParse)
      .whereType<int>()
      .toSet();
  @override
  Future<void> write(Set<int> ids) async {
    final saved = await _prefs.setStringList(
      _key,
      ids.map((id) => '$id').toList(),
    );
    if (!saved) throw StateError('SharedPreferences rejected favorites write.');
  }
}
