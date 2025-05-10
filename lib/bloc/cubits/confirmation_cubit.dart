import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bleutooth/bloc/states/confirmation_states.dart';


class ConfirmationCubit extends Cubit<ConfirmationState> {
  ConfirmationCubit() : super(ConfirmationInitial());

  void verifyCode(String code) async {
    emit(ConfirmationLoading());
    await Future.delayed(const Duration(seconds: 2)); // Simulate API call

    if (code == "1234") { // Replace with real validation logic
      emit(ConfirmationSuccess());
    } else {
      emit(ConfirmationFailure("Invalid confirmation code."));
    }
  }

  void resendCode() async {
    emit(ResendCodeLoading());
    await Future.delayed(const Duration(seconds: 2)); // Simulate API call

    bool success = true; // Simulated response

    if (success) {
      emit(ResendCodeSuccess());
    } 
  }
}
