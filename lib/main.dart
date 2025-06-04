import 'package:bleutooth/firebase_options.dart';
import 'package:bleutooth/services/notifications_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bleutooth/bloc/cubits/confirmation_cubit.dart';
import 'package:bleutooth/bloc/cubits/register_cubit.dart';
// import 'package:bleutooth/screens/add_box.dart';
// import 'package:bleutooth/screens/homepage.dart';
import 'package:bleutooth/screens/login_form.dart';
// import 'package:bleutooth/screens/confirmation_code.dart';
// import 'package:bleutooth/screens/register_form.dart';
import 'package:bleutooth/services/auth_service.dart';
// import 'package:bluetooth/services/notifications_service.dart';
import 'bloc/cubits/login_cubit.dart';
import 'package:firebase_core/firebase_core.dart';
void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.instance.initialize();
  runApp( MainApp());
}

class MainApp extends StatelessWidget {
   MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LoginCubit(authService: AuthService())),
        BlocProvider(create: (context) => RegisterCubit(authService: AuthService())),
        BlocProvider(create: (context) => ConfirmationCubit()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home:LoginForm(),
      ),
    );
  }
}
  