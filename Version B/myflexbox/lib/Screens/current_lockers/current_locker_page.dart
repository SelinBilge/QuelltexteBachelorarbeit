import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myflexbox/Screens/current_lockers/widgets/BottomCard.dart';
import 'package:myflexbox/Screens/current_lockers/widgets/TopCard.dart';
import 'package:myflexbox/Screens/current_lockers/widgets/current_locker_empty.dart';
import 'package:myflexbox/Screens/rent_locker/widgets/rent_locker_list_view.dart';
import 'package:myflexbox/config/app_router.dart';
import 'package:myflexbox/config/constants.dart';
import 'package:myflexbox/cubits/current_locker/current_locker_cubit.dart';
import 'package:myflexbox/cubits/current_locker/current_locker_state.dart';
import 'package:myflexbox/cubits/locker_detail/locker_detail_cubit.dart';
import 'package:myflexbox/cubits/locker_detail/locker_detail_state.dart';
import 'package:myflexbox/repos/get_locker_booking_repo.dart';
import 'package:myflexbox/repos/models/booking.dart';
import 'package:timelines/timelines.dart';
import 'package:myflexbox/Screens/current_locker_detail/current_locker_detail.dart';

class CurrentLockersPage extends StatefulWidget {
  @override
  _CurrentLockersPageState createState() => _CurrentLockersPageState();
}

class _CurrentLockersPageState extends State<CurrentLockersPage> {
  bool toggle1 = true;
  bool toggle2 = true;
  bool toggle3 = true;
  bool toggle4 = true;

  SizedBox getFilterCaption(String caption){
    return SizedBox(
      height: 30,
      child: Text(
        caption,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 12,
            color: Colors.black
        ),
      ),
    );
  }

  void saveFilterState(BuildContext context, FilterStates filterState){
    var cubit = context.read<CurrentLockerCubit>();
    cubit.changeFilter(filterState);

    // track when the user chooses a filter icon
    if(analyticsService != null){
      analyticsService.logSelectContent(contentType: filterState.toString(), itemId: filterState.index.toString());
      print("ANALYTICS: logSelectContent: " + filterState.toString() + ", " + filterState.index.toString());
    }
  }


  @override
  Widget build(BuildContext buildContext) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          toolbarHeight: 90.0,
          title:

          Container(
           // height: 250.0,
              child: BlocBuilder<CurrentLockerCubit, CurrentLockerState>(
                builder: (context, state) {
                  double sizeVal = 65.0;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [

                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                          IconButton(icon: toggle1? Image.asset('assets/images/filter_reserviert_on.png'): Image.asset('assets/images/filter_reserviert_off.png'),
                              iconSize: sizeVal,
                              onPressed: () {
                                setState(() {
                                  // Here we changing the icon.
                                  toggle1 = !toggle1;
                                });
                                saveFilterState(context, FilterStates.BOOKING_CREATED);
                              }
                          ),
                            getFilterCaption('Reserviert'),
                          ]
                          ),
                        Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(icon: toggle2? Image.asset('assets/images/filter_eingelagert_on.png'): Image.asset('assets/images/filter_eingelagert_off.png'),
                                  iconSize: sizeVal,
                                  onPressed: (){
                                    setState(() {
                                      // Here we changing the icon.
                                      toggle2 = !toggle2;
                                    });
                                    saveFilterState(context, FilterStates.NOT_COLLECTED);
                                  }
                              ),
                              getFilterCaption('Eingelagert'),
                            ]
                        ),

                        Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(icon: toggle3? Image.asset('assets/images/filter_abgeholt_on.png'): Image.asset('assets/images/filter_abgeholt_off.png'),
                              iconSize: sizeVal,
                              onPressed: (){
                              setState(() {
                              // Here we changing the icon.
                              toggle3 = !toggle3;
                              });
                              saveFilterState(context, FilterStates.COLLECTED);
                              }
                              ),
                              getFilterCaption('Abgeholt'),
                            ]
                        ),

                        Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(icon: toggle4? Image.asset('assets/images/filter_abgebrochen_on.png'): Image.asset('assets/images/filter_abgebrochen_off.png'),
                                  iconSize: sizeVal,
                                  onPressed: (){

                                    setState(() {
                                      // Here we changing the icon.
                                      toggle4 = !toggle4;
                                    });
                                    saveFilterState(context, FilterStates.CANCELLED);
                                  }
                              ),
                              getFilterCaption('Abgebrochen'),
                            ]
                        ),
                      ],
                    );
                }
              ),
          ),
          actions: [

            BlocBuilder<CurrentLockerCubit, CurrentLockerState>(
              builder: (context, state) {

                return Column(
                  children: <Widget>[
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          FocusScope.of(buildContext).unfocus();
                          showModalBottomSheet(
                              context: buildContext,
                              builder: (BuildContext buildContext) {
                                var cubit = context.read<CurrentLockerCubit>();
                                return BlocProvider.value(
                                    value: cubit,
                                    child: TextField(
                                      onChanged: (value){
                                        //add filter function
                                        var cubit = context.read<CurrentLockerCubit>();
                                        cubit.changeTextFilter(value);

                                        // track when user search locker in searchbar
                                        if(analyticsService != null){
                                          analyticsService.logViewSearchResults(searchTerm: value);
                                          print("ANALYTICS: logViewSearchResults: " + value);
                                        }

                                        // ScaffoldMessenger.of(buildContext).showSnackBar(SnackBar(
                                        //   content: Text(value),
                                        // ));
                                      },
                                      decoration: InputDecoration(
                                        hintText: "Suchen",
                                        border: InputBorder.none,
                                        prefixIcon: Icon(
                                          Icons.search,
                                          color: kPrimaryColor,
                                        ),
                                      ),
                                    ) //HistoryFilter(),
                                );
                              });
                        },
                        child: Container(
                          margin: EdgeInsets.only(
                            right: 20,
                            left: 10,
                          ),
                          child: Icon(Icons.search, color: kPrimaryColor),
                        ),
                      ),

                    ),

                  ],
                );

              }
            )
          ],
        ),
        body: BlocBuilder<CurrentLockerCubit, CurrentLockerState>(
          builder: (context, state) {
            if (state is CurrentLockerList) {
              return HistoryList();
            } else if (state is CurrentLockerEmpty) {
              return EmptyScreen();
            } else {
              return RentLockerListLoadingIndicator();
            }
          },
        ));
  }
}

class HistoryList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrentLockerCubit, CurrentLockerState>(
        builder: (context, state) {
      List<Booking> bookingList = [];
      if (state is CurrentLockerList) {
        bookingList = (state).bookingListFiltered;
      }
      return RefreshIndicator(
        onRefresh: (){
          var cubit = context.read<CurrentLockerCubit>();
          return cubit.loadDataBackground();

        },
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: bookingList.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              child: HistoryTile(booking: bookingList[index]),

            );
          },
        ),
      );
    });
  }
}

class HistoryTile extends StatelessWidget {
  final Booking booking;

  const HistoryTile({Key key, this.booking}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {

        // track when user clicks on a card
        if(analyticsService != null){
          String msg = booking.bookingId.toString() + " " + booking.state;

          analyticsService.logEvent(name: "card_clicked", parameters: <String, dynamic> {
            "bookingID": booking.bookingId.toString(),
            "bookingState": booking.state
          },);
          print("ANALYTICS: logEvent: card_clicked " + msg);
        }

        showModalBottomSheet<dynamic>(
            isScrollControlled: true,
            context: context,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(15),
                  topLeft: Radius.circular(15)
              ),
            ),
            builder: (BuildContext buildContext) {
              var currentLockerCubit = context.read<CurrentLockerCubit>();
              return BlocProvider(
                create: (context) =>
                LockerDetailCubit(booking, currentLockerCubit.repo, currentLockerCubit)..getPosition(),
                child: CurrentLockerDetailScreen(),
              );
            });
      },
      child: Card(
        margin: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {

                // track when user clicks on a card
                if(analyticsService != null){
                  String msg = booking.bookingId.toString() + " " + booking.state;

                  analyticsService.logEvent(name: "card_clicked", parameters: <String, dynamic> {
                    "bookingID": booking.bookingId.toString(),
                    "bookingState": booking.state
                  },);
                  print("ANALYTICS: logEvent: card_clicked " + msg);
                }

                showModalBottomSheet<dynamic>(
                    isScrollControlled: true,
                    context: context,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(15),
                        topLeft: Radius.circular(15)
                      ),
                    ),
                    builder: (BuildContext buildContext) {
                      var currentLockerCubit = context.read<CurrentLockerCubit>();
                      return BlocProvider(
                        create: (context) =>
                            LockerDetailCubit(booking, currentLockerCubit.repo, currentLockerCubit)..getPosition(),
                        child: CurrentLockerDetailScreen(),
                      );
                    });
              },
              child: Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    TopCard(booking: booking,),
                    BottomCard(booking: booking,)
                  ],
                )
              ),
            ),
            //TimeLine(),
            const Divider(
              height: 1,
              thickness: 1,
              indent: 5,
              endIndent: 5,
            ),
            GestureDetector(
              onTap: () {

                // track when a user displays the qr code
                if(analyticsService != null){
                  analyticsService.logEvent(name: "display_qr_code");
                  print("ANALYTICS: logEvent: display_qr_code");
                }

                showModalBottomSheet<dynamic>(
                    isScrollControlled: true,
                    context: context,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(15),
                          topLeft: Radius.circular(15)
                      ),
                    ),
                    builder: (BuildContext buildContext) {
                      var currentLockerCubit = context.read<CurrentLockerCubit>();
                      return BlocProvider(
                        create: (context) =>
                            LockerDetailCubit(booking, currentLockerCubit.repo, currentLockerCubit)..showQR()..getPosition(),
                        child: CurrentLockerDetailScreen(),
                      );
                    });
              },
              child: Container(
                padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: width * 0.6,
                      child: Text(
                        getQRCodeText(booking),
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      padding: EdgeInsets.fromLTRB(0, 0, 30, 0),
                      constraints: BoxConstraints(),
                      onPressed: () {

                        // track when a user displays the qr code
                        if(analyticsService != null){
                          analyticsService.logEvent(name: "display_qr_code");
                          print("ANALYTICS: logEvent: display_qr_code");
                        }

                        showModalBottomSheet<dynamic>(
                            isScrollControlled: true,
                            context: context,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(15),
                                  topLeft: Radius.circular(15)
                              ),
                            ),
                            builder: (BuildContext buildContext) {
                              var currentLockerCubit = context.read<CurrentLockerCubit>();
                              return BlocProvider(
                                create: (context) =>
                                LockerDetailCubit(booking, currentLockerCubit.repo, currentLockerCubit)..showQR()..getPosition(),
                                child: CurrentLockerDetailScreen(),
                              );
                            });
                      },
                      icon: Icon(
                        Icons.qr_code,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///this method is to set the right text left to the QR Code
  String getQRCodeText(Booking booking){
    if(booking is BookingFrom){
      return "Paket abholen";
    } else if(booking.state == "BOOKING_CREATED"){
      return "Paket einlegen";
    } else if(booking.state == "CANCELLED"){
      return "Abgelaufen";
    } else {
      return "Paket einlegen";
    }
  }
}