import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/error/app_failure.dart';
import 'app_failure_message.dart';
import '../domain/entities.dart';
import '../domain/use_cases.dart';

enum CharactersLoadState { loading, ready, empty, failed }

class CharactersState {
  CharactersState({
    List<Character> items = const [],
    this.phase = CharactersLoadState.loading,
    this.loadingMore = false,
    this.error,
    this.query = '',
    this.status,
    this.hasNext = true,
  }) : items = List.unmodifiable(items);
  final List<Character> items;
  final CharactersLoadState phase;
  final bool loadingMore, hasNext;
  final String? error;
  final String query;
  final CharacterStatus? status;
  bool get loading => phase == CharactersLoadState.loading;
  bool get empty => phase == CharactersLoadState.empty;

  CharactersState copyWith({
    List<Character>? items,
    CharactersLoadState? phase,
    bool? loadingMore,
    String? error,
    bool clearError = false,
    String? query,
    CharacterStatus? status,
    bool clearStatus = false,
    bool? hasNext,
  }) => CharactersState(
    items: items ?? this.items,
    phase: phase ?? this.phase,
    loadingMore: loadingMore ?? this.loadingMore,
    error: clearError ? null : error ?? this.error,
    query: query ?? this.query,
    status: clearStatus ? null : status ?? this.status,
    hasNext: hasNext ?? this.hasNext,
  );
}

sealed class CharactersEvent {
  const CharactersEvent();
}

class CharactersStarted extends CharactersEvent {
  const CharactersStarted();
}

class SearchChanged extends CharactersEvent {
  const SearchChanged(this.value);
  final String value;
}

class StatusChanged extends CharactersEvent {
  const StatusChanged(this.value);
  final CharacterStatus? value;
}

class NextPageRequested extends CharactersEvent {
  const NextPageRequested();
}

class RefreshRequested extends CharactersEvent {
  const RefreshRequested([this.completer]);
  final Completer<void>? completer;
}

class RetryRequested extends CharactersEvent {
  const RetryRequested();
}

class CharactersBloc extends Bloc<CharactersEvent, CharactersState> {
  CharactersBloc(this._get) : super(CharactersState()) {
    on<CharactersStarted>((_, e) => _load(e));
    on<SearchChanged>(_search);
    on<StatusChanged>(
      (e, emit) => _reset(emit, query: state.query, status: e.value),
    );
    on<RefreshRequested>((event, emit) async {
      try {
        await _load(emit);
      } finally {
        if (!(event.completer?.isCompleted ?? true))
          event.completer!.complete();
        if (identical(_activeRefresh, event.completer)) _activeRefresh = null;
      }
    });
    on<RetryRequested>((_, e) => _load(e));
    on<NextPageRequested>(_more);
  }
  final GetCharacters _get;
  int _epoch = 0;
  int _searchGeneration = 0;
  Timer? _timer;
  Completer<void>? _searchDelay;
  Completer<void>? _activeRefresh;

  Future<void> refresh() {
    if (!(_activeRefresh?.isCompleted ?? true)) _activeRefresh!.complete();
    final completer = Completer<void>();
    _activeRefresh = completer;
    add(RefreshRequested(completer));
    return completer.future;
  }

  Future<void> _search(SearchChanged e, Emitter<CharactersState> emit) async {
    final generation = ++_searchGeneration;
    _timer?.cancel();
    if (!(_searchDelay?.isCompleted ?? true)) _searchDelay!.complete();
    final delay = Completer<void>();
    _searchDelay = delay;
    _timer = Timer(const Duration(milliseconds: 400), delay.complete);
    await delay.future;
    if (generation != _searchGeneration || emit.isDone) return;
    await _reset(emit, query: e.value, status: state.status);
  }

  Future<void> _reset(
    Emitter<CharactersState> emit, {
    required String query,
    required CharacterStatus? status,
  }) async {
    emit(
      state.copyWith(query: query, status: status, clearStatus: status == null),
    );
    await _load(emit);
  }

  Future<void> _load(Emitter<CharactersState> emit) async {
    final epoch = ++_epoch;
    emit(
      state.copyWith(
        phase: CharactersLoadState.loading,
        loadingMore: false,
        clearError: true,
      ),
    );
    try {
      final page = await _get(name: state.query, status: state.status);
      if (epoch != _epoch || emit.isDone) return;
      emit(
        state.copyWith(
          items: page.items,
          phase: page.items.isEmpty
              ? CharactersLoadState.empty
              : CharactersLoadState.ready,
          hasNext: page.hasNext,
        ),
      );
    } on AppFailure catch (e) {
      if (epoch == _epoch && !emit.isDone)
        emit(
          state.copyWith(
            phase: state.items.isEmpty
                ? CharactersLoadState.failed
                : CharactersLoadState.ready,
            error: e.message,
          ),
        );
    }
  }

  Future<void> _more(NextPageRequested e, Emitter<CharactersState> emit) async {
    if (state.loading || state.loadingMore || !state.hasNext) return;
    final epoch = _epoch;
    emit(state.copyWith(loadingMore: true, clearError: true));
    try {
      final page = await _get(
        page: (state.items.length ~/ 20) + 1,
        name: state.query,
        status: state.status,
      );
      if (epoch == _epoch && !emit.isDone)
        emit(
          state.copyWith(
            items: [...state.items, ...page.items],
            loadingMore: false,
            hasNext: page.hasNext,
            clearError: true,
          ),
        );
    } on AppFailure catch (e) {
      if (epoch == _epoch && !emit.isDone)
        emit(state.copyWith(loadingMore: false, error: e.message));
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    if (!(_searchDelay?.isCompleted ?? true)) _searchDelay!.complete();
    if (!(_activeRefresh?.isCompleted ?? true)) _activeRefresh!.complete();
    return super.close();
  }
}
