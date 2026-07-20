abstract class FavoritesRepository {
  Future<Set<int>> read();
  Future<void> write(Set<int> ids);
}
