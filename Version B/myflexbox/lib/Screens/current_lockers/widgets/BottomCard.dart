import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myflexbox/repos/models/booking.dart';

class BottomCard extends StatelessWidget{
  final Booking booking;

  const BottomCard({Key key, this.booking}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
            children: [
              Text(
                "Ersteller",
                style: TextStyle(color: Colors.black54),
              ),
              SizedBox(
                width: 5,
              ),
              Text(getCreator()),
            ]
        ),
        SizedBox(
          height: 5,
        ),
        Row(
            children: [
              Text(
                "geteilt mit",
                style: TextStyle(color: Colors.black54),
              ),
              SizedBox(
                width: 5,
              ),
              Text(getSharedName()),
            ]
        ),
      ],
    );
  }

  String getSharedName() {
    String txt = "";
    if (booking is BookingFrom) {
      txt = (booking as BookingFrom).fromUser.name;
    }
    if (txt.isNotEmpty) {
      return "Mir";
    } else {
      return txt;
    }
  }

  String getCreator(){
    if(booking is BookingTo){
      return "Ich";
    } else if(booking is BookingFrom){
      return (booking as BookingFrom).fromUser.name;
    } else {
      return "Ich";
    }
  }
}