import 'package:bloc/bloc.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:myflexbox/cubits/rent_locker/rent_locker_state.dart';
import 'package:myflexbox/repos/models/google_places_data.dart';
import 'package:myflexbox/repos/models/locker.dart';
import 'package:myflexbox/repos/rent_locker_repository.dart';
import 'package:location/location.dart';
import 'package:geocoder/geocoder.dart';

class RentLockerCubit extends Cubit<RentLockerState> {
  final RentLockerRepository _rentLockerRepository;
  GoogleMapController mapsController;

  RentLockerCubit(this._rentLockerRepository)
      : super(FilterRentLockerState(
            boxSize: BoxSize.m,
            startDate: DateTime.now(),
            endDate: DateTime.now().add(const Duration(days: 1)),
            location: MapsLocationData(
                lat: 47.804793263105125,
                long: 13.04687978865836,
                description: "Salzburg, Österreich",
                isExactLocation: false),
            myLocation: MapsLocationData(),
            lockerList: []));

  //switch between screens
  Future<void> switchScreen() async {
    if (state is FilterRentLockerState) {
      emit(
        MapRentLockerState(
            boxSize: state.boxSize,
            startDate: state.startDate,
            endDate: state.endDate,
            location: MapsLocationData.clone(state.chosenLocation),
            myLocation: MapsLocationData.clone(state.myLocation),
            lockerList: state.lockerList),
      );
      //wait until the mapsController is initialized, then update Camera
      while (mapsController == null) {
        await Future.delayed(Duration.zero);
      }
      await Future.delayed(Duration(milliseconds: 700));
      updateCameraLocation();
    } else {
      emit(FilterRentLockerState(
          boxSize: state.boxSize,
          startDate: state.startDate,
          endDate: state.endDate,
          location: MapsLocationData.clone(state.chosenLocation),
          myLocation: MapsLocationData.clone(state.myLocation),
          lockerList: state.lockerList));
      mapsController = null;
    }
  }

  //change Box Size
  void changeBoxSize(BoxSize chosenBoxSize) {
    if (state is FilterRentLockerState) {
      emit(FilterRentLockerState(
          boxSize: chosenBoxSize,
          startDate: state.startDate,
          endDate: state.endDate,
          location: MapsLocationData.clone(state.chosenLocation),
          myLocation: MapsLocationData.clone(state.myLocation),
          lockerList: state.lockerList));
    }

    if (state is MapRentLockerState) {
      emit(MapRentLockerState(
          boxSize: chosenBoxSize,
          startDate: state.startDate,
          endDate: state.endDate,
          location: MapsLocationData.clone(state.chosenLocation),
          myLocation: MapsLocationData.clone(state.myLocation),
          lockerList: state.lockerList));
    }
    fetchResults();
  }

  //change date
  void changeDate(DateTime startDate, DateTime endDate) {
    if (state is FilterRentLockerState) {
      emit(FilterRentLockerState(
          boxSize: state.boxSize,
          startDate: startDate,
          endDate: endDate,
          location: MapsLocationData.clone(state.chosenLocation),
          myLocation: MapsLocationData.clone(state.myLocation),
          lockerList: state.lockerList));
    }
    if (state is MapRentLockerState) {
      emit(MapRentLockerState(
          boxSize: state.boxSize,
          startDate: startDate,
          endDate: endDate,
          location: MapsLocationData.clone(state.chosenLocation),
          myLocation: MapsLocationData.clone(state.myLocation),
          lockerList: state.lockerList));
    }
    fetchResults();
  }

  //change location
  void changeLocation(MapsLocationData location) {
    if (state is FilterRentLockerState) {
      emit(FilterRentLockerState(
          boxSize: state.boxSize,
          startDate: state.startDate,
          endDate: state.endDate,
          location: location,
          myLocation: MapsLocationData.clone(state.myLocation),
          lockerList: state.lockerList));
    }

    if (state is MapRentLockerState) {
      emit(MapRentLockerState(
          boxSize: state.boxSize,
          startDate: state.startDate,
          endDate: state.endDate,
          location: location,
          myLocation: MapsLocationData.clone(state.myLocation),
          lockerList: state.lockerList));
    }
    fetchResults();
  }

  Future<void> getCurrentLocation() async {
    Location _locationTracker = Location();
    try {
      var location = await _locationTracker.getLocation();
      final coordinates =
          new Coordinates(location.latitude, location.longitude);
      var addresses =
          await Geocoder.local.findAddressesFromCoordinates(coordinates);
      var first = addresses.first;
      var addressLine = first.addressLine.replaceAll("Austria", "Österreich");
      var myLocation = MapsLocationData(
          lat: location.latitude,
          long: location.longitude,
          description: addressLine,
          isExactLocation: true);
      if (state is FilterRentLockerState) {
        emit(FilterRentLockerState(
            boxSize: state.boxSize,
            startDate: state.startDate,
            endDate: state.endDate,
            location: myLocation,
            myLocation: myLocation,
            lockerList: state.lockerList));
      }

      if (state is MapRentLockerState) {
        emit(MapRentLockerState(
            boxSize: state.boxSize,
            startDate: state.startDate,
            endDate: state.endDate,
            location: myLocation,
            myLocation: myLocation,
            lockerList: state.lockerList));
      }
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        if (state is FilterRentLockerState) {
          emit(FilterRentLockerState(
              boxSize: state.boxSize,
              startDate: state.startDate,
              endDate: state.endDate,
              location: MapsLocationData.clone(state.chosenLocation),
              myLocation: MapsLocationData(),
              lockerList: state.lockerList));
        } else {
          emit(MapRentLockerState(
              boxSize: state.boxSize,
              startDate: state.startDate,
              endDate: state.endDate,
              location: MapsLocationData.clone(state.chosenLocation),
              myLocation: MapsLocationData(),
              lockerList: state.lockerList));
        }
      }
    }
    fetchResults();
  }

  Future<void> fetchResults() async {
    print(state.boxSize.toString().split('.').last);
    if (state is MapRentLockerState) {
      emit(MapRentLockerLoadingState(
          boxSize: state.boxSize,
          startDate: state.startDate,
          endDate: state.endDate,
          location: MapsLocationData.clone(state.chosenLocation),
          myLocation: MapsLocationData.clone(state.myLocation),
          lockerList: []));
    } else if (state is FilterRentLockerState) {
      emit(FilterRentLockerLoadingState(
          boxSize: state.boxSize,
          startDate: state.startDate,
          endDate: state.endDate,
          location: MapsLocationData.clone(state.chosenLocation),
          myLocation: MapsLocationData.clone(state.myLocation),
          lockerList: []));
    }

    //"2021-04-24T08%3A00%3A00%2B00%3A00",
    //"2021-04-25T16%3A00%3A00%2B00%3A00",

    //DATE FUNCTIONS
    //if the date is today, take the time from now
    var startDate = DateTime.now();
    if (state.startDate.day != startDate.day ||
        state.startDate.month != startDate.month ||
        state.startDate.year != startDate.year) {
      startDate = state.startDate;
    }
    //set start date to minutes only
    startDate = DateTime(startDate.year, startDate.month, startDate.day,
        startDate.hour, startDate.minute);
    //set end date to minutes only
    var endDate = DateTime(
        state.endDate.year, state.endDate.month, state.endDate.day, 23, 59);

    //To Iso8601String
    var endDateString =
        (Uri.encodeComponent((endDate.toIso8601String() + "+00:00")))
            .replaceAll(".000", "");
    var startDateString =
        (Uri.encodeComponent((startDate.toIso8601String() + "+00:00")))
            .replaceAll(".000", "");
    print(startDateString);
    print(endDateString);
    var lockerList = await _rentLockerRepository.getFilteredLockers(
        state.boxSize.toString().split('.').last,
        startDateString,
        endDateString,
        state.chosenLocation.lat,
        state.chosenLocation.long);

    if (state is FilterRentLockerLoadingState) {
      emit(FilterRentLockerState(
          boxSize: state.boxSize,
          startDate: state.startDate,
          endDate: state.endDate,
          location: MapsLocationData.clone(state.chosenLocation),
          myLocation: MapsLocationData.clone(state.myLocation),
          lockerList: lockerList));
    }

    if (state is MapRentLockerLoadingState) {
      emit(MapRentLockerState(
          boxSize: state.boxSize,
          startDate: state.startDate,
          endDate: state.endDate,
          location: MapsLocationData.clone(state.chosenLocation),
          myLocation: MapsLocationData.clone(state.myLocation),
          lockerList: lockerList));
      updateCameraLocation();
    }
  }

  void showLockerOnMap(LatLng latLng) async {
    emit(MapRentLockerState(
        boxSize: state.boxSize,
        startDate: state.startDate,
        endDate: state.endDate,
        location: MapsLocationData.clone(state.chosenLocation),
        myLocation: MapsLocationData.clone(state.myLocation),
        lockerList: state.lockerList));
    while (mapsController == null) {
      await Future.delayed(Duration.zero);
    }
    mapsController.animateCamera(CameraUpdate.newCameraPosition(
        new CameraPosition(target: latLng, tilt: 0, zoom: 12.4746)));
  }

  Future<void> updateCameraLocation() async {
    if (mapsController == null) {
      return;
    }
    //The location is not an exact location -> city, bundesland...
    if (!state.chosenLocation.isExactLocation || state.lockerList.length == 0) {
      mapsController.animateCamera(CameraUpdate.newCameraPosition(
          new CameraPosition(
              target:
                  LatLng(state.chosenLocation.lat, state.chosenLocation.long),
              tilt: 0,
              zoom: 12.4746)));
      return;
    }

    Locker nearestLocker = state.lockerList[0];
    LatLng source = LatLng(state.chosenLocation.lat, state.chosenLocation.long);
    LatLng destination =
        LatLng(nearestLocker.latitude, nearestLocker.longitude);
    LatLngBounds bounds;

    if (source.latitude > destination.latitude &&
        source.longitude > destination.longitude) {
      bounds = LatLngBounds(southwest: destination, northeast: source);
    } else if (source.longitude > destination.longitude) {
      bounds = LatLngBounds(
          southwest: LatLng(source.latitude, destination.longitude),
          northeast: LatLng(destination.latitude, source.longitude));
    } else if (source.latitude > destination.latitude) {
      bounds = LatLngBounds(
          southwest: LatLng(destination.latitude, source.longitude),
          northeast: LatLng(source.latitude, destination.longitude));
    } else {
      bounds = LatLngBounds(southwest: source, northeast: destination);
    }

    CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 70);

    return checkCameraLocation(cameraUpdate);
  }

  Future<void> checkCameraLocation(CameraUpdate cameraUpdate) async {
    mapsController.animateCamera(cameraUpdate);
    LatLngBounds l1 = await mapsController.getVisibleRegion();
    LatLngBounds l2 = await mapsController.getVisibleRegion();
    if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90) {
      return checkCameraLocation(cameraUpdate);
    }
  }
}
