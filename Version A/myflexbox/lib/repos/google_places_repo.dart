import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'models/google_places_data.dart';

class GooglePlacesRepo {
  final client = Client();

  GooglePlacesRepo();

  static final String androidKey = 'AIzaSyDYdoUpfz9nP-v_-bwdehX9Qkgg6YDm24w';
  static final String iosKey = 'AIzaSyDYdoUpfz9nP-v_-bwdehX9Qkgg6YDm24w';
  final apiKey = Platform.isAndroid ? androidKey : iosKey;

  Future<List<Suggestion>> fetchSuggestions(String input, String lang) async {
    final request =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&language=de&components=country:at&key=$apiKey';
    final response = await client.get(Uri.parse(request));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        // compose suggestions in a list
        return result['predictions']
            .map<Suggestion>((p) => Suggestion(p['place_id'], p['description']))
            .toList();
      }
      if (result['status'] == 'ZERO_RESULTS') {
        return [];
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }

  Future<MapsLocationData> getPlaceDetailFromId(String placeId, String placeDescription) async {
    final request =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=geometry&key=$apiKey';
    final response = await client.get(Uri.parse(request));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        print(result['result']['geometry']['location']);
        final components =
        result['result']['geometry']['location'] as Map<String, dynamic>;
        // build result
        final location = MapsLocationData();
        location.lat = components["lat"];
        location.long = components["lng"];
        location.description = placeDescription;

        //check if its a city or a full address
        String ld = location.description;
        int countOfComma = 0;
        for (int i = ld.indexOf(",");
        i >= 0;
        i = location.description.indexOf(",", i + 1)) {
          countOfComma++;
        }
        if(countOfComma  >= 2) {
          location.isExactLocation = true;
        } else {
          location.isExactLocation = false;
        }
        return location;
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }
}