// items_state.dart
import 'package:equatable/equatable.dart';
import 'package:bleutooth/models/item.dart';

abstract class ItemsState extends Equatable {
  const ItemsState();

  @override
  List<Object> get props => [];
}

class ItemsInitial extends ItemsState {}

class ItemsLoading extends ItemsState {}

class ItemsLoaded extends ItemsState {
  final List<Item> items;

  const ItemsLoaded(this.items);

  @override
  List<Object> get props => [items];
}

class ItemsError extends ItemsState {
  final String message;

  const ItemsError(this.message);

  @override
  List<Object> get props => [message];
}