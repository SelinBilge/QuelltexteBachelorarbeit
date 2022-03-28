import 'dart:collection';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:myflexbox/config/app_router.dart';
import 'package:myflexbox/config/size_config.dart';
import 'package:myflexbox/config/constants.dart';
import 'package:myflexbox/repos/models/notification.dart';
import 'package:myflexbox/repos/models/user.dart';
import 'package:myflexbox/repos/user_repo.dart';


class ContactScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    if(analyticsService != null){
      analyticsService.logScreenView(screenName: "Contact_Screen2");
      print("ANALYTICS: logScreenView: Contact_Screen2");
    }

    ///init the SizeConfig class for height and weight calc methods
    SizeConfig().init(context);

    ///A Scaffold Widget provides a framework which implements the basic material
    /// design visual layout structure of the flutter app.
    /// It provides APIs for showing drawers, snack bars and bottom sheets.
    /// In a Scaffold you can add for example a button navigation bar
    return Scaffold(
      ///Body() is a Widget class which can be found at screens/splash/components
      body: Contacts(),
    );
  }
}


class Contacts extends StatefulWidget {
  @override
  _ContactsState createState() => _ContactsState();
}


class _ContactsState extends State<Contacts> {
  /// List for all contacts
  List<DBUser> contacts = [];

  /// list for sontacts after searcing
  List<DBUser> contactsFiltered = [];

  /// controller for searching
  TextEditingController searchController = new TextEditingController();

  /// List for favorites
  List<DBUser> _savedContacts = [];

  String mNumber = "";

  /// import all the contacts
  @override
  void initState() {
    getAllContacts();

    /// look if controller has changed or text inside the search input
    /// has changed -> you nedd a listener
    /// calls function everytime something changes in the searchcontroller text
    searchController.addListener(() {
      filterContacts();
    });
  }


  /// get all contacts that are on the phone
  getAllContacts() async {
    // save the favorites from the db
    _savedContacts = favouriteContacts;
    List<DBUser> test = await UserRepository().getContactsWithoutFavorites(_savedContacts);

    /// sort the favorites and put them at the front
    var displayContactList = _savedContacts;
    displayContactList.sort((a, b) => a.name.compareTo(b.name));
    displayContactList += test;

    /// rebuild the List after flutter has the contacts
    /// populates the list
    setState(() {
      /// remove duplicates
      contacts = displayContactList;
    });
  }

  /// filter the contact list after letters and numbers
  filterContacts(){
    List<DBUser> _contacts = [];
    _contacts.addAll(contacts);

    if(searchController.text.isNotEmpty){
      /// see which contact matches with the input in searchbar
      /// removes the ones who dont match in the list
      _contacts.retainWhere((contact) {
        String searchTerm = searchController.text.toLowerCase();
        String searchTermFlatten = flattenPhoneNumer(searchTerm);

        String contactName = contact.name.toLowerCase();
        bool nameMatches = contactName.contains(searchTerm);

        // found name
        if(nameMatches == true){
          return true;
        }

        if(searchTermFlatten.isEmpty){
          return false;
        }
        String phnFlattened = flattenPhoneNumer(contact.number);

        if(phnFlattened.contains(searchTermFlatten)){
          return phnFlattened.contains(searchTermFlatten);
        } else {
          return null;
        }

      });

      /// forces UI to rebuild and display filtered list
      setState(() {
        contactsFiltered = _contacts;
      });
    }
  }

  /// remove all special characters, except '+' at the begonning of phone number
  String flattenPhoneNumer(String phoneStr) {
    return phoneStr.replaceAllMapped(RegExp(r'^(\+)|\D'), (Match m) {
      return m[0] == "+" ? "+" : "";
    });
  }

  /// send a sms to a phonenumber who hasn't downloaded the MyFlexboxApp
  void _sendSMS(String message, List<String> recipents) async {
    String _result = await sendSMS(message: message, recipients: recipents)
        .catchError((onError) {
      print(onError);
    });
    print(_result);
  }


  ///this method is called when user types in a phoneNumber and press the add Button
  ///returns a [bool] which means:
  ///return true = user was found in db and added > you can update favourite list
  ///return false = user was not found in db > open share > but cant added to favourite list right now
  Future<bool> searchContact(String phoneNumber) async {

    var contactFromDB = await getDBContact(phoneNumber);

    if (contactFromDB.isNotEmpty ) {
      //adden in saved contacts
      for (int i = 0; i < contactFromDB.length; i++) {
        // notification: user added to favourites
        if(contactFromDB[i].number == phoneNumber){
          addNotificationUser(contactFromDB[0].uid, contactFromDB[0].name);
        }
      }
      getAllContacts();
      return true;

    } else if (contactFromDB.isEmpty){
      ///send ShareLink via SMS
      String message = "Download the MyFlexBox App \n https://myflexbox.page.link/sharedLocker";
      List<String> recipents = [phoneNumber];
      _sendSMS(message, recipents);

      /// notification: used got invited
      addNotificationUser("", phoneNumber);
      return false;
    }

  }

  /// This method adds a notification to the list for the current user
  void addNotificationUser(String friendUid, String friendName) async {
    FirebaseDatabase database = FirebaseDatabase();
    DatabaseReference userDb = database.reference().child('Notifications');

    var myUserId = FirebaseAuth.instance.currentUser.uid;
    var myUserName = FirebaseAuth.instance.currentUser.displayName;

    Messages messageUser;
    Messages messageFriend;


    /// friendUid has app
    if(friendUid != ""){
      messageUser = new Messages(friendName, "als Freund hinzugefügt", "added");

      /// notification for friend
      messageFriend = new Messages(myUserName, "hat dich als Freund hinzugefügt", "added");
      userDb.child(friendUid).push().set(messageFriend.toJson());

    } else {
      final DateTime now = DateTime. now();
      final DateFormat formatter = DateFormat('dd.MM.yyyy');
      final String formatted = formatter. format(now);

      messageUser = new Messages(friendName, "hat am ${formatted} eine Einladung erhalten.", "invited");
    }

    /// add uid to list
    userDb.child(myUserId).push().set(messageUser.toJson());

  }


  ///this method remove a dBContact from the users table which is online at the moment
  ///returns a [bool] which means:
  ///return true = user found in the favourite list and successful deleted > you can update favourite list
  ///return false = user not found or not successful deleted > you cant remove the favourite user
  Future<bool> removeDBContact(DBUser contact) async {
    FirebaseDatabase database = FirebaseDatabase();
    DatabaseReference userDb = database.reference().child('Users');
    var myUserId = FirebaseAuth.instance.currentUser.uid;


    //Removed einen user aus den favoriten
    await database.reference().child('Users').child(myUserId).child("favourites").child(contact.uid).remove();
    return true;
    /*
    DBUser myUser = await getUserFromDB(myUserId);
    var deleted = myUser.favourites.remove(contact.uid);
    bool isCompleted = false;

    //check if saving is necessary
    if (deleted) {
      isCompleted = await userDb.child(myUser.uid).set(myUser.toJson()).then((result) {
        return Future.value(true); //successful saved
      }).catchError((error) {
        return Future.value(false); //fail to save
      });
    }
    return Future.value(isCompleted);
     */
  }

  ///this method takes a [phoneNumber] param > with this number we look in the db if user already installed the app
  ///if user already in app > we return a list of [Contact] > if not return null
  Future<List<DBUser>> getDBContact(String phoneNumber) async{

    int count = 0;
    List<DBUser> contacts = [];
    FirebaseDatabase database = FirebaseDatabase();
    DatabaseReference userDb = database.reference().child('Users');
    var myUserId = FirebaseAuth.instance.currentUser.uid;

    //get my current user from db
    DBUser myUser = await getUserFromDB(myUserId);
    //get contacts list from search with the given phoneNumber
    DataSnapshot contact = await userDb.orderByChild('number').equalTo(phoneNumber).once();

    //if search not null > add all contacts to user favourites db and to list for favourites list
    DBUser user;
    if(contact.value != null){
      Map<dynamic, dynamic>.from(contact.value).forEach((key,values) {
         user = DBUser.fromJson(values);
        if(!myUser.favourites.contains(user.uid)){
          myUser.favourites.add(user.uid);
          contacts.add(user);
          favouriteContacts.add(user);
          count++;
        }
      });

      //save updated myUser to db
      if(count > 0){
        userDb.child(myUser.uid).child("favourites").child(user.uid).set({"key":user.uid});
      }
    }

    return Future.value(contacts);
  }

  ///this method query the db in the users table with the given uid as [String]
  ///returns a [DBUser] obj which is already parsed or null if user not found in db
  Future<DBUser> getUserFromDB(String uid) async {
    FirebaseDatabase database = FirebaseDatabase();
    DatabaseReference userDb = database.reference().child('Users');
    DataSnapshot user = await userDb
        .child(uid)
        .once();
    if(user.value != null){
      return Future.value(DBUser.fromJson(user.value));
    } else {
      return Future.value(null);
    }
  }

  /// Widget for UI
  @override
  Widget build(BuildContext context) {
    bool isSearching = searchController.text.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black54),
        title: Text(
          "Kontakte",
          style: TextStyle(color: Colors.black54),
        ),
      ),


      /// add Button
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () async {
          popUpDialog();
        },
      ),
      /// widget that combines common paiinting, positioning and sizing widgets
      body: Container(
        padding: EdgeInsets.all(20),
        /// displays its children in a vertical array
        child: Column(
          children: <Widget>[
            Container(
              /// search bar for filtering the contacts
              child: TextField(
                controller: searchController,
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
              ),
            ),
            /// expands a child of a row, column or flex so that the child
            /// fills the available space
            Expanded(
              /// Populates the List
                child:  ListView.builder(
                    shrinkWrap: true,
                    // check if user is searching or not
                    itemCount: isSearching == true ? contactsFiltered.length : contacts.length,
                    itemBuilder: (context, index)  {

                      DBUser contact = isSearching == true ? contactsFiltered[index] : contacts[index];
                      /// check if the user already saved the contact to favorites
                      bool alreadySaved = _savedContacts.contains(contact);

                      /// displays the user name and the phone number
                      return ListTile(
                          title: Text(contact.name),
                          subtitle: Text(
                            // when user has more phone numbers takes the first one
                            //contact.phones.elementAt(0).value
                            contact.number
                          ),
                          /// if the user has an image saved for the contact show the image
                          /// else show the initials of the name from the contact
                          /// 
                          leading:
                          CircleAvatar(
                            child: Text(contact.name.substring(0, 1),
                            style: TextStyle(
                              color: Colors.white,
                            )),
                            backgroundColor:  Theme.of(context).primaryColor,),

                          trailing: new IconButton(icon: Icon(alreadySaved ? Icons.favorite:
                          Icons.favorite_border, color: alreadySaved ? Colors.red: null),
                              onPressed: () {
                                setState(() {

                                  if(alreadySaved) {
                                    /// remove from firebase
                                    removeDBContact(contact);

                                    while(_savedContacts.contains(contact)){
                                      _savedContacts.remove(contact);
                                    }
                                    contacts.add(contact);
                                    getAllContacts();

                                  } else {
                                    /// add contact to firebase
                                    getDBContact(contact.number);

                                    _savedContacts.add(contact);
                                    contacts.remove(contact);
                                    getAllContacts();
                                  }

                                });
                              })
                      );
                    })
            )
          ],
        ),
      ),
    );
  }


  /// Dialog for inviting a contact
  popUpDialog() {
    Widget cancelButton = FlatButton(
      child: Text('Abbrechen'),
      onPressed: (){
        Navigator.of(context).pop();
      },
    );

    Widget deleteButton = FlatButton(
      color: Colors.red,
      child: Text('Hinzufügen'),
      onPressed: () async {
        searchContact(mNumber);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text('Freund hinzufügen'),
      content: Text('Füge einen Freund hinzu oder lade ihn ein wenn er die MyFlexbox App nicht benutzt.'),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(width: 280,
                child: InternationalPhoneNumberInput(
                  onInputChanged: (phoneNumber) {
                    mNumber = phoneNumber.phoneNumber;
                  },
                  errorMessage: "",
                  hintText: "Telefonnummer",
                  spaceBetweenSelectorAndTextField: 5,
                  locale: "AT",
                  autoFocus: false,
                  autoFocusSearch: false,
                  autoValidateMode: AutovalidateMode.always,
                  countries: ["AT", "DE"],
                  ignoreBlank: false,
                  inputBorder: OutlineInputBorder(),
                  selectorConfig: SelectorConfig(
                    setSelectorButtonAsPrefixIcon: true,
                  ),
                ))
          ],
        ),

        Row(mainAxisAlignment: MainAxisAlignment.end,children: <Widget>[
          SizedBox(width: 100,child: cancelButton),
          SizedBox(width: 100,child: deleteButton)
        ],)
      ],
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }


}