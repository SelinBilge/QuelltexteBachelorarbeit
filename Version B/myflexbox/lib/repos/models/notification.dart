import 'dart:collection';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';

class Messages {
  String friendUid;
  String text;
  String messageType;


  Messages(this.friendUid, this.text, this.messageType);
  Messages.json({ this.friendUid, this.text, this.messageType});

  Map<String, dynamic> toJson() =>
      {
        'friendUid' : friendUid,
        'text' : text,
        'messageType' : messageType
      };

  factory Messages.fromJson(Map<dynamic,dynamic> json){

    return Messages.json(
        friendUid: json['friendUid'] as String,
        text:  json['text'] as String,
        messageType: json['messageType'] as String
    );
  }
}