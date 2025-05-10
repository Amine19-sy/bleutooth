import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bleutooth/bloc/cubits/confirmation_cubit.dart';
import 'package:bleutooth/bloc/states/confirmation_states.dart';
import 'package:bleutooth/widgets/input_field.dart';
// import 'package:bleutooth/bloc/cubit/confirmation_cubit.dart';
// import 'package:bleutooth/bloc/cubit/confirmation_state.dart';

class ConfirmationCode extends StatefulWidget {
  const ConfirmationCode({super.key});

  @override
  State<ConfirmationCode> createState() => _ConfirmationCodeState();
}

class _ConfirmationCodeState extends State<ConfirmationCode> {
  final TextEditingController codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 36),
                const Text(
                  "Enter confirmation code",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                ),
                const SizedBox(height: 6),
                const Text(
                  "A 4-digit code was sent to ensia@gmail.com",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    return Container(
                      height: 68,
                      width: 64,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: CustomTextField(
                        isCodeInput: true,
                        controller: TextEditingController(),
                      ),
                    );
                  }),
                ),
              ],
            ),
            Column(
              children: [
                BlocBuilder<ConfirmationCubit, ConfirmationState>(
                  builder: (context, state) {
                    return SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: state is ResendCodeLoading
                            ? null
                            : () {
                                context.read<ConfirmationCubit>().resendCode();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: state is ResendCodeLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: Colors.blue,
                                ),
                              )
                            : const Text(
                                "Resend Code",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                BlocBuilder<ConfirmationCubit, ConfirmationState>(
                  builder: (context, state) {
                    return SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: state is ConfirmationLoading
                            ? null
                            : () {
                                String enteredCode = codeController.text;
                                context.read<ConfirmationCubit>().verifyCode(enteredCode);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: state is ConfirmationLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                "Continue",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 36),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
