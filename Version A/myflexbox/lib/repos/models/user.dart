import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';

class DBUser {
  String email;
  String name;
  String number;
  String uid;
  List<String> favourites;

  DBUser(this.email, this.name, this.number, this.uid, this.favourites);
  DBUser.json({this.email, this.name, this.number, this.uid, this.favourites});

  Map<String, dynamic> toJson() =>
      {
        'name': name,
        'email': email,
        'number' : number,
        'uid' : uid,
        'favourites' : favourites,
      };

  factory DBUser.fromJson(Map<dynamic,dynamic> json){
    var favouritesFromJson = json['favourites'];
    List<String> favouritesList = [];
    if(favouritesFromJson != null){
      Map<String,dynamic> favouriteMap = new Map<String,dynamic>.from(favouritesFromJson);
      favouriteMap.forEach((key, value) => favouritesList.add(key));
    }

    return DBUser.json(
      name: json['name'] as String,
      email: json['email'] as String,
      number: json['number'] as String,
      uid: json['uid'] as String,
      favourites: favouritesList
    );
  }
}