import 'package:equatable/equatable.dart';
import 'package:bleutooth/models/box.dart';

abstract class SharedBoxesState extends Equatable {
  const SharedBoxesState();
  @override List<Object?> get props => [];
}

class SharedBoxesLoading extends SharedBoxesState {}
class SharedBoxesLoaded extends SharedBoxesState {
  final List<Box> boxes;
  const SharedBoxesLoaded(this.boxes);
  @override List<Object?> get props => [boxes];
}
class SharedBoxesError extends SharedBoxesState {
  final String message;
  const SharedBoxesError(this.message);
  @override List<Object?> get props => [message];
}
