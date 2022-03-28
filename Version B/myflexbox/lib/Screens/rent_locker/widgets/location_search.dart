import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:myflexbox/repos/google_places_repo.dart';
import 'package:myflexbox/repos/models/google_places_data.dart';

class AddressSearch extends SearchDelegate<Suggestion> {
  AddressSearch() {
    apiClient = GooglePlacesRepo();
  }

  GooglePlacesRepo apiClient;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        tooltip: 'Clear',
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder(
      // We will put the api call here
      future: query == ""
          ? null
          : apiClient.fetchSuggestions(
          query, Localizations.localeOf(context).languageCode),
      builder: (context, snapshot) => query == ''
          ? Container(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Adresse eingeben',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 17,
            color: Colors.black54,
          ),
        ),
      )
          : snapshot.hasData
          ? ListView.builder(
        itemBuilder: (context, index) => ListTile(
          // we will display the data returned from our future here
          title: Text(
            snapshot.data[index].toString(),
            style: TextStyle(
              fontSize: 17,
              color: Colors.black54,
            ),
          ),
          onTap: () {
            close(context, snapshot.data[index]);
          },
        ),
        itemCount: snapshot.data.length,
      )
          : Center(
          child: SizedBox(
            child: CircularProgressIndicator(
              strokeWidth: 4,
            ),
            height: 30.0,
            width: 30.0,
          )),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder(
      // We will put the api call here
      future: query == ""
          ? null
          : apiClient.fetchSuggestions(
              query, Localizations.localeOf(context).languageCode),
      builder: (context, snapshot) => query == ''
          ? Container(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Adresse eingeben',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.black54,
                ),
              ),
            )
          : snapshot.hasData
              ? ListView.builder(
                  itemBuilder: (context, index) => ListTile(
                    // we will display the data returned from our future here
                    title: Text(
                      snapshot.data[index].toString(),
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.black54,
                      ),
                    ),
                    onTap: () {
                      close(context, snapshot.data[index]);
                    },
                  ),
                  itemCount: snapshot.data.length,
                )
              : Center(
                  child: SizedBox(
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                  ),
                  height: 30.0,
                  width: 30.0,
                )),
    );
  }
}
