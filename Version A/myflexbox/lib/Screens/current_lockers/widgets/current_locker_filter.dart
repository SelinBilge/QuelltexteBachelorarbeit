import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myflexbox/config/constants.dart';
import 'package:myflexbox/cubits/current_locker/current_locker_cubit.dart';
import 'package:myflexbox/cubits/current_locker/current_locker_state.dart';

class HistoryFilter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    // track when user presses filter icon
    if(analyticsService != null){
      analyticsService.logEvent(name: "locker_filter");
      print("ANALYTICS: logEvent: locker_filter");
    }

    var width = MediaQuery.of(context).size.width;
    var height = 340.0;
    return BlocBuilder<CurrentLockerCubit, CurrentLockerState>(
      builder: (context, state) {
        return Container(
            height: height,
            padding: EdgeInsets.only(top: 20, bottom: 0, left: 0, right: 0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30), topRight: Radius.circular(30))),
            //color: Colors.amber,
            child: Column(
              children: [
                Text(
                  "Buchungen filtern",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.black12,
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      BoxPickerSquare(width: width,filterType: "nicht eingelagert", height: height,assetPath: "assets/images/status_booking_created.png",filterState: FilterStates.BOOKING_CREATED),
                      BoxPickerSquare(width: width,filterType: "abgeholt", height: height,assetPath: "assets/images/status_collected.png",filterState: FilterStates.COLLECTED),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.black12,
                        width: 1.0,
                      ),
                      bottom: BorderSide(
                        color: Colors.black12,
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      BoxPickerSquare(width: width,filterType: "nicht abgeholt", height: height,assetPath: "assets/images/status_not_collected.png", filterState: FilterStates.NOT_COLLECTED,),
                      BoxPickerSquare(width: width,filterType: "abgebrochen", height: height,assetPath: "assets/images/status_booking_cancelled.png",filterState: FilterStates.CANCELLED,),
                    ],
                  ),
                )
              ],
            ));
      }
    );
  }
}

class BoxPickerSquare extends StatelessWidget{
  final double width;
  final String filterType;
  final double height;
  final String assetPath;
  final FilterStates filterState;

  const BoxPickerSquare({Key key, this.width, this.filterType, this.height, this.assetPath, this.filterState}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrentLockerCubit, CurrentLockerState>(
      builder: (context, state) {
        var stateTest = state.filter;
        var abc = "a";
        return GestureDetector(
          onTap: () {
            var cubit = context.read<CurrentLockerCubit>();
            cubit.changeFilter(filterState);

            // track when user clicks on element in filter
            if(analyticsService != null){
              analyticsService.logSelectContent(contentType: filterState.toString(), itemId: filterState.index.toString());
              print("ANALYTICS: logSelectContent: " + filterState.toString() + ", " + filterState.index.toString());
            }

          },
          child: Container(
            width: width * 0.5,
            height: height * 0.4,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: state.filter[filterState]? Colors.grey[200] : Colors.white,
              border: Border(
                right: BorderSide(
                  color: Colors.black12,
                  width: 1.0,
                ),
              ),
            ),
            child: Column(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      filterType,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: Colors.black
                      ),
                    ),
                    Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
                    Image.asset(
                      assetPath,
                      width: 65,
                    )
                  ],
                )
              ],
            ),
          ),
        );
      }
    );
  }

}