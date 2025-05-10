// lib/cubits/requests_sent_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bleutooth/bloc/states/req_sent.dart';
import 'package:bleutooth/services/box_service.dart';


class RequestsSentCubit extends Cubit<RequestsSentState> {
  final BoxService _service;
  RequestsSentCubit(this._service) : super(RequestsSentLoading());

  Future<void> fetch(int ownerId) async {
    try {
      emit(RequestsSentLoading());
      final list = await _service.fetchRequestsSent(ownerId);
      emit(RequestsSentLoaded(list));
    } catch (e) {
      emit(RequestsSentError(e.toString()));
    }
  }
}
