import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myflexbox/Screens/current_lockers/widgets/BottomCard.dart';
import 'package:myflexbox/Screens/current_lockers/widgets/TopCard.dart';
import 'package:myflexbox/Screens/current_lockers/widgets/current_locker_empty.dart';
import 'package:myflexbox/Screens/current_lockers/widgets/current_locker_filter.dart';
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

class CurrentLockersPage extends StatelessWidget {
  @override
  Widget build(BuildContext buildContext) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          title: Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 1),
                borderRadius: BorderRadius.all(
                  Radius.circular(4),
                )),
              child: BlocBuilder<CurrentLockerCubit, CurrentLockerState>(
                builder: (context, state) {
                  return TextField(
                    onChanged: (value){
                      //add filter function
                      var cubit = context.read<CurrentLockerCubit>();
                      cubit.changeTextFilter(value);

                      // track when user searches in textfield
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
                  );
                }
              ),
          ),
          actions: [
            BlocBuilder<CurrentLockerCubit, CurrentLockerState>(
              builder: (context, state) {
                return GestureDetector(
                  onTap: () {
                    FocusScope.of(buildContext).unfocus();
                    showModalBottomSheet(
                        context: buildContext,
                        builder: (BuildContext buildContext) {
                          var cubit = context.read<CurrentLockerCubit>();
                          return BlocProvider.value(
                            value: cubit,
                            child: HistoryFilter(),
                          );
                        });
                  },
                  child: Container(
                    margin: EdgeInsets.only(
                      right: 20,
                      left: 10,
                    ),
                    child: Icon(Icons.filter_list),
                  ),
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

        // track when user clicks on card
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

                // track when user clicks on card
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

                // track when user displays qr code
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

                        // track when user displays qr code
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