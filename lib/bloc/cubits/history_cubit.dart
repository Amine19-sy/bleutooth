import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bleutooth/bloc/states/history_states.dart';
import 'package:bleutooth/services/history_service.dart';
import 'package:bleutooth/models/history.dart';

class HistoryCubit extends Cubit<HistoryState> {
  final HistoryService _service;

  HistoryCubit(this._service) : super(HistoryInitial());

  Future<void> fetchHistory(int boxId) async {
    try {
      emit(HistoryLoading());
      final raw = await _service.getHistory(boxId);
      final list = raw.map((json) => History.fromJson(json)).toList();
      emit(HistoryLoaded(list));
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }
}