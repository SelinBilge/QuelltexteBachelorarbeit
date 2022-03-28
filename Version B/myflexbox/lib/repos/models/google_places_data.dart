class Suggestion {
  final String placeId;
  final String description;

  Suggestion(this.placeId, this.description);

  @override
  String toString() {
    return description;
  }
}

class MapsLocationData {
  double lat;
  double long;
  String description;
  bool isExactLocation;

  MapsLocationData.clone(MapsLocationData location)
      : this(
            lat: location.lat,
            long: location.long,
            description: location.description,
            isExactLocation: location.isExactLocation);

  MapsLocationData({this.lat, this.long, this.description, this.isExactLocation});
}
