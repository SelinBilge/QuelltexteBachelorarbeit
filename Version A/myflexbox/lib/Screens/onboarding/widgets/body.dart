import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myflexbox/Screens/onboarding/widgets/splash_content.dart';
import 'package:myflexbox/components/default_button.dart';
import 'package:myflexbox/config/app_router.dart';
import 'package:myflexbox/config/constants.dart';
import 'package:myflexbox/config/size_config.dart';
import 'package:myflexbox/cubits/auth/auth_cubit.dart';
import 'package:myflexbox/cubits/auth/auth_state.dart';
import 'package:permission_handler/permission_handler.dart';

///a StatefulWidget can change over time
/// for example when a counter number should be shown on the display
class OnBoardingBody extends StatefulWidget {
  @override
  _OnBoardingBodyState createState() => _OnBoardingBodyState();
}

class _OnBoardingBodyState extends State<OnBoardingBody> {
  ///this number tell us the current page of the onBoarding Screens
  int currentPage = 0;

  ///this List saves the different data for the onBoarding Screens
  /// like the text and which image should be shown
  List<Map<String, String>> splashData = [
    {
      "text": "Welcome to MYFLEXBOX, Screen 1",
      "image": "assets/images/onboarding_one_img.png"
    },
    {
      "text": "Welcome to MYFLEXBOX, Screen 2",
      "image": "assets/images/onboarding_two_img.png"
    },
    {
      "text": "Welcome to MYFLEXBOX, Screen 3",
      "image": "assets/images/onboarding_three_img.png"
    },
  ];

  ///the build method is to create the Widget and all widgets under this one
  ///(with the method setState() we can recall the build method (after button tab for example)
  @override
  Widget build(BuildContext context) {
    ///init a PageController > can control the shown page in the ViewPager (if button clicked)
    PageController _pageController =
        PageController(initialPage: currentPage, keepPage: false);

    /// A widget that insets its child by sufficient padding to avoid intrusions by the operating system.
    /// For example, this will indent the child by enough to avoid the status bar at the top of the screen.
    /// https://stackoverflow.com/questions/49227667/using-safearea-in-flutter/52767639
    return SafeArea(
      ///A box with a specified size.
      ///If given a child, this widget forces it to have a specific width and/or height.
      child: SizedBox(

          ///double.infinity mean "I want to be as big as my parent allows"
          ///https://stackoverflow.com/questions/54489513/whats-the-difference-between-double-infinity-and-mediaquery
          width: double.infinity,

          ///Column is a widget that displays its children in a vertical array.
          child: Column(
            ///multiple widgets on the same height in the widget tree (have the same parent)
            children: <Widget>[
              ///Expanded is a widget that expands a child of a Row, Column, or Flex so that the child fills the available space.
              Expanded(

                  ///flex is a number of relationship of screenSpace to the other widgets with the same height in the widget tree
                  flex: 3,

                  ///in this example the PageView has 3:5 space for his own (sum of flex = 5)
                  child: PageView.builder(

                      ///onPageChanged gets called if user swipe left / right
                      onPageChanged: (value) {
                        ///set state method recall the build method to update the UI
                        setState(() {
                          currentPage = value;
                        });
                      },

                      ///number of screens in the PageView
                      itemCount: splashData.length,

                      ///is to can control the PageView outside of this widget (button click)
                      controller: _pageController,

                      ///creates the UI in the PageView > with the text/ image of the List above
                      /// SplashContent is a Widget class (screens/splash/splash_content.dart)
                      itemBuilder: (context, index) => SplashContent(
                            image: splashData[index]["image"],
                            text: splashData[index]["text"],
                          ))),
              Expanded(
                flex: 1,

                ///add a Padding between the Widgets
                ///A widget that insets its child by the given padding.
                child: Padding(
                  ///X pixel margin above and below, no horizontal margins:
                  padding: EdgeInsets.symmetric(
                      horizontal: getProportionateScreenWidth(20)),
                  child: Column(
                    children: <Widget>[
                      Spacer(),

                      ///create a Row with the onBoarding dot in it
                      Row(
                        ///set the alignment to center
                        mainAxisAlignment: MainAxisAlignment.center,

                        ///Generates a list with splashData.length values (3) > for each build a Dot Widget.
                        children: List.generate(splashData.length,
                            (index) => buildDot(index: index)),
                      ),

                      ///add a Spacer with flex 1 > Space has 1:5 of the screen (between Dot and Button)
                      Spacer(flex: 1),

                      ///create a Default Button (components/default_button.dart)
                      // BLocBuilder is used here, to get the AuthCubit, and
                      // the userRepository (which is stored in the authCubit),
                      // to pass it as arguments to the Login Route.
                      BlocBuilder<AuthCubit, AuthState>(
                          builder: (context, state) {
                        //get the AuthCubit and the userRepository
                        var authCubit = context.read<AuthCubit>();
                        var arguments = {
                          "authCubit": authCubit,
                          "userRepository": authCubit.userRepository
                        };
                        return DefaultButton(
                          text: "Continue",
                          press: () {
                            ///call the build method if button is pressed
                            setState(() async {
                              ///if currentPage < 2 swipe to the next onBoarding Screen
                              if (currentPage < 2) {
                                _pageController.animateToPage(++currentPage, duration: Duration(milliseconds: 500), curve: Curves.easeOut);

                                ///else (>2) > navigate to the login route (onBoarding done)
                              } else if (await Permission.contacts.request().isGranted){
                                  // pass arguments to the route
                                  Navigator.pushNamedAndRemoveUntil(
                                      context, AppRouter.LoginViewRoute, (Route<dynamic> route) => false, arguments: arguments);
                                } else {
                                  Navigator.pushNamedAndRemoveUntil(
                                    context, AppRouter.LoginViewRoute, (Route<dynamic> route) => false, arguments: arguments);
                              }
                            });
                          },
                        );
                      }),

                      ///add a Spacer
                      Spacer(),
                    ],
                  ),
                ),
              )
            ],
          )),
    );
  }

  ///this method creates a AnimatedContainer Dot for to show which Screen of
  ///the onBoarding process are showed at the moment
  AnimatedContainer buildDot({int index}) {
    return AnimatedContainer(
      ///set the duration to the constant duration from the constants.dart
      duration: kAnimationDuration,

      ///set a margin
      margin: EdgeInsets.only(right: 5),

      ///set a height
      height: 6,

      ///if we are on current on this page make a wider dot > else also 6 (same as height)
      width: currentPage == index ? 20 : 6,

      ///decorate the Dot (add radius and the color (if current page primaryColor > else gray)
      decoration: BoxDecoration(
        color: currentPage == index ? kPrimaryColor : Color(0xFFD8D8D8D),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
