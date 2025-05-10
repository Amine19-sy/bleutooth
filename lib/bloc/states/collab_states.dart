import 'package:equatable/equatable.dart';
import 'package:bleutooth/models/user.dart';

abstract class CollaboratorsState extends Equatable {
  const CollaboratorsState();
  @override
  List<Object?> get props => [];
}

/// State when collaborators are being loaded
class CollaboratorsLoading extends CollaboratorsState {}

/// State when collaborators have been successfully fetched
class CollaboratorsLoaded extends CollaboratorsState {
  final List<User> users;
  const CollaboratorsLoaded(this.users);
  @override
  List<Object?> get props => [users];
}

/// State when there was an error fetching collaborators
class CollaboratorsError extends CollaboratorsState {
  final String message;
  const CollaboratorsError(this.message);
  @override
  List<Object?> get props => [message];
}