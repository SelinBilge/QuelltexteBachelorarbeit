import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myflexbox/Screens/home/home_screen.dart';
import 'package:myflexbox/Screens/login/login_screen.dart';
import 'package:myflexbox/Screens/onboarding/onboarding_screen.dart';
import 'package:myflexbox/Screens/profile/profile_page.dart';
import 'package:myflexbox/Screens/register/register_screen.dart';
import 'package:myflexbox/Screens/start/start_screen.dart';
import 'package:myflexbox/config/constants.dart';
import 'package:myflexbox/cubits/auth/auth_cubit.dart';
import 'package:myflexbox/cubits/bottom_nav/bottom_nav_cubit.dart';
import 'package:myflexbox/cubits/login/login_cubit.dart';
import 'package:myflexbox/cubits/register/register_cubit.dart';
import 'package:myflexbox/cubits/rent_locker/rent_locker_state.dart';
import 'package:myflexbox/repos/models/locker.dart';
import 'package:myflexbox/repos/user_repo.dart';
import 'package:myflexbox/Screens/profile/widgets/contact_screen.dart';
import 'package:myflexbox/Screens/submit/submit_page.dart';

// Responsible for routing in the App.
// Each available Route has a static stringValue.
// The generateRoute method is used by the MaterialApp and called, whenever
// a route change is requested(via the Navigator.push... method)
class AppRouter {
  static const String StartViewRoute = '/'; // / -> initial route
  static const String LoginViewRoute = 'login';
  static const String HomeViewRoute = 'home';
  static const String RegisterViewRoute = 'register';
  static const String OnBoardingRoute = 'onboarding';
  static const String ContactViewRoute = 'contact';
  static const String ProfileViewRoute = 'profile';
  static const String SubmitViewRoute = 'submit';



  // Depending on the name of the route, a different MaterialPageRoute
  // is returned from the switch statement, and pushed to the navigation stack
  // If arguments are passed, they are available via settings.arguments
  // The Widgets returned, are often wrapped in BlocProviders, that provide a
  // certain Cubit to the Page.
  Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Initial Route, returns the StartPage Widget.
      case StartViewRoute:
        return MaterialPageRoute(builder: (context) => StartPage(), settings: RouteSettings(name: "Start_Page"));

      // Login Route, is wrapped with a BLocProvider for the LoginCubit.
      // the authCubit and userRepository are passed to the new LoginCubit.
      case LoginViewRoute:
        var arguments = settings.arguments as Map;
        AuthCubit authCubit = arguments["authCubit"];
        UserRepository userRepository = arguments["userRepository"];
        return MaterialPageRoute(
            builder: (context) => BlocProvider(
                create: (context) => LoginCubit(
                    authCubit: authCubit, userRepository: userRepository),
                child: LoginScreen()), settings: RouteSettings(name: "Login_Screen"));

      // Registration Route, is wrapped with a BLocProvider for the
      // RegisterCubit.
      // The userRepository is passed to the new RegisterCubit.
      case RegisterViewRoute:
        var arguments = settings.arguments as Map;
        AuthCubit authCubit = arguments["authCubit"];
        return MaterialPageRoute(
            builder: (context) => BlocProvider(
                create: (context) =>
                    RegisterCubit(authCubit: authCubit),
                child: RegisterPage()), settings: RouteSettings(name: "Register_Screen"));

      // HomeViewRoute, is wrapped with a BlocProvider for the BottomNavCubit,
      // which is responsible for the bottom-navigation.
      case HomeViewRoute:
      // Screentracking for analytics when the user switches to this screen
        if(analyticsService != null){
          analyticsService.logEvent(name: "current_locker_screen");
          print("ANALYTICS: logEvent: current_locker_screen");
        }

        return MaterialPageRoute(
          builder: (context) => BlocProvider(
              create: (context) => BottomNavCubit(), child: HomeScreen()), settings: RouteSettings(name: "Home_Screen")
        );

      // OnBoardingRoute
      case OnBoardingRoute:
        return MaterialPageRoute(builder: (context) => OnboardingScreen(), settings: RouteSettings(name: "Onboarding_Screen"));

      case ContactViewRoute:
        return MaterialPageRoute(builder: (context) => ContactScreen(), settings: RouteSettings(name: "Contact_Screen"));

      case ProfileViewRoute:
        return MaterialPageRoute(builder: (context) => ProfilePage(), settings: RouteSettings(name: "Profile_Screen"));

      case SubmitViewRoute:
        var arguments = settings.arguments as Map;
        BoxSize lockerSize = arguments["lockerSize"];
        DateTime startDate = arguments["startDate"];
        DateTime endTime = arguments["endDate"];
        Locker locker = arguments["locker"];
        return MaterialPageRoute(builder: (context) => SubmitPage(
          lockerSize: lockerSize,
          locker: locker,
          startDate: startDate,
          endDate: endTime,
        ), settings: RouteSettings(name: "Submit_Screen"));

      default:
        return MaterialPageRoute(builder: (context) => StartPage(), settings: RouteSettings(name: "Start_Page"));
    }
  }
}