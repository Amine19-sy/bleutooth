import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bleutooth/bloc/states/items_states.dart';
import 'package:bleutooth/services/item_service.dart';


class ItemsCubit extends Cubit<ItemsState> {
  final ItemService _itemService;

  ItemsCubit(this._itemService) : super(ItemsInitial());

  Future<void> getItems(int boxId) async {
    try {
      emit(ItemsLoading());
      final items = await _itemService.getItems(boxId);
      emit(ItemsLoaded(items));
    } catch (e) {
      emit(ItemsError(e.toString()));
    }
  }
  
  Future<void> addItem({
  required int boxId,
  required String name,
  required int userId,
  File? imageFile,
}) async {
  try {
    emit(ItemsLoading());
    await _itemService.addItem(
      boxId: boxId,
      name: name,
      userId: userId,
      imageFile: imageFile, 
    );
    final items = await _itemService.getItems(boxId);
    emit(ItemsLoaded(items));
  } catch (e) {
    emit(ItemsError(e.toString()));
  }
}

  Future<void> removeItem({
    required int itemId,
    required int userId,
    required int boxId,
  }) async {
    try {
      emit(ItemsLoading());
      await _itemService.removeItem(
        itemId: itemId,
        userId: userId,
      );
      final items = await _itemService.getItems(boxId);
      emit(ItemsLoaded(items));
    } catch (e) {
      emit(ItemsError(e.toString()));
    }
  }
}