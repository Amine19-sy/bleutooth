import 'package:equatable/equatable.dart';

abstract class SearchState extends Equatable {
  const SearchState();
  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {}
class SearchLoading extends SearchState {}
class SearchError extends SearchState {
  final String message;
  const SearchError(this.message);
  @override List<Object?> get props => [message];
}

class SearchLoaded extends SearchState {
  final List<Map<String, dynamic>> allBoxes;
  final List<Map<String, dynamic>> filteredBoxes;
  const SearchLoaded({required this.allBoxes, required this.filteredBoxes});
  @override List<Object?> get props => [allBoxes, filteredBoxes];
}