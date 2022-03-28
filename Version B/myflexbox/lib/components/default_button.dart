import 'package:flutter/material.dart';
import 'package:myflexbox/config/constants.dart';
import 'package:myflexbox/config/size_config.dart';


///this class creates and return a custom Button
///this button can be used everywhere you want
class DefaultButton extends StatelessWidget {

  ///constructor
  const DefaultButton({
    Key key, this.text, this.press,
  }) : super (key: key);

  ///is the text of the button
  final String text;
  ///is the function of the button if he is pressed
  final Function press;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      ///double.infinity mean "I want to be as big as my parent allows"
      ///https://stackoverflow.com/questions/54489513/whats-the-difference-between-double-infinity-and-mediaquery
      width: double.infinity,
      ///add height of the button
      height: getProportionateScreenHeight(56),
      ///add a TextButton
      child: TextButton(
        ///style this button
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: kPrimaryColor,
          ///text Color
          primary: Colors.white,
        ),
        ///if button is pressed do the given function of the constructor
        onPressed: press,
        ///add a Text to the Button
        child: Text(
          text,
          style: TextStyle(
            fontSize: getProportionateScreenWidth(18),
          ),
        ),
      ),
    );
  }
}