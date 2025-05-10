import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bleutooth/bloc/states/req_rec.dart';
import 'package:bleutooth/services/box_service.dart';


class RequestsReceivedCubit extends Cubit<RequestsReceivedState> {
  final BoxService _service;
  RequestsReceivedCubit(this._service) : super(RequestsReceivedLoading());

  Future<void> fetch(int userId) async {
    try {
      emit(RequestsReceivedLoading());
      final list = await _service.fetchRequestsReceived(userId);
      emit(RequestsReceivedLoaded(list));
    } catch (e) {
      emit(RequestsReceivedError(e.toString()));
    }
  }

  Future<void> respond(int requestId, bool accept, int userId) async {
    try {
      await _service.respondRequest(requestId, accept, userId);
      fetch(userId);
    } catch (e) {
      // you could also emit a ResponseError state here
      emit(RequestsReceivedError(e.toString()));
    }
  }
}
