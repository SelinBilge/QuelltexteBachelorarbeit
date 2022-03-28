import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myflexbox/Screens/login/widgets/login_form.dart';
import 'package:myflexbox/config/app_router.dart';
import 'package:myflexbox/config/constants.dart';
import 'package:myflexbox/cubits/auth/auth_cubit.dart';
import 'package:myflexbox/cubits/auth/auth_state.dart';

// Root of the Login Route.
// The BlocListener pushes the HomeViewRoute as soon as the AuthAuthenticated
// state is emitted (the user has successfully logged in)
class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthCubit, AuthState>(listener: (context, state) {
        // Listens for states emitted by the AuthCubit.
        // If the user logged in, and the Authentication was successful, clear
        // the route stack and go to HomeViewRoute
        if (state is AuthAuthenticated) {
          // Screentracking for analytics when the user switches to this screen
          if(analyticsService != null){
            analyticsService.logEvent(name: "login_screen");
            print("ANALYTICS: logEvent: login_screen");
          }

          Navigator.pushNamedAndRemoveUntil(context, AppRouter.HomeViewRoute,
              (Route<dynamic> route) => false);
        }
      }, child: Center(
          // The LoginForm is displayed.
          child: LoginForm()
      ))
    );
  }
}