import 'favorites_repository.dart';

class LoadFavorites {
  const LoadFavorites(this._repository);

  final FavoritesRepository _repository;

  Future<Set<int>> call() => _repository.read();
}

class SaveFavorites {
  const SaveFavorites(this._repository);

  final FavoritesRepository _repository;

  Future<void> call(Set<int> ids) => _repository.write(ids);
}
