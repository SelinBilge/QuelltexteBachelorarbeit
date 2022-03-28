import 'package:equatable/equatable.dart';
import 'package:myflexbox/repos/models/booking.dart';

enum FilterStates {
  BOOKING_CREATED,
  COLLECTED,
  NOT_COLLECTED,
  CANCELLED
}

extension ParseToString on FilterStates {
  String toShortString() {
    return this.toString().split('.').last;
  }
}

abstract class CurrentLockerState extends Equatable {
  const CurrentLockerState(this.filter);

  final Map<FilterStates,bool> filter;

  /**
   * zum vergleichen der listen
   */
  @override
  List<Object> get props => [filter];
}

/**
 * if api call is not finished
 */
class CurrentLockerLoading extends CurrentLockerState {
  CurrentLockerLoading(Map<FilterStates,bool> filter) : super(filter);
}

class CurrentLockerList extends CurrentLockerState {
  List<Booking> bookingList;
  List<Booking> bookingListFiltered;
  String filterTxt = "";

  CurrentLockerList({this.bookingList,this.bookingListFiltered,Map<FilterStates,bool> filter, this.filterTxt}) : super(filter);

  @override
  List<Object> get props => [bookingList,filter,bookingListFiltered];
}

class CurrentLockerEmpty extends CurrentLockerState {
  CurrentLockerEmpty(Map<FilterStates,bool> filter) : super(filter);

}
