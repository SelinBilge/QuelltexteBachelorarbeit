import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:myflexbox/repos/models/user.dart';

///here you find all constants which can be used in the whole app
///Colors
const kPrimaryColor = Color(0xFFD20A10);
const kPrimaryLightColor = Color(0xFFFFECDF);
const kPrimaryGradientColor = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFFFA53E), Color(0xFFFFF7643)],
);
const kSecondaryColor = Color(0xFF979797);
const kTextColor = Color(0xFF757575);

///Duration (for Animations)
const kAnimationDuration = Duration(microseconds: 200);

List<DBUser> favouriteContacts = [];

FirebaseAnalytics analyticsService;