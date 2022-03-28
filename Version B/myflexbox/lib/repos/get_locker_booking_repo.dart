import 'dart:convert';
import 'dart:io';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:myflexbox/repos/models/booking.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'models/locker.dart';
import 'models/user.dart';

class GetLockerBooking {
  FirebaseDatabase database;
  DatabaseReference shareDB;
  DatabaseReference userDB;

  GetLockerBooking() {
    database = FirebaseDatabase();
    shareDB = database.reference().child('share');
    userDB = database.reference().child('Users');
  }

  ///the [apiKey] is needed in each api call and is stored in the auth header
  final String apiKey =
      "Basic 77+977+90IcGI++/vVQhWjDvv73vv70R77+9Nh/vv70yVTIoe++/vRDvv71WVwBd77+9";

  ///the [baseUrl] is needed in each api call for building the url endpoint
  final String baseUrl = "https://dev-myflxbx-rest.azurewebsites.net";

  //Gets the list of Bookings for the user id
  //Transforms all Bookings that are shared by the user to BookingsTo
  //Gets the list of Bookings that are shared to the user, and combines the two lists
  Future<List<Booking>> getBookings(String externalId) async {
    var url = '$baseUrl/api/1/bookings?externalId=$externalId';//
    final response = await http.get(
      Uri.parse(url),
      headers: {HttpHeaders.authorizationHeader: apiKey},
    );

    //Get the Bookings of the user
    if (response.statusCode == 200) {
      List<Booking> userBookings = json
          .decode(response.body)['bookings']
          .map((data) => Booking.fromJson(data))
          .toList()
          .cast<Booking>();
      //Transform the Bookings of the user to BookingsTo if they are shared by the user
      await transformSharedBookings(externalId, userBookings);
      //Get the Bookings that are Shared  to the user
      List<Booking> sharedToUserBookings =
          await getSharedBookingsFrom(externalId);
      //Add the own bookings to the bookings, shared by the user
      sharedToUserBookings.addAll(userBookings);

      sharedToUserBookings.sort((a,b) {
        return a.startTime.compareTo(b.startTime);
      });

      return sharedToUserBookings;
    } else {
      return [];
    }
  }

  //Transforms Bookings in the passed list to BookingsTo if the user with the
  // externalId has shared a locker with others.
  Future<void> transformSharedBookings(
      String externalID, List<Booking> bookingList) async {
    //Get all Booking IDs of bookings shared by the user
    DataSnapshot toF =
        await shareDB.orderByChild("from").equalTo(externalID).once();
    Map<dynamic, dynamic> sharedBookings = toF.value;
    if (sharedBookings != null) {
      //For each bookingID, get the User that its shared to
      //Transform the booking in the list to a BookingTo with the User
      for (int i = 0; i < bookingList.length; i++) {
        try {
          String bId = bookingList[i].bookingId.toString();
          if (sharedBookings.containsKey(bId)) {
            //Get user that the booking is shared to
            String toId = sharedBookings[bId]['to'] as String;
            DBUser toUser = toId.startsWith("+43")
                ? await getUserWithNumber(toId)
                : await getUser(toId);
            //Transform
            bookingList[i] = BookingTo(bookingList[i], toUser);
          }
        } catch (e) {
          print(e.toString());
        }
      }
    }
  }

  //Creates a List with BookingsFrom, that contains all booking that are shared
  // to the user with the externalID
  Future<List<Booking>> getSharedBookingsFrom(String externalID) async {
    //Get all Booking IDs of bookings shared to the user
    DataSnapshot fromF =
        await shareDB.orderByChild("to").equalTo(externalID).once();
    Map<dynamic, dynamic> sharedBookings = fromF.value;
    //For each bookingID, get the User that its shared by
    //Create a new BookingFrom with the User that its shared by and add it to the list
    if (sharedBookings != null) {
      List<Booking> fromBookingList = [];
      await Future.forEach(sharedBookings.entries, ((entry) async {
        Booking booking = await getBooking(entry.key);
        if (booking != null) {
          String fromId = entry.value['from'] as String;
          DBUser fromUser = await getUser(fromId);
          BookingFrom bookingFrom = BookingFrom(booking, fromUser);
          fromBookingList.add(bookingFrom);
        }
      }));
      return fromBookingList;
    } else {
      return [];
    }
  }

  ///this method Retrieves one [Booking] with a given bookingId
  Future<Booking> getBooking(String bookingId) async {
    var url = '$baseUrl/api/1/booking?bookingId=${bookingId}';
    final response = await http.get(
      Uri.parse(url),
      headers: {HttpHeaders.authorizationHeader: apiKey},
    );

    if (response.statusCode == 200) {
      return Booking.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      return null;
    }
  }

  //Returns a FlexBox User with the given ID
  Future<DBUser> getUser(String uid) async {
    DataSnapshot user =
        await database.reference().child('Users').child(uid).once();
    if (user.value != null) {
      return Future.value(DBUser.fromJson(user.value));
    } else {
      return DBUser("", uid, uid, null, []);
    }
  }

  // Returns a User with the given number.
  //Search in the contacts for a name
  //If none, is found, the number is used as name
  //The id is set to null
  Future<DBUser> getUserWithNumber(String number) async {
    List<Contact> _contacts = (await ContactsService.getContactsForPhone(
      number,
      withThumbnails: false,
      photoHighResolution: false,
    ))
        .toList();
    if (_contacts.isEmpty) {
      return DBUser("", number, number, null, []);
    } else {
      String name = _contacts[0].displayName;
      return DBUser("", name, number, null, []);
    }
  }

  ///this method deletes one [Booking] with a given bookingId
  Future<bool> deleteBooking(String bookingId) async {
    var url = '$baseUrl/api/1/booking?bookingId=${bookingId}';
    final response = await http.delete(
      Uri.parse(url),
      headers: {HttpHeaders.authorizationHeader: apiKey},
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  //Returns the QR code as MemoryImage for a locker with the id
  Future<MemoryImage> getQR(int id) async {
    var url = '$baseUrl/api/1/qr?code=$id';
    final response = await http.get(
      Uri.parse(url),
      headers: {HttpHeaders.authorizationHeader: apiKey},
    );

    if (response.statusCode == 200) {
      return MemoryImage(response.bodyBytes);
    } else {
      // If the server did not return a 200 OK response,
      return null;
    }
  }

  Future<Locker> getLocker(int lockerId) async {
    var url = '$baseUrl/api/1/locker?lockerId=$lockerId';
    final response = await http.get(
      Uri.parse(url),
      headers: {HttpHeaders.authorizationHeader: apiKey},
    );

    if (response.statusCode == 200) {
      print(jsonDecode(response.body));
      Locker locker = Locker.fromJson(jsonDecode(response.body)["locker"]);
      return locker;
    } else {
      return null;
    }
  }

  //Creates a new share in the firebase
  Future<void> shareBooking(String toId, String fromId, int bookingID) async {
    await shareDB
        .child(bookingID.toString())
        .set({"to": toId.toString(), "from": fromId.toString()});
  }

  //Deletes a Share from the firebase
  Future<void> deleteShare(String bookingID) async {
    print(bookingID);
    await shareDB.child(bookingID).remove();
  }

  //If the locker was shared with a contact or a new number,
  // check if this number has a flexbox account
  // If so, change the share to value from the number to the id, and the
  //number is added to favorites
  Future<String> checkIfFlexBoxUser(
      String number, String fromId, int bookingID) async {
    DataSnapshot contact =
        await userDB.orderByChild('number').equalTo(number).once();
    if (contact.value != null) {
      Map<dynamic, dynamic>.from(contact.value).forEach((key, values) {
          //set favorite
          userDB.child(fromId).child("favourites").child(key).set({"key": key});
          //update the shareBooking entry
          shareBooking(key, fromId, bookingID);
          return key;
      });
    }
    return null;
  }
}
