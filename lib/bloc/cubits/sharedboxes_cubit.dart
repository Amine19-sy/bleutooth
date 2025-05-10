import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bleutooth/bloc/states/sharedboxes_states.dart';
import 'package:bleutooth/services/box_service.dart';


class SharedBoxesCubit extends Cubit<SharedBoxesState> {
  final BoxService _service;
  SharedBoxesCubit(this._service) : super(SharedBoxesLoading());

  Future<void> fetchSharedBoxes(int userId) async {
    try {
      emit(SharedBoxesLoading());
      final boxes = await _service.SharedBoxes(userId);
      emit(SharedBoxesLoaded(boxes));
    } catch (e) {
      emit(SharedBoxesError(e.toString()));
    }
  }
}
