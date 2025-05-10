import 'package:equatable/equatable.dart';
import 'package:bleutooth/models/boxrequest.dart';

abstract class RequestsReceivedState extends Equatable {
  const RequestsReceivedState();
  @override List<Object?> get props => [];
}

class RequestsReceivedLoading extends RequestsReceivedState {}
class RequestsReceivedLoaded extends RequestsReceivedState {
  final List<BoxAccessRequest> requests;
  const RequestsReceivedLoaded(this.requests);
  @override List<Object?> get props => [requests];
}
class RequestsReceivedError extends RequestsReceivedState {
  final String message;
  const RequestsReceivedError(this.message);
  @override List<Object?> get props => [message];
}
