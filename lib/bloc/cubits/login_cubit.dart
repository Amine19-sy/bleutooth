import 'package:bloc/bloc.dart';
import 'package:bleutooth/services/auth_service.dart';
import '../states/login_states.dart';
import 'dart:async';

// import '../states/login_state.dart';


class LoginCubit extends Cubit<LoginState> {
  final AuthService authService;
  
  LoginCubit({required this.authService}) : super(LoginInitial());

  /// Updated method to accept username (or email) and password.
  Future<void> login(String identifier, String password) async {
    emit(LoginLoading());
    try {
      
      final response = await authService.login(
        username: identifier,
        password: password,
      );
      emit(LoginSuccess(response));
    } catch (error) {
      emit(LoginFailure(error.toString()));
    }
  }
}
