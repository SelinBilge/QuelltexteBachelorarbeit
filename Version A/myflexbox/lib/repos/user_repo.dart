import 'dart:async';

import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:myflexbox/config/constants.dart';

import 'models/user.dart';

// Handles the communication with the database, concerning the user.
class UserRepository {
  FirebaseDatabase database;
  DatabaseReference userDb;

  ///Constructor of the UserRepository
  ///here the database reference is set
  UserRepository() {
    database = FirebaseDatabase();
    userDb = database.reference().child('Users');
  }

  ///this method adds a new entry into the Users table on the firebase database
  ///param [user] is the user which get stored in the db
  Future<bool> addUserToDB(DBUser user) async {
    var test = await userDb.child(user.uid).set(user.toJson());
    return Future.value(true);
  }

  ///this method checks the phonebook and search for each [Contact] in it in the userDB
  ///if a
  Future<bool> addFavouritesToUser(DBUser user) async {
    List<Contact> _contacts = (await ContactsService.getContacts()).toList();

    List<String> numberList = [];

    for (int i = 0; i < _contacts.length; i++) {
      var contactNumbers = _contacts[i].phones.toList();
      for (int j = 0; j < _contacts[i].phones.length; j++) {
        numberList.add(contactNumbers[j].value.replaceAll(" ", ""));
      }
    }

    for (int i = 0; i < numberList.length; i++) {
      if (numberList[i].isNotEmpty) {
        addFavouriteToFirebase(numberList[i], user);
      }
    }

    return Future.value(true);
  }

  Future<void> addFavouriteToFirebase(String number, DBUser user) async {
    DataSnapshot contact =
        await userDb.orderByChild('number').equalTo(number).once();
    print('favouriteAdded');
    if (contact.value != null && user.uid != contact.value) {
      Map<dynamic, dynamic>.from(contact.value).forEach((key, values) {
        userDb.child(user.uid).child("favourites").child(key).set({"key": key});
      });
    }
  }

  ///this method query all favourite [DBUser] and saves it into [favouriteContacts] for global usage
  Future<void> getFavouriteUsers(String uid) async {
    DBUser myUser = await getUserFromDB(uid);

    for (int i = 0; i < myUser.favourites.length; i++) {
      DBUser user = await getUserFromDB(myUser.favourites[i]);
      if (user != null && !favouriteContacts.contains(user)) {
        favouriteContacts.add(user);
      }
    }
  }

  ///this method gets a user from the firebase db after he start the app
  ///param [uid] is the unique firebase identifier of the user
  ///returns [DBUser] object
  Future<DBUser> getUserFromDB(String uid) async {
    DataSnapshot user = await userDb.child(uid).once();
    if (user.value != null) {
      return Future.value(DBUser.fromJson(user.value));
    } else {
      return Future.value(null);
    }
  }

  //Returns all contact as a list of users, if they are not already favorites
  //Also adds the name of the Contact to the flexbox username in the passed
  //favList
  Future<List<DBUser>> getContactsWithoutFavorites(List<DBUser> favList) async {
    //Get all contacts
    List<Contact> _contacts = (await ContactsService.getContacts(
      withThumbnails: false,
      photoHighResolution: false,
    )).toList();

    List<DBUser> contactList = [];
    //Loop all contacts
    for (int i = 0; i < _contacts.length; i++) {
      //Loop all numbers of a contact
      var contactNumbers = _contacts[i].phones.toList();
      for (int j = 0; j < _contacts[i].phones.length; j++) {
        var isFavorite = false;
        var contactNumber = contactNumbers[j].value.replaceAll(" ", "");
        //check if the number is not a duplicated for the contact
        if (!(j > 0 &&
            contactNumbers[j - 1].value.replaceAll(" ", "") == contactNumber)) {
          //check if the contact is a favorite
          for (int t = 0; t < favList.length; t++) {
            //if yes, add the name to the favorite
            if (favList[t].number == contactNumber) {
              isFavorite = true;
              favList[t].name += " (" + _contacts[i].displayName + ")";
            }
          }
          //if not, add contact to the list
          if (!isFavorite) {
            contactList.add(
                DBUser("", _contacts[i].displayName, contactNumber, null, []));
          }
        }
      }
    }
    return contactList;
  }
}
