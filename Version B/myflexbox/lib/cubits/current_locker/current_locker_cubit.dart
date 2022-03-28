import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myflexbox/repos/get_locker_booking_repo.dart';
import 'package:myflexbox/repos/models/booking.dart';
import 'current_locker_state.dart';


class CurrentLockerCubit extends Cubit<CurrentLockerState> {
  GetLockerBooking repo = new GetLockerBooking();
  var myUserId = FirebaseAuth.instance.currentUser.uid;
  String filterTxt = "";
  var filterState;
  //todo get userid from firebase and put it into getBookings if everything is ready


  CurrentLockerCubit()
      : super(new CurrentLockerLoading({
    FilterStates.BOOKING_CREATED : true,
    FilterStates.COLLECTED : true,
    FilterStates.NOT_COLLECTED : true,
    FilterStates.CANCELLED : true,
  }));

  Future<void> loadData() async{
    emit(new CurrentLockerLoading(state.filter));
    loadDataBackground();
  }

  //Needed for error-free background actualisation
  Future<void> loadDataBackground() async{
    var userId = FirebaseAuth.instance.currentUser.uid;
    List<Booking> bookingList = await repo.getBookings(userId);
      if(bookingList.isNotEmpty){
        //change to filterData if ready
        var filteredList = filterData(state.filter, bookingList, "");
        emit(new CurrentLockerList(bookingList: bookingList, bookingListFiltered: filteredList,filter: state.filter, filterTxt: ""));
      } else {
        emit(new CurrentLockerEmpty(state.filter));
      }
  }

  Future<void> changeFilter(FilterStates filterSate) async {
    if(state is CurrentLockerList){
      Map<FilterStates,bool> updatedMap = new Map.from(state.filter);
      updatedMap[filterSate] = !updatedMap[filterSate];
      var filteredList = filterData(updatedMap, (state as CurrentLockerList).bookingList, (state as CurrentLockerList).filterTxt);
      emit(new CurrentLockerList(bookingList: (state as CurrentLockerList).bookingList, bookingListFiltered: filteredList, filter: updatedMap, filterTxt: (state as CurrentLockerList).filterTxt));
    }
  }

  Future<void> changeTextFilter(String txt) async {
    if(state is CurrentLockerList){
      var filteredList = filterData(state.filter, (state as CurrentLockerList).bookingList, txt);
      emit(new CurrentLockerList(bookingList: (state as CurrentLockerList).bookingList, bookingListFiltered: filteredList, filter: state.filter, filterTxt: txt));
    }
  }


  List<Booking> filterData(Map<FilterStates, bool> filter, List<Booking> bookingList, String filterTxt){
      //create new list and return theme after the loop
      List<Booking> filteredList = [];

      for(int i = 0; i < bookingList.length; i++){
        if(filterTextSearch(filterTxt, bookingList[i])){
          if(bookingList[i].state == FilterStates.BOOKING_CREATED.toShortString() && filter[FilterStates.BOOKING_CREATED] == true){
            filteredList.add(bookingList[i]);
          } else if(bookingList[i].state == FilterStates.COLLECTED.toShortString() && filter[FilterStates.COLLECTED] == true){
            filteredList.add(bookingList[i]);
          }  else if(bookingList[i].state == FilterStates.NOT_COLLECTED.toShortString() && filter[FilterStates.NOT_COLLECTED] == true){
            filteredList.add(bookingList[i]);
          }  else if(bookingList[i].state == FilterStates.CANCELLED.toShortString() && filter[FilterStates.CANCELLED] == true){
            filteredList.add(bookingList[i]);
          }
        }
      }//end loop
      return filteredList;

  }

  bool filterTextSearch(String txt, Booking booking){

      if(txt == ""){
        return true;
      } else if(convertDate(booking.startTime).contains(txt)){
        return true;
      } else if(convertDate(booking.endTime).contains(txt)){
        return true;
      } else if(booking is BookingFrom){
        if(booking.fromUser.name.contains(txt)){
          return true;
        }
      }

    return false;
  }

  String convertDate(String date) {
    var time = DateTime.parse(date);
    return time.day.toString() +
        "." +
        time.month.toString() +
        "." +
        time.year.toString();
  }
}

