import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:myflexbox/config/constants.dart';
import 'package:myflexbox/cubits/bottom_nav/bottom_nav_cubit.dart';
import 'package:myflexbox/cubits/bottom_nav/bottom_nav_state.dart';
import 'package:myflexbox/cubits/current_locker/current_locker_cubit.dart';
import 'package:myflexbox/cubits/current_locker/current_locker_state.dart';
import 'package:myflexbox/cubits/rent_locker/rent_locker_cubit.dart';
import 'package:myflexbox/cubits/rent_locker/rent_locker_state.dart';
import 'package:myflexbox/repos/models/locker.dart';
import 'package:myflexbox/config/app_router.dart';

class RentLockerListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RentLockerCubit, RentLockerState>(
        builder: (context, state) {
      if (state is FilterRentLockerLoadingState) {
        return RentLockerListLoadingIndicator();
      } else if (state.lockerList.length == 0) {
        return Center();
      } else {
        return RentLockerList();
      }
    });
  }
}

class RentLockerList extends StatelessWidget {
  @override
  Widget build(BuildContext buildContext) {
    return BlocBuilder<RentLockerCubit, RentLockerState>(
      builder: (bocContext, state) {
        return Expanded(
          child: ListView.builder(
              itemCount: state.lockerList.length,
              itemBuilder: (context, index) {
                var position =
                    LatLng(state.myLocation.lat, state.myLocation.long);
                return Container(
                    child: LockerTile(
                        locker: state.lockerList[index]));
              }),
        );
      },
    );
  }
}

class LockerTile extends StatelessWidget {
  final Locker locker;

  LockerTile({this.locker});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return BlocBuilder<RentLockerCubit, RentLockerState>(
      builder: (context, state) {
        return BlocBuilder<CurrentLockerCubit, CurrentLockerState>(
          builder: (curLockerContext, curLockerState) {
            return BlocBuilder<BottomNavCubit, BottomNavState>(
              builder: (navContext, navState) {
                return GestureDetector(
                  onTap: () {
                    var arguments = {
                      "lockerSize": state.boxSize,
                      "startDate": state.startDate,
                      "endDate": state.endDate,
                      "locker": locker,
                    };
                    Navigator.pushNamed(context, AppRouter.SubmitViewRoute,
                        arguments: arguments).then((value) {
                          if (value != null) {

                            var curLockerCubit = curLockerContext.read<CurrentLockerCubit>();
                            curLockerCubit.loadDataBackground();

                            var navCubit = navContext.read<BottomNavCubit>();
                            navCubit.changePage(0);
                          }
                    });
                  },
                  child: Card(
                    margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                    child: Container(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: width * 0.6,
                                child: Text(
                                  "${locker.streetName} ${locker.streetNumber}",
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  var rentLockerCubit = context.read<RentLockerCubit>();
                                  var latLng =
                                      LatLng(locker.latitude, locker.longitude);
                                  rentLockerCubit.showLockerOnMap(latLng);
                                },
                                icon: Icon(
                                  Icons.map,
                                  color: kPrimaryColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "${locker.postcode} ${locker.city}",
                            style: TextStyle(color: Colors.black54),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: [
                              Text(
                                "Entfernung",
                                style: TextStyle(color: Colors.black54),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text("-- km"),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              Text(
                                "Freie Fächer",
                                style: TextStyle(color: Colors.black54),
                              ),
                              SizedBox(
                                width: 7,
                              ),
                              locker.compartments.firstWhere(
                                          (element) => element.size == "s",
                                          orElse: () => null) ==
                                      null
                                  ? Text("")
                                  : Text(" S "),
                              locker.compartments.firstWhere(
                                          (element) => element.size == "m",
                                          orElse: () => null) ==
                                      null
                                  ? Text("")
                                  : Text(" M "),
                              locker.compartments.firstWhere(
                                          (element) => element.size == "l",
                                          orElse: () => null) ==
                                      null
                                  ? Text("")
                                  : Text(" L "),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
            );
          }
        );
      },
    );
  }
}

class RentLockerListLoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
      padding: const EdgeInsets.only(top: 50),
      child: SizedBox(
        child: CircularProgressIndicator(
          strokeWidth: 4,
        ),
        height: 30.0,
        width: 30.0,
      ),
    ));
  }
}
