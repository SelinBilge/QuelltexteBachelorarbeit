import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:myflexbox/config/constants.dart';
import 'package:myflexbox/cubits/rent_locker/rent_locker_cubit.dart';
import 'package:myflexbox/cubits/rent_locker/rent_locker_state.dart';
import 'package:myflexbox/repos/google_places_repo.dart';
import 'package:myflexbox/repos/models/google_places_data.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import 'location_search.dart';

class FilterForm extends StatelessWidget {
  @override
  Widget build(BuildContext buildContext) {
    var width = MediaQuery.of(buildContext).size.width;
    return BlocBuilder<RentLockerCubit, RentLockerState>(
        builder: (context, state) {
      return Container(
        padding: EdgeInsets.only(
            left: width * 0.05, right: width * 0.05, top: 20, bottom: 20),
        decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.04),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            )),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: width * 0.75, child: LockerSearchBar()),
                SizedBox(
                    width: width * 0.15,
                    child: IconButton(
                      icon: state is FilterRentLockerState ||
                              state is FilterRentLockerLoadingState
                          ? Icon(Icons.map)
                          : Icon(Icons.list),
                      color: kPrimaryColor,
                      onPressed: () {
                        var rentLockerCubit = context.read<RentLockerCubit>();
                        rentLockerCubit.switchScreen();
                      },
                    )),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: width * 0.65, child: LockerTimeBar()),
                GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus(); //Hide Keyboard
                    showModalBottomSheet(
                        context: buildContext,
                        builder: (BuildContext buildContext) {
                          var rentLockerCubit = context.read<RentLockerCubit>();
                          return BlocProvider.value(
                            value: rentLockerCubit,
                            child: BoxPickerModal(),
                          );
                        });
                  },
                  child: Container(
                      width: width * 0.2,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.inbox, color: kPrimaryColor,),
                            padding: EdgeInsets.zero,
                          ),
                          Text(state.boxSize == BoxSize.s
                              ? "S"
                              : state.boxSize == BoxSize.m
                                  ? "M"
                                  : state.boxSize == BoxSize.l
                                      ? "L"
                                      : "XL"),
                        ],
                      )),
                ),
              ],
            )
          ],
        ),
      );
    });
  }
}

class LockerSearchBar extends StatelessWidget {
  void showLocationSearch(BuildContext context, BuildContext buildContext,
      RentLockerState state) async {
    final Suggestion result = await showSearch(
      context: buildContext,
      delegate: AddressSearch(),
      query: state.chosenLocation.description,
    );
    if (result != null) {
      final location = await GooglePlacesRepo()
          .getPlaceDetailFromId(result.placeId, result.description);
      var rentLockerCubit = context.read<RentLockerCubit>();
      rentLockerCubit.changeLocation(location);
    }
  }

  @override
  Widget build(BuildContext buildContext) {
    var width = MediaQuery.of(buildContext).size.width;
    return BlocBuilder<RentLockerCubit, RentLockerState>(
        builder: (context, state) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: Colors.white,
        ),
        child: Row(
          children: [
            GestureDetector(
                child: Container(
                  padding: EdgeInsets.only(left: 20, top: 15, bottom: 15),
                  width: width * 0.55,
                  child: Text(
                    state.chosenLocation.description == null
                        ? "Adresse eingeben"
                        : state.chosenLocation.description,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 17,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // OnChangedListener
                onTap: () {
                  showLocationSearch(context, buildContext, state);
                }),
            Spacer(),
            IconButton(
              padding: EdgeInsets.only(left: 5, right: 5),
              constraints: BoxConstraints(),
              icon: Icon(
                Icons.search,
                color: kPrimaryColor,
              ),
              onPressed: () {
                showLocationSearch(context, buildContext, state);
              },
            ),
            IconButton(
              padding: EdgeInsets.only(left: 0, right: 10),
              constraints: BoxConstraints(),
              icon: Icon(
                Icons.location_on_outlined,
                color: state.myLocation.description != null
                    ? kPrimaryColor
                    : Colors.grey,
              ),
              onPressed: () {
                var rentLockerCubit = context.read<RentLockerCubit>();
                rentLockerCubit.getCurrentLocation();
              },
            ),
          ],
        ),
      );
    });
  }
}

class LockerTimeBar extends StatelessWidget {
  @override
  Widget build(BuildContext buildContext) {
    return BlocBuilder<RentLockerCubit, RentLockerState>(
        builder: (context, state) {
      DateFormat dateFormat = DateFormat("dd.MM.yyyy");
      String startDateString = dateFormat.format(state.startDate);
      String endDateString = dateFormat.format(state.endDate);
      return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); //Hide Keyboard
          showModalBottomSheet(
              context: buildContext,
              builder: (BuildContext buildContext) {
                var rentLockerCubit = context.read<RentLockerCubit>();
                return BlocProvider.value(
                  value: rentLockerCubit,
                  child: DatePickerModal(),
                );
              });
        },
        child: Container(
          padding: EdgeInsets.only(left: 20, top: 15, bottom: 15, right: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.white,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today,
                color: kPrimaryColor,
                size: 20,
              ),
              Text(
                startDateString + " - " + endDateString,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class DatePickerModal extends StatelessWidget {
  @override
  Widget build(BuildContext buildContext) {
    return BlocBuilder<RentLockerCubit, RentLockerState>(
        builder: (context, state) {
      return Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 20, left: 20, right: 20),
            child: Align(
              alignment: Alignment.centerRight,
              child: FlatButton(
                  onPressed: () {
                    Navigator.pop(buildContext);
                  },
                  child: Text(
                    "Auswählen",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                    ),
                  )),
            ),
          ),
          Container(
            height: 335,
            padding: EdgeInsets.only(left: 20, right: 20, bottom: 5, top: 10),
            child: SfDateRangePicker(
              selectionMode: DateRangePickerSelectionMode.range,
              minDate: DateTime.now(),
              initialSelectedRange:
                  PickerDateRange(state.startDate, state.endDate),
              onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                if (args.value is PickerDateRange) {
                  final DateTime rangeStartDate = args.value.startDate;
                  final DateTime rangeEndDate = args.value.endDate;
                  if (rangeStartDate != null && rangeEndDate != null) {
                    var rentLockerCubit = context.read<RentLockerCubit>();
                    rentLockerCubit.changeDate(rangeStartDate, rangeEndDate);
                  }
                }
              },
            ),
          ),
        ],
      );
    });
  }
}

class BoxPickerModal extends StatelessWidget {
  @override
  Widget build(BuildContext buildContext) {
    var width = MediaQuery.of(buildContext).size.width;

    return Container(
        height: 340,
        padding: EdgeInsets.only(top: 20, bottom: 0, left: 0, right: 0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30))),
        child: Column(
          children: [
            Text(
              "Größe auswählen",
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
                  BoxPickerSquare(
                    size: "40x40",
                    price: "20",
                    width: width,
                    category: "S",
                    boxSize: BoxSize.s,
                  ),
                  BoxPickerSquare(
                    size: "40x40",
                    price: "20",
                    width: width,
                    category: "M",
                    boxSize: BoxSize.m,
                  ),
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
                  BoxPickerSquare(
                    size: "40x40",
                    price: "20",
                    width: width,
                    category: "L",
                    boxSize: BoxSize.l,
                  ),
                ],
              ),
            )
          ],
        ));
  }
}

class BoxPickerSquare extends StatelessWidget {
  final double width;
  final String category;
  final String size;
  final String price;
  final BoxSize boxSize;

  const BoxPickerSquare(
      {Key key, this.width, this.category, this.size, this.price, this.boxSize})
      : super(key: key);

  @override
  Widget build(BuildContext buildContext) {
    return BlocBuilder<RentLockerCubit, RentLockerState>(
      builder: (context, state) {
        return GestureDetector(
          onTap: () {
            var rentLockerCubit = context.read<RentLockerCubit>();
            rentLockerCubit.changeBoxSize(boxSize);
            Navigator.pop(buildContext);
          },
          child: Container(
            width: width * 0.5,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: boxSize == state.boxSize ? kPrimaryColor : null,
              border: Border(
                right: BorderSide(
                  color: Colors.black12,
                  width: 1.0,
                ),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      category,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: boxSize == state.boxSize
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                    Icon(
                      Icons.inbox,
                      color: boxSize == state.boxSize
                          ? Colors.white
                          : Colors.black26,
                    )
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Text(
                      "Preis:",
                      style: TextStyle(
                        color: boxSize == state.boxSize
                            ? Colors.white
                            : Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(
                      width: 7,
                    ),
                    Text(
                      "€" + price,
                      style: TextStyle(
                        fontSize: 15,
                        color: boxSize == state.boxSize
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 3,
                ),
                Row(
                  children: [
                    Text(
                      "Größe:",
                      style: TextStyle(
                          color: boxSize == state.boxSize
                              ? Colors.white
                              : Colors.black54,
                          fontSize: 16),
                    ),
                    SizedBox(
                      width: 7,
                    ),
                    Text(
                      size + "cm",
                      style: TextStyle(
                        color: boxSize == state.boxSize
                            ? Colors.white
                            : Colors.black,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
