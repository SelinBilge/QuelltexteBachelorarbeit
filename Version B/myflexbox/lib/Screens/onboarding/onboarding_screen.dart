import 'package:flutter/material.dart';
import 'package:myflexbox/Screens/onboarding/widgets/body.dart';
import 'package:myflexbox/config/constants.dart';
import 'package:myflexbox/config/size_config.dart';



class OnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Screentracking for analytics when the user switches to this screen
    if(analyticsService != null){
      analyticsService.logEvent(name: "onboarding_screen");
      print("ANALYTICS: logEvent: onboarding_screen");
    }

    ///init the SizeConfig class for height and weight calc methods
    SizeConfig().init(context);
    ///A Scaffold Widget provides a framework which implements the basic material
    /// design visual layout structure of the flutter app.
    /// It provides APIs for showing drawers, snack bars and bottom sheets.
    /// In a Scaffold you can add for example a button navigation bar
    return Scaffold(
      ///Body() is a Widget class which can be found at screens/splash/components
      body: OnBoardingBody(),
    );
  }

}