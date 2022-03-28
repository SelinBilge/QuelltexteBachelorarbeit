import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myflexbox/cubits/current_locker/current_locker_cubit.dart';
import 'package:myflexbox/repos/models/booking.dart';
import 'package:myflexbox/repos/models/locker.dart';
import 'package:myflexbox/repos/models/user.dart';
import 'package:myflexbox/repos/notification_repo.dart';
import 'package:myflexbox/repos/user_repo.dart';
import 'locker_detail_state.dart';
import 'package:myflexbox/repos/get_locker_booking_repo.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_sms/flutter_sms.dart';

class LockerDetailCubit extends Cubit<LockerDetailState> {
  final GetLockerBooking currentLockersRepository;
  final UserRepository userRepository = new UserRepository();
  final NotificationRepo notificationRepo = new NotificationRepo();
  final CurrentLockerCubit currentLockerCubit;

  LockerDetailCubit(
      Booking booking, this.currentLockersRepository, this.currentLockerCubit)
      : super(LockerDetailStateDefault(booking, null));

  //Show the QR Page
  void showQR() async {
    emit(LockerDetailStateLoading(state.booking, state.locker));
    MemoryImage image =
        await currentLockersRepository.getQR(state.booking.compartmentId);
    emit(LockerDetailStateQR(state.booking, image, state.locker));
  }

  // Shows the Share Page
  // Sets the contact and favorite lists in the state
  void showShare(List<String> favoriteIds) async {
    emit(LockerDetailStateShare(
        state.booking, null, null, null, null, "", state.locker));
    //Get the list of favorite DBUsers
    List<DBUser> favList = [];
    for (final favoriteID in favoriteIds) {
      favList.add(await userRepository.getUserFromDB(favoriteID));
    }
    //Get contacts without favorites and modify favList names
    List<DBUser> contactsWithoutFavorites =
        await userRepository.getContactsWithoutFavorites(favList);

    //Emit state
    if (state is LockerDetailStateShare) {
      var shareState = state as LockerDetailStateShare;
      emit(LockerDetailStateShare(
          shareState.booking,
          contactsWithoutFavorites,
          contactsWithoutFavorites,
          favList,
          favList,
          shareState.filter,
          state.locker));
    }
  }

  //Filters the SharePage with the passed Filters
  void filterShare(String filter) async {
    if (state is LockerDetailStateShare) {
      var shareState = state as LockerDetailStateShare;
      List<DBUser> filteredContacts = [];
      List<DBUser> filteredFavorites = [];

      //Select all Users from state.favorites that match the filter
      //and add them to the new filtered favorites list
      if (filter.isNotEmpty && shareState.favorites != null) {
        for (DBUser user in shareState.favorites) {
          if (user.name.toLowerCase().contains(filter.toLowerCase()) ||
              user.number
                  .toString()
                  .toLowerCase()
                  .contains(filter.toLowerCase())) {
            filteredFavorites.add(user);
          }
        }
      } else {
        filteredFavorites = shareState.favorites;
      }
      //Select all Users from state.contacts that match the filter
      //and add them to the new filtered contacts list
      if (filter.isNotEmpty && shareState.contacts != null) {
        for (DBUser user in shareState.contacts) {
          if (user.name.toLowerCase().contains(filter.toLowerCase()) ||
              user.number
                  .toString()
                  .toLowerCase()
                  .contains(filter.toLowerCase())) {
            filteredContacts.add(user);
          }
        }
      } else {
        filteredContacts = shareState.contacts;
      }
      emit(LockerDetailStateShare(
          shareState.booking,
          shareState.contacts,
          filteredContacts,
          shareState.favorites,
          filteredFavorites,
          filter,
          state.locker));
    }
  }

  //Get Position and emit when its returned
  void getPosition() async {
    Locker position =
        await currentLockersRepository.getLocker(state.booking.lockerId);
    if (state is LockerDetailStateDefault) {
      emit(LockerDetailStateDefault(state.booking, position));
    }
    if (state is LockerDetailStateShare) {
      LockerDetailStateShare shareState = (state as LockerDetailStateShare);
      emit(LockerDetailStateShare(
          shareState.booking,
          shareState.contacts,
          shareState.contactsFiltered,
          shareState.favorites,
          shareState.favoritesFiltered,
          shareState.filter,
          position));
    }
    if (state is LockerDetailStateQR) {
      LockerDetailStateQR qrState = (state as LockerDetailStateQR);
      emit(LockerDetailStateQR(state.booking, qrState.qr, position));
    }
    if (state is LockerDetailStateLoading) {
      emit(LockerDetailStateLoading(state.booking, position));
    }
  }

  //Shows the default page
  void showDefault() async {
    emit(LockerDetailStateDefault(state.booking, state.locker));
  }

  void shareFlexBox(DBUser userTo, DBUser userFrom) async {
    String toID = userTo.uid == null ? userTo.number : userTo.uid;
    String fromID = userFrom.uid == null ? userFrom.number : userFrom.uid;

    emit(LockerDetailStateLoading(state.booking, state.locker));
    await currentLockersRepository.shareBooking(
        toID, fromID, state.booking.bookingId);
    var newBooking = BookingTo(state.booking, userTo);
    currentLockerCubit.loadDataBackground();
    emit(LockerDetailStateDefault(newBooking, state.locker));

    //Check if the user is a flexbox user and send notification
    if (userTo.uid == null) {
      //Check if is a FLexBox User
      toID = await currentLockersRepository.checkIfFlexBoxUser(
          userTo.number, fromID, state.booking.bookingId);
      if (toID != null) {
        //Is a flexboxUser
        //send notification
        notificationRepo.notifyLockerShared(userFrom, toID, state.booking);
      }
    } else {
      //Is a flexboxUser
      //send notification
      notificationRepo.notifyLockerShared(userFrom, toID, state.booking);
    }
  }

  void shareViaWhatsapp(DBUser userTo, DBUser userFrom) async {
    if (state is LockerDetailStateShare) {
      launch("https://wa.me/${userTo.number}?text=Hello");
      shareFlexBox(userTo, userFrom);
    }
  }

  void shareViaSMS(DBUser userTo, DBUser userFrom) async {
    if (state is LockerDetailStateShare) {
      sendSMS(message: "https://myflexbox.page.link/sharedLocker", recipients: [userTo.number]);
      shareFlexBox(userTo, userFrom);
    }
  }

  Future<void> deleteShare() async {
    emit(LockerDetailStateLoading(state.booking, state.locker));
    await currentLockersRepository
        .deleteShare(state.booking.bookingId.toString());
    currentLockerCubit.loadDataBackground();
    Booking updatedBooking = Booking.fromBooking(state.booking);
    emit(LockerDetailStateDefault(updatedBooking, state.locker));
  }

  Future<void> openGoogleMaps(double lat, double long) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$lat,$long';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    }
  }
}
