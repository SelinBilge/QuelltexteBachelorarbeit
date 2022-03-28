

import 'compartment.dart';

class Locker {
  final int lockerId;
  final String externalId;
  final String name;
  final String streetName;
  final String streetNumber;
  final String postcode;
  final String city;
  final String country;
  final String countryCode;
  final double longitude;
  final double latitude;
  final String state;
  final String access;
  final String manufacturer;
  final List<Compartment> compartments;

  Locker(
      {this.compartments,
        this.lockerId,
        this.externalId,
        this.name,
        this.streetName,
        this.streetNumber,
        this.postcode,
        this.city,
        this.country,
        this.countryCode,
        this.longitude,
        this.latitude,
        this.state,
        this.access,
        this.manufacturer});

  factory Locker.fromJson(Map<String, dynamic> json) {
    var list = json['compartments'].map((data) => Compartment.fromJson(data)).toList().cast<Compartment>();
    return Locker(
      lockerId: json['lockerId'] as int,
      externalId: json['externalId'] as String,
      name: json['name'] as String,
      streetName: json['streetName'] as String,
      streetNumber: json['streetNumber'] as String,
      postcode: json['postcode'] as String,
      city: json['city'] as String,
      country: json['country'] as String,
      countryCode: json['countryCode'] as String,
      longitude: json['longitude'] as double,
      latitude: json['latitude'] as double,
      state: json['state'] as String,
      access: json['access'] as String,
      manufacturer: json['manufacturer'] as String,
      compartments: list as List<Compartment>,
    );
  }
}