import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myflexbox/repos/models/booking.dart';

class TopCard extends StatelessWidget{
  final Booking booking;

  const TopCard({Key key, this.booking}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Row(
      children: [
        SizedBox(
          width: width * 0.60,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                getStateText(),
                style: TextStyle(
                    fontSize: 18,
                    color: booking is BookingFrom
                        ? Colors.lightGreen
                        : booking is BookingTo
                        ? Colors.yellow
                        : Colors.black87),
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  Text(
                    "von",
                    style: TextStyle(color: Colors.black54),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(convertDate(booking.startTime))
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                  children: [
                    Text(
                      "bis",
                      style: TextStyle(color: Colors.black54),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(convertDate(booking.endTime)),
                  ]
              ),
            ],
          ),
        ),
        Spacer(),
        Column(
          children: [
            Image.asset(
              getImagePath(),
              width: 80,
            ),
            Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 0))
          ],
        )
      ],
    );
  }

  ///this method is to set the header state string
  String getStateText(){
    String txt = "";
    if (booking.state == "BOOKING_CREATED") {
      txt = "nicht eingelagert";
    } else if (booking.state == "COLLECTED") {
      txt = "abgeholt";
    } else if (booking.state == "NOT_COLLECTED") {
      txt = "nicht abgeholt";
    } else {
      txt = "abgebrochen";
    }
    return txt;
  }

  ///this method is to get the right image for each booking
  String getImagePath(){
    String stateImageSrc = "";
    if (booking.state == "BOOKING_CREATED") {
      stateImageSrc = "assets/images/status_booking_created.png";
    } else if (booking.state == "COLLECTED") {
      stateImageSrc = "assets/images/status_collected.png";
    } else if (booking.state == "NOT_COLLECTED") {
      stateImageSrc = "assets/images/status_not_collected.png";
    } else {
      stateImageSrc = "assets/images/status_booking_cancelled.png";
    }
    return stateImageSrc;
  }

  String convertDate(String date) {
    // var time = DateTime.parse(date);
    // String formattedString = DateFormat('yyyy-MM-ddTKK:mm:00+02:00').format(time);
    // return formattedString;

    var time = DateTime.parse(date);

    return time.day.toString() +
        "." +
        time.month.toString() +
        "." +
        time.year.toString();
  }
}