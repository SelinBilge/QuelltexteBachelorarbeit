import 'package:flutter/material.dart';

class CurrentLockersRepository {

  Future<String> getLockers() async {
    await Future.delayed(Duration(seconds: 2));
    return "MyOnlyLocker";
  }
}