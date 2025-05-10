import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bleutooth/bloc/states/collab_states.dart';
import 'package:bleutooth/services/box_service.dart';

class CollaboratorsCubit extends Cubit<CollaboratorsState> {
  final BoxService _service;
  CollaboratorsCubit(this._service) : super(CollaboratorsLoading());

  /// Fetches all users who have been granted access to [boxId]
  Future<void> fetchCollaborators(int boxId) async {
    try {
      emit(CollaboratorsLoading());
      final users = await _service.fetchCollaborators(boxId);
      emit(CollaboratorsLoaded(users));
    } catch (e) {
      emit(CollaboratorsError(e.toString()));
    }
  }
}