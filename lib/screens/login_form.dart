import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bleutooth/bloc/cubits/home_cubit.dart';
import 'package:bleutooth/bloc/cubits/login_cubit.dart';
import 'package:bleutooth/bloc/states/login_states.dart';
import 'package:bleutooth/screens/homepage.dart';
import 'package:bleutooth/screens/register_form.dart';
import 'package:bleutooth/services/box_service.dart';
import 'package:bleutooth/widgets/input_field.dart';

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _loginFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    _identifierController.text = "admin";
    _passwordController.text = "admin";
    super.initState();
  }

  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (_) => BlocProvider(
                    create:
                        (_) => HomeCubit(
                          userId: state.user["id"].toString(),
                          boxService: BoxService(),
                        )..fetchUserBoxes(),
                    child: HomePage(user: state.user),
                  ),
            ),
          );
        }
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: BlocBuilder<LoginCubit, LoginState>(
            builder: (context, state) {
              return Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.3,
                    color: Colors.grey[100],
                    child: Center(
                      child: Image.asset(
                        'assets/img/logo_bleutooth.png',
                        width: 200,
                        height: 200,
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Form(
                          key: _loginFormKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 25),
                              Text(
                                'Welcome!',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'Popins',
                                ),
                              ),
                              SizedBox(height: 24),
                              CustomTextField(
                                labelText: "Email address", // identifier field
                                controller: _identifierController,
                              ),
                              SizedBox(height: 24),
                              CustomTextField(
                                labelText: "Password",
                                controller: _passwordController,
                                isPassword: true,
                              ),
                              SizedBox(height: 16),
                              GestureDetector(
                                child: Text(
                                  "Forgot password?",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(height: 16),
                              if (state is LoginFailure)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    state.error,
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed:
                                      state is LoginLoading
                                          ? null
                                          : () {
                                            if (_loginFormKey.currentState!
                                                .validate()) {
                                              context.read<LoginCubit>().login(
                                                _identifierController.text,
                                                _passwordController.text,
                                              );
                                            }
                                          },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child:
                                      state is LoginLoading
                                          ? SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 3,
                                              color: Colors.white,
                                            ),
                                          )
                                          : Text(
                                            "Login",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                ),
                              ),
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Not a member? ",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => RegisterForm(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "Register now",
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                color: Colors.grey,
                                height: 1,
                                margin: EdgeInsets.symmetric(vertical: 16),
                              ),
                              Center(
                                child: Text(
                                  "Or Continue with",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {},
                                    child: CircleAvatar(
                                      backgroundColor: Colors.red,
                                      // child: Image.asset("assets/img/apple.png"),
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  GestureDetector(
                                    onTap: () {},
                                    child: CircleAvatar(
                                      backgroundColor: Colors.black,
                                      // child: Image.asset("assets/img/facebook.png")
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  GestureDetector(
                                    onTap: () {},
                                    child: CircleAvatar(
                                      backgroundColor: Colors.blue,
                                      // child: Image.asset("assets/img/google.png")
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
