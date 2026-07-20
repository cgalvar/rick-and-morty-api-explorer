import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/error/app_failure.dart';
import '../domain/entities.dart';
import '../domain/use_cases.dart';
import 'app_failure_message.dart';

class DetailState {
  const DetailState({this.character, this.loading = true, this.error});
  final Character? character;
  final bool loading;
  final String? error;
}

class DetailCubit extends Cubit<DetailState> {
  DetailCubit(this._get) : super(const DetailState());
  final GetCharacter _get;
  Future<void> load(int id) async {
    emit(const DetailState());
    try {
      emit(DetailState(character: await _get(id), loading: false));
    } on AppFailure catch (e) {
      emit(DetailState(loading: false, error: e.message));
    }
  }
}
