import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:myflexbox/config/constants.dart';
import 'package:myflexbox/repos/models/notification.dart';


class CustomData extends StatefulWidget {
  CustomData({this.app});

  ///add Firebase
  final FirebaseApp app;

  @override
  _CustomDataState createState() => _CustomDataState();
}

class _CustomDataState extends State<CustomData> {
  ///add a Controller to can access the input text of adding
  final editTextController = TextEditingController();
  ///add a Controller to can access the input text for the search
  final searchTextController = TextEditingController();
  ///add a global userDb variable
  DatabaseReference userDb;
  ///add a global query variable for searching in the db
  var query;
  ///the name is used to chance the name of the db search like Stefan, ...
  String uid = "";
  ///the key is used that the firebase db knows to reloads again with another query
  var _key;

  List<Messages> messageList = [];



  ///in the init the userDb and the query gets initialized
  @override
  void initState() {
    final FirebaseDatabase database = FirebaseDatabase(app: widget.app);
    var myUserId = FirebaseAuth.instance.currentUser.uid;
    userDb = database.reference().child('Notifications').child(myUserId);
    query = userDb;

    searchTextController.addListener(() {
      filterList();
    });

    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      ///A box in which a single widget can be scrolled.
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Container(
                color: Colors.white,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: [

                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                        ),
                        child:

                          TextField(
                            controller: searchTextController,
                            decoration: InputDecoration(
                                labelText: 'Suchen',
                                border: new OutlineInputBorder(
                                    borderSide: new BorderSide(
                                        color: Theme.of(context).primaryColor
                                    )
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: Theme.of(context).primaryColor,
                                )
                            ),
                          )
                      ),
                    ),
                    ///add a button where the user can reload the db search
                    Flexible(
                      ///add the firebase Animated List
                        child: firebaseList()
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  ///function which returns a FirebaseAnimatedList
  Widget firebaseList(){
    return new FirebaseAnimatedList(
      ///If the scroll view does not shrink wrap, then the scroll view will expand
      ///to the maximum allowed size in the scrollDirection. If the scroll view
      /// has unbounded constraints in the scrollDirection, then shrinkWrap must be true.
        shrinkWrap: true,
        ///add the firebase query
        query: query,
        ///add the key > only with a different key the firebase will reload the data
        key: _key,
        ///how to sort the list
        sort: (DataSnapshot a, DataSnapshot b) =>
            b.key.compareTo(a.key),
        ///Called, as needed, to build list item widgets.
        ///List items are only built when they're scrolled into view.
        itemBuilder: (BuildContext context,
            DataSnapshot snapshot,
            Animation<double> animation,
            int index) {
          ///convert the db result to an person object
          Messages person = Messages.fromJson(snapshot.value);
          String text;
          if(person.friendUid.startsWith('+')){
             text = "Telefonnummer: ${person.friendUid}";
          } else {
             text = "Name: ${person.friendUid}";
          }

          Icon icon;
          if(person.messageType == "shared"){
             icon =  Icon(Icons.share_outlined, color: Theme.of(context).primaryColor,);

          } else if(person.messageType == "added"){
            icon =  Icon(Icons.person_add, color: Theme.of(context).primaryColor,);

          } else if(person.messageType == "invited"){
            icon = Icon(Icons.mark_email_read_rounded, color: Theme.of(context).primaryColor,);

          } else {
            icon = Icon(Icons.message, color: Theme.of(context).primaryColor,);
          }

          ///A single fixed-height row that typically contains some text as well as a leading or trailing icon.
          return new ListTile(
            leading: icon,
              horizontalTitleGap: 0.0,

              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () =>
                ///if pressed delete this item in the app and on db
                userDb.child(snapshot.key).remove(),
              ),
              title: new Text(text),
              subtitle: new Text("${person.text}")
          );
        });
  }



  /// filter the message list after letters and numbers
  filterList(){

    setState(() {
      ///save the name of the input field in the name variable
      uid = searchTextController.text;
      if(searchTextController.text.isNotEmpty){

        ///search for the specific name in the db
        query = userDb.orderByChild("friendUid").equalTo(uid);

      } else {
        ///load the whole user table if no input in the search field
        query = userDb;
      }
      ///give the key a unique dataset > for example the actual date
      _key = Key(DateTime.now().millisecondsSinceEpoch.toString());
    });
  }

  }




///Person object
class Person{
  final String email;
  final String name;
  final String token;
  final String uid;

  ///normal constructor
  Person(this.name, this.email, this.token, this.uid);
  ///constructor for parsing from a json
  ///is used in factory below
  Person.json({this.email, this.token, this.uid, this.name });

  ///from object to json
  ///is used to push the data up to the db
  Map<String, dynamic> toJson() =>
      {
        'email': email,
        'name': name,
        'token': token,
        'uid': uid
      };

  ///from json to object
  ///is used to parse the data from json to object
  factory Person.fromJson(Map<dynamic, dynamic> json) {
    return Person.json(
        email: json['email'] as String,
        name: json['name'] as String,
        token: json['token'] as String,
        uid: json['uid'] as String
    );
  }
}