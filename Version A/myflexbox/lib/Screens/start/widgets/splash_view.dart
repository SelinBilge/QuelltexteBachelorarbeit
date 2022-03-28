import 'package:flutter/material.dart';
import 'package:myflexbox/config/constants.dart';

class SplashView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: kPrimaryColor,
        child: Center(
        child: Image.asset(
          'assets/images/logo.png',
          width: double.infinity,
        ),
      ),
      )
    );
  }
}