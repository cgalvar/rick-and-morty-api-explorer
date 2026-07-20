import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/app_failure.dart';
import '../domain/entities.dart';
import '../domain/use_cases.dart';
import 'app_failure_message.dart';

class LocationState {
  const LocationState({this.location, this.loading = true, this.error});

  final LocationDetail? location;
  final bool loading;
  final String? error;
}

class LocationCubit extends Cubit<LocationState> {
  LocationCubit(this._getLocation) : super(const LocationState());

  final GetLocation _getLocation;
  int? _id;

  Future<void> load(int id) async {
    _id = id;
    emit(const LocationState());
    try {
      emit(LocationState(location: await _getLocation(id), loading: false));
    } on AppFailure catch (error) {
      emit(LocationState(loading: false, error: error.message));
    }
  }

  Future<void> retry() => load(_id!);
}
