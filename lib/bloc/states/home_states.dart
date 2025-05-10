import 'package:equatable/equatable.dart';
import 'package:bleutooth/models/box.dart';

abstract class HomeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeEmpty extends HomeState {}

class HomeLoaded extends HomeState {
  final List<Box> boxes;

  HomeLoaded({required this.boxes});

  @override
  List<Object?> get props => [boxes];
}

class HomeError extends HomeState {
  final String message;

  HomeError({required this.message});

  @override
  List<Object?> get props => [message];
}