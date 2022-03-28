import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myflexbox/Screens/register/widgets/register_form.dart';
import 'package:myflexbox/Screens/register/widgets/register_success_view.dart';
import 'package:myflexbox/config/constants.dart';
import 'package:myflexbox/cubits/register/register_cubit.dart';
import 'package:myflexbox/cubits/register/register_state.dart';

//Root of the Register Route
class RegisterPage extends StatelessWidget {
  @override
  Widget build(BuildContext buildContext) {

    // Screentracking for analytics when the user switches to this screen
    if(analyticsService != null){
      analyticsService.logEvent(name: "register_screen");
      print("ANALYTICS: logEvent: register_screen");
    }

    return Scaffold(body: Center(
      child:
          BlocBuilder<RegisterCubit, RegisterState>(builder: (context, state) {
            // Depending on the RegisterState,either the Form or the Success
            // screen is displayed
        if (state is RegisterSuccess) {
          return RegisterSuccessView();
        } else {
          return RegisterForm();
        }
      }),
    ));
  }
}
