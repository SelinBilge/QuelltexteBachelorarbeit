import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myflexbox/config/constants.dart';

class ProfileMenu extends StatelessWidget {

 const ProfileMenu({
   Key key,
   @required this.text,
   @required this.icon,
   this.press,

 }) : super(key: key);

  final String text, icon;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    /// a widget that insets its child by the given padding
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      /// text label material widget that performs an action when the button is tapped
      child: FlatButton(
        padding: EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: Color(0xFFF5F6F9),
        onPressed: press,
        /// displays its children in a horizontal way
        child: Row(
          children: [
            SvgPicture.asset(
              icon,
              color: kPrimaryColor, /// from constants file
              width: 22,
            ),
            SizedBox(width: 20),
            Expanded(child: Text(text)),
            Icon(Icons.arrow_forward_ios)

          ],
        ),
      ),
    );
  }
}