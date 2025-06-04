import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bleutooth/bloc/states/search_states.dart';
import '../../services/search_service.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchService _service;
  List<Map<String, dynamic>> _baseBoxes = [];      // items after filters
  List<Map<String, dynamic>> _filteredBoxes = [];  // items after search()

  SearchCubit(this._service) : super(SearchInitial());

  Future<void> loadBoxes(String userId) async {
    emit(SearchLoading());
    try {
      _baseBoxes = await _service.fetchBoxesGrouped(userId);
      _filteredBoxes = _baseBoxes;
      emit(SearchLoaded(allBoxes: _baseBoxes, filteredBoxes: _filteredBoxes));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  /// Search by name within the current filters.
  void search(String query) {
    if (state is SearchLoaded) {
      final q = query.toLowerCase();
      final filtered = _baseBoxes.map((box) {
        final items = (box['items'] as List)
          .where((j) => (j['name'] as String).toLowerCase().contains(q))
          .toList();
        if (items.isEmpty) return null;
        return {
          'box_id': box['box_id'],
          'box_name': box['box_name'],
          'items': items,
        };
      }).whereType<Map<String, dynamic>>().toList();

      _filteredBoxes = filtered;
      emit(SearchLoaded(allBoxes: _baseBoxes, filteredBoxes: _filteredBoxes));
    }
  }

  /// Apply date & “added by” filters, re-fetch from backend.
  Future<void> applyFilters({
    required String userId,
    String? addedBy,
    String? dateFilter,
    String? toFilter,
  }) async {
    emit(SearchLoading());
    try {
      final response = await _service.fetchBoxesGrouped(
        userId,
        addedBy:  addedBy?.isNotEmpty == true ? addedBy : null,
        dateFrom: dateFilter,
        dateTo:   toFilter,
      );

      // reset base & filtered lists
      _baseBoxes     = response;
      _filteredBoxes = response;
      emit(SearchLoaded(allBoxes: _baseBoxes, filteredBoxes: _filteredBoxes));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }
  // final SearchService _service;
  // late List<Map<String, dynamic>> _allBoxes;

  // SearchCubit(this._service) : super(SearchInitial());

  // Future<void> loadBoxes(String userId) async {
  //   emit(SearchLoading());
  //   try {
  //     _allBoxes = await _service.fetchBoxesGrouped(userId);
  //     emit(SearchLoaded(allBoxes: _allBoxes, filteredBoxes: _allBoxes));
  //   } catch (e) {
  //     emit(SearchError(e.toString()));
  //   }
  // }

  // void search(String query) {
  //   if (state is SearchLoaded) {
  //     final q = query.toLowerCase();
  //     final filtered = _allBoxes.map((box) {
  //       final items = (box['items'] as List)
  //           .where((j) => (j['name']?.toString().toLowerCase() ?? '').contains(q))
  //           .toList();
  //       if (items.isEmpty) return null;
  //       return {
  //         'box_id': box['box_id'] ?? -1,
  //         'box_name': box['box_name']?.toString() ?? 'Unknown Box',
  //         'items': items,
  //       };
  //     }).whereType<Map<String, dynamic>>().toList();

  //     emit(SearchLoaded(allBoxes: _allBoxes, filteredBoxes: filtered));
  //   }
  // }

}