import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:myflexbox/Screens/profile/widgets/profile_menu.dart';
import 'package:myflexbox/config/constants.dart';
import 'package:myflexbox/cubits/auth/auth_cubit.dart';
import 'package:myflexbox/cubits/auth/auth_state.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:myflexbox/config/app_router.dart';

/// is a stateless widget, it doesn't change over time
/// menu stays always the same
class ProfileBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    /// SingleChildScrollView -> is a box im which a single widget can be scrolled
    return SingleChildScrollView(
      /// specifies offsets in terms of visual edges
      padding: EdgeInsets.symmetric(vertical: 20),

      /// a widget that displays its children in a vertical array
      child: Column(
        children: [

          BlocBuilder<AuthCubit, AuthState>(
            builder: (cubitContext, state) {
              if(state is AuthAuthenticated){

                return Column(
                  children: [

                   SizedBox(
                    height: 115,
                    width: 115,

                    /// a widget that positions its children relative to the edges of its box
                    /// useful if you want to overlap several children in a simple way
                    child: Stack(
                      fit: StackFit.expand,
                      overflow: Overflow.visible,
                      children: [
                        /// circle that represents a user
                        CircleAvatar(
                          child: Text(state.user.name.substring(0, 1),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 35.0
                              )),
                          backgroundColor:  Theme.of(context).primaryColor,),

                        Positioned(
                            right: -16,
                            bottom: 0,
                            /// box with specified size
                            child: SizedBox(
                              height: 46,
                              width: 46,
                              /// text label material widget that performs an action when the button is tapped
                              child: FlatButton(
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                  side: BorderSide(color: Colors.white),
                                ),
                                color: Color(0xFFF5F6F9),
                                onPressed: (){},
                                child: SvgPicture.asset("assets/icons/Camera Icon.svg"),
                              ),
                            ))
                      ],
                    )
                ),

                  SizedBox(height: 20),
              ],
              );

              }
              return  SizedBox(height: 8);
              }
      ),


          BlocBuilder<AuthCubit, AuthState>(
              builder: (cubitContext, state) {
                if (state is AuthAuthenticated) {

                  /// user that is logged in with google has
                  /// the email saved as name -> only show ones
                  if (state.user.name == state.user.email) {
                    return Column(
                      children: [
                        Text(state is AuthAuthenticated ? state.user.name : ""),
                      ],
                    );
                  } else {
                    /// show name and email of user
                    return Column(
                      children: [
                        Text(state is AuthAuthenticated ? state.user.name : ""),
                        SizedBox(height: 8,),
                        Text(state is AuthAuthenticated ? state.user.email : "")
                      ],
                    );
                  }
                }
                return SizedBox(height: 8);
              }
          ),


          /// different menu points
          ProfileMenu(
            text: "Favoriten",
            icon: "assets/icons/Heart_Icon.svg",
            press: () async => {
              if (await Permission.contacts.request().isGranted)
                {Navigator.pushNamed(context, AppRouter.ContactViewRoute)}
            },
          ),
          ProfileMenu(
            text: "Passwort ändern",
            icon: "assets/icons/Lock.svg",
            press: () {},
          ),
          ProfileMenu(
            text: "Zahlung einrichten",
            icon: "assets/icons/Cash.svg",
            press: () {},
          ),
          ProfileMenu(
            text: "Zahlungsverlauf",
            icon: "assets/icons/Bill_Icon.svg",
            press: () {},
          ),
          ProfileMenu(
            text: "OnBoarding neu starten",
            icon: "assets/icons/Question_mark.svg",
            press: () {},
          ),
          BlocBuilder<AuthCubit, AuthState>(
            builder: (cubitContext, state) {
              return ProfileMenu(
                text: "Abmelden",
                icon: "assets/icons/Log_out.svg",
                press: () async {
                  var authCubit = cubitContext.read<AuthCubit>();
                  await authCubit.logout();
                  var arguments = {
                    "authCubit": authCubit,
                    "userRepository": authCubit.userRepository
                  };
                  Navigator.pushNamedAndRemoveUntil(
                      context, AppRouter.LoginViewRoute, (route) => false,
                      arguments: arguments);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
