
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:intl/intl.dart';
import 'package:myflexbox/components/default_button.dart';
import 'package:myflexbox/config/constants.dart';
import 'package:myflexbox/cubits/current_locker/current_locker_cubit.dart';
import 'package:myflexbox/cubits/rent_locker/rent_locker_state.dart';
import 'package:myflexbox/repos/models/booking_request.dart';
import 'package:myflexbox/repos/models/locker.dart';
import 'package:myflexbox/repos/rent_locker_repository.dart';

class SubmitPage extends StatefulWidget {
  final BoxSize lockerSize;
  final DateTime startDate;
  final DateTime endDate;
  final Locker locker;

  SubmitPage({this.lockerSize, this.startDate, this.endDate, this.locker});

  @override
  _SubmitPageState createState() => _SubmitPageState();
}

class _SubmitPageState extends State<SubmitPage> {
  bool isLoading = false;
  String noteText = "";

  String parseDate(DateTime date) {
    String formattedString = DateFormat('yyyy-MM-ddTKK:mm:00+02:00').format(date);
    return formattedString;
  }

  String formattingDate(DateTime date) {
    String formattedString = DateFormat('dd.MM.yyyy').format(date);
    return formattedString;
  }

  String formatBoxSize(BoxSize box) {
    String cur = box.toString().toUpperCase();
    String substring = cur.substring(cur.length - 1);
    return substring;
  }

  void toggleLoading() {
    setState(() {
      isLoading = !isLoading;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.black
        ),
        brightness: Brightness.light,
        foregroundColor: Colors.black,
        title: Text("Reservierung bestätigen", style: TextStyle(color: Colors.black)),
      ) ,
      body: Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      Card(
        margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text("Boxgröße:", style:
                  TextStyle(
                    fontWeight: FontWeight.bold
                  )),
                  SizedBox(width: 20,),
                  Text(formatBoxSize(widget.lockerSize))
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text("Startdatum:", style:
                    TextStyle(
                      fontWeight: FontWeight.bold
                    ),),
                  SizedBox(width: 8,),
                  Text(formattingDate(widget.startDate)),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text("Enddatum:", style:
                    TextStyle(
                      fontWeight: FontWeight.bold
                    ),),
                  SizedBox(width: 16,),
                  Text(formattingDate(widget.endDate))
                ],
              ),
              SizedBox(height: 10),
                Row(
                  children: [
                    Text("Straße:", style:
                    TextStyle(
                        fontWeight: FontWeight.bold
                    ),
                    ),
                    SizedBox(width: 40,),

                    Expanded(
                      child: Text("${widget.locker.streetName} ${widget.locker.streetNumber}",
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        maxLines: 1,)
                    )
                  ],
                ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text("Plz / Stadt:", style:
                    TextStyle(
                      fontWeight: FontWeight.bold,
                    ),),
                  SizedBox(width: 15),
                  Text("${widget.locker.postcode} ${widget.locker.city}"),
                ],
              ),
              SizedBox(height: 10,),
              Row(
                children: [
                  Text("Notiz:", style:
                  TextStyle(
                    fontWeight: FontWeight.bold,
                  )),
                ],
              ),
              SizedBox(height: 5,),
              Row(
                children: [
                  Expanded(

                    child: TextField(
                      maxLines: 1,
                      autocorrect: false,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "optional"
                      ),
                      onChanged: (text) {
                        noteText = text;
                      },
                    ),
                  )
                ],
              ),
            ],
          )
        ),
      ),
      SizedBox(height: 20,),
      Text("Gesamtkosten 0€", style: TextStyle(
        fontSize: 22.0,
        fontWeight: FontWeight.bold,
      ),),
      SizedBox(height: 20,),
      isLoading ? CircularProgressIndicator(
        backgroundColor: Colors.yellow,
        strokeWidth: 8,
        valueColor: new AlwaysStoppedAnimation<Color>(kPrimaryColor),

      ):TextButton(
        child: Text("Reservierung bestätigen"),
        onPressed: () async{
          if (isLoading) {
            return;
          }
          toggleLoading();
          BookingRequest request = new BookingRequest(
              widget.locker.lockerId,
              widget.locker.compartments.first.compartmentId,
              parseDate(widget.startDate),
              parseDate(widget.endDate),
              FirebaseAuth.instance.currentUser.uid,
              noteText);

          var response = await RentLockerRepository().bookLocker(request);

          toggleLoading();

          if (response != null) {
            // Screentracking for analytics when the user switches to this screen
            if(analyticsService != null){
              analyticsService.logEvent(name: "submit_screen");
              analyticsService.logEvent(name: "current_locker_screen");
              print("ANALYTICS: logEvent: current_locker_screen");
              print("ANALYTICS: logEvent: submit_screen");
            }
            Navigator.pop(context, true);

          } else {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text("error")));
          }
        },

        style: TextButton.styleFrom(
          backgroundColor: kPrimaryColor,
          primary: Colors.white,

        )

      ),
    ])
      )
    );
  }
}