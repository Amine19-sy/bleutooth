import 'package:equatable/equatable.dart';
import 'package:bleutooth/models/boxrequest.dart';

abstract class RequestsSentState extends Equatable {
  const RequestsSentState();
  @override List<Object?> get props => [];
}

class RequestsSentLoading extends RequestsSentState {}
class RequestsSentLoaded extends RequestsSentState {
  final List<BoxAccessRequest> requests;
  const RequestsSentLoaded(this.requests);
  @override List<Object?> get props => [requests];
}
class RequestsSentError extends RequestsSentState {
  final String message;
  const RequestsSentError(this.message);
  @override List<Object?> get props => [message];
}
