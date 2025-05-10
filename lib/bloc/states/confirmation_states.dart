import 'package:equatable/equatable.dart';

abstract class ConfirmationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ConfirmationInitial extends ConfirmationState {}

class ConfirmationLoading extends ConfirmationState {}

class ConfirmationSuccess extends ConfirmationState {}

class ConfirmationFailure extends ConfirmationState {
  final String error;
  ConfirmationFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class ResendCodeLoading extends ConfirmationState {}

class ResendCodeSuccess extends ConfirmationState {}

class ResendCodeFailure extends ConfirmationState {
  final String error;
  ResendCodeFailure(this.error);

  @override
  List<Object?> get props => [error];
}
