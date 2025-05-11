import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bleutooth/bloc/states/search_states.dart';
import '../../services/search_service.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchService _service;
  late List<Map<String, dynamic>> _allBoxes;

  SearchCubit(this._service) : super(SearchInitial());

  Future<void> loadBoxes(String userId) async {
    emit(SearchLoading());
    try {
      _allBoxes = await _service.fetchBoxesGrouped(userId);
      emit(SearchLoaded(allBoxes: _allBoxes, filteredBoxes: _allBoxes));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  void search(String query) {
    if (state is SearchLoaded) {
      final q = query.toLowerCase();
      final filtered = _allBoxes.map((box) {
        final items = (box['items'] as List)
            .where((j) => (j['name']?.toString().toLowerCase() ?? '').contains(q))
            .toList();
        if (items.isEmpty) return null;
        return {
          'box_id': box['box_id'] ?? -1,
          'box_name': box['box_name']?.toString() ?? 'Unknown Box',
          'items': items,
        };
      }).whereType<Map<String, dynamic>>().toList();

      emit(SearchLoaded(allBoxes: _allBoxes, filteredBoxes: filtered));
    }
  }

}