import 'package:bloc/bloc.dart';

import 'bottom_nav_state.dart';

// Cubit, that handles the Bottom navigation
class BottomNavCubit extends Cubit<BottomNavState> {

  BottomNavCubit() : super(CurrentLockersNavState());

  //On changeState, the respective State is loaded
  void changePage(int newPageIndex) async {
    switch (newPageIndex) {
      case 0:
        emit(CurrentLockersNavState());
        break;
      case 1:
        emit(AddLockerNavState());
        break;
      case 2:
        emit(NotificationNavState());
        break;
      case 3:
        emit(ProfileNavState());
        break;
    }
  }
}