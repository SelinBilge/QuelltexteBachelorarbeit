import 'package:flutter/cupertino.dart';
import 'package:myflexbox/config/constants.dart';
import 'package:myflexbox/config/size_config.dart';

///this class creates the Widget for the SplashScreen Content
class SplashContent extends StatelessWidget {

  ///constructor
  const SplashContent({
    Key key,
    this.text,
    this.image,
  }): super(key: key);

  ///saves the given text and the image reference as String
  final String text, image;

  @override
  Widget build(BuildContext context) {
    return Column(
      ///add more Widgets with the same parent
      children: <Widget>[
        ///add a Spacer with flex 1 > so 1:5 of the screen
        Spacer(flex: 1),
        ///add a header Text
        Text(
          "MYFLEXBOX",
          ///add some style attributes to the text
          style: TextStyle(
            fontSize: getProportionateScreenWidth(36),
            ///user the PrimaryColor from the constants.dart file
            color: kPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        Spacer(flex: 3),
        ///add the given Image
        Image.asset(
          image,
          ///double.infinity mean "I want to be as big as my parent allows"
          ///https://stackoverflow.com/questions/54489513/whats-the-difference-between-double-infinity-and-mediaquery
          width: double.infinity,
        ),
        Spacer(flex: 1),
        ///add the given text as subtext to a Text Widget
        Text(
          text,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}