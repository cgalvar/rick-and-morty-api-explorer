import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/favorites_use_cases.dart';

class FavoritesState {
  FavoritesState(Set<int> ids, {this.error}) : ids = Set.unmodifiable(ids);
  final Set<int> ids;
  final String? error;
}

class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit(this._loadFavorites, this._saveFavorites)
    : super(FavoritesState({}));

  final LoadFavorites _loadFavorites;
  final SaveFavorites _saveFavorites;
  Future<void> _operations = Future.value();

  Future<void> _enqueue(Future<void> Function() operation) {
    final next = _operations.then((_) => operation());
    _operations = next.catchError((_) {});
    return next;
  }

  Future<void> load() => _enqueue(() async {
    try {
      emit(FavoritesState(await _loadFavorites()));
    } catch (_) {
      emit(
        FavoritesState(state.ids, error: 'No se pudieron cargar favoritos.'),
      );
    }
  });

  Future<void> toggle(int id) => _enqueue(() async {
    final next = {...state.ids};
    next.contains(id) ? next.remove(id) : next.add(id);
    try {
      await _saveFavorites(next);
      emit(FavoritesState(next));
    } catch (_) {
      emit(FavoritesState(state.ids, error: 'No se pudo guardar el favorito.'));
    }
  });
}
