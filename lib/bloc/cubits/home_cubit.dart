import 'package:bloc/bloc.dart';
import 'package:bleutooth/bloc/states/home_states.dart';
import 'package:bleutooth/services/box_service.dart';


class HomeCubit extends Cubit<HomeState> {
  final String userId;
  final BoxService boxService;

  HomeCubit({required this.userId, required this.boxService}) : super(HomeInitial());

  Future<void> fetchUserBoxes() async {
    emit(HomeLoading());
    try {
      final boxes = await boxService.fetchUserBoxes(userId);
      if (boxes.isEmpty) {
        emit(HomeEmpty());
      } else {
        emit(HomeLoaded(boxes: boxes));
      }
    } catch (e) {
      emit(HomeError(message: 'Failed to fetch boxes: $e'));
    }
  }
}
