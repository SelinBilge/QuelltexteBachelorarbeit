import 'package:equatable/equatable.dart';
import 'package:myflexbox/repos/models/google_places_data.dart';
import 'package:myflexbox/repos/models/locker.dart';

enum BoxSize { m, s, l}

abstract class RentLockerState extends Equatable {
  final BoxSize boxSize;
  final DateTime startDate;
  final DateTime endDate;
  final MapsLocationData chosenLocation;
  final MapsLocationData myLocation;
  final List<Locker> lockerList;

  const RentLockerState({
    this.boxSize,
    this.startDate,
    this.endDate,
    this.chosenLocation,
    this.myLocation,
    this.lockerList,
  });

  @override
  List<Object> get props => [];
}


class FilterRentLockerState extends RentLockerState {
  @override
  List<Object> get props =>
      [boxSize, startDate, endDate, chosenLocation, myLocation];

  FilterRentLockerState({
    DateTime startDate,
    DateTime endDate,
    BoxSize boxSize,
    MapsLocationData location,
    MapsLocationData myLocation,
    List<Locker> lockerList,
  }) : super(
            boxSize: boxSize,
            startDate: startDate,
            endDate: endDate,
            chosenLocation: location,
            myLocation: myLocation,
            lockerList: lockerList);
}

class FilterRentLockerLoadingState extends RentLockerState {
  @override
  List<Object> get props =>
      [boxSize, startDate, endDate, chosenLocation, myLocation];

  FilterRentLockerLoadingState({
    DateTime startDate,
    DateTime endDate,
    BoxSize boxSize,
    MapsLocationData location,
    MapsLocationData myLocation,
    List<Locker> lockerList,
  }) : super(
      boxSize: boxSize,
      startDate: startDate,
      endDate: endDate,
      chosenLocation: location,
      myLocation: myLocation,
      lockerList: lockerList);
}

class MapRentLockerState extends RentLockerState {
  @override
  List<Object> get props =>
      [boxSize, startDate, endDate, chosenLocation, myLocation];

  MapRentLockerState({
    DateTime startDate,
    DateTime endDate,
    BoxSize boxSize,
    MapsLocationData location,
    MapsLocationData myLocation,
    List<Locker> lockerList,
  }) : super(
            boxSize: boxSize,
            startDate: startDate,
            endDate: endDate,
            chosenLocation: location,
            myLocation: myLocation,
            lockerList: lockerList);
}

class MapRentLockerLoadingState extends RentLockerState {
  @override
  List<Object> get props =>
      [boxSize, startDate, endDate, chosenLocation, myLocation];

  MapRentLockerLoadingState({
    DateTime startDate,
    DateTime endDate,
    BoxSize boxSize,
    MapsLocationData location,
    MapsLocationData myLocation,
    List<Locker> lockerList,
  }) : super(
      boxSize: boxSize,
      startDate: startDate,
      endDate: endDate,
      chosenLocation: location,
      myLocation: myLocation,
      lockerList: lockerList);
}

class SubmitRentLockerState extends RentLockerState {}
