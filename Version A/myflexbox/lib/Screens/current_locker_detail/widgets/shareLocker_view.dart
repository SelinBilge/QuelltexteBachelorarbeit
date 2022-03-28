import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:myflexbox/cubits/auth/auth_cubit.dart';
import 'package:myflexbox/cubits/auth/auth_state.dart';
import 'package:myflexbox/cubits/locker_detail/locker_detail_cubit.dart';
import 'package:myflexbox/cubits/locker_detail/locker_detail_state.dart';
import 'package:myflexbox/repos/models/booking.dart';
import 'package:myflexbox/repos/models/user.dart';

class CurrentLockerShareView extends StatelessWidget {
  final Booking booking;
  final LockerDetailCubit cubit;

  CurrentLockerShareView({Key key, this.booking, this.cubit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
      return SingleChildScrollView(
        child: IntrinsicHeight(
          child: Column(
            children: [
              Container(height: 5),
              ShareViewMenuBar(cubit: cubit),
              ShareViewSearchField(cubit: cubit),
              ShareViewBody(cubit: cubit, booking: booking)
            ],
          ),
        ),
      );
  }
}

class ShareViewMenuBar extends StatelessWidget {
  final LockerDetailCubit cubit;

  const ShareViewMenuBar({Key key, this.cubit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: FlatButton(
            onPressed: () {
              cubit.showDefault();
            },
            child: Icon(Icons.close),
          ),
        ),
        Expanded(
          child: Center(
            child: Text("Locker teilen"),
          ),
          flex: 2,
        ),
        Expanded(
          child: FlatButton(onPressed: () {}, child: Text("")),
        ),
      ],
    );
  }
}

class ShareViewSearchField extends StatelessWidget {
  final LockerDetailCubit cubit;

  ShareViewSearchField({Key key, this.cubit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),
      child: TextFormField(
        autocorrect: false,
        onChanged: (text) async {
          print("Search bar change");
          cubit.filterShare(text);
        },
        decoration: InputDecoration(
            labelText: "Nummer oder Namen eingeben",
            hintText: "Nummer oder Namen eingeben",
            labelStyle: TextStyle(color: Colors.grey),
            focusColor: Colors.grey,
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.grey, width: 1.0),
              borderRadius: BorderRadius.all(Radius.circular(25.0)),
            ),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(25.0)))),
      ),
    );
  }
}

class ShareViewBody extends StatelessWidget {
  final Booking booking;
  final LockerDetailCubit cubit;

  const ShareViewBody({Key key, this.booking, this.cubit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LockerDetailCubit, LockerDetailState>(
        builder: (context, state) {
      //Get Contact and Favorite List and their lengths
      LockerDetailStateShare detailState = (state as LockerDetailStateShare);
      List<DBUser> contactList = detailState.contactsFiltered;
      var contactListLength = contactList == null ? 0 : contactList.length;
      List<DBUser> favoritesList = detailState.favoritesFiltered;
      var favoritesListLength =
          favoritesList == null ? 0 : favoritesList.length;

      //Depending on the state of the List, return List of NumberNotFound View
      if (favoritesList != null &&
          contactList != null &&
          favoritesListLength == 0 &&
          contactListLength == 0) {
        return ShareViewNumberNotFound(cubit: cubit, detailState: detailState);
      } else {
        return ShareViewUserList(
          cubit: cubit,
          contactList: contactList,
          favoritesList: favoritesList,
          favoritesListLength: favoritesListLength,
          contactListLength: contactListLength,
        );
      }
    });
  }
}

class ShareViewUserList extends StatelessWidget {
  final List<DBUser> contactList;
  final int contactListLength;
  final List<DBUser> favoritesList;
  final int favoritesListLength;
  final LockerDetailCubit cubit;

  const ShareViewUserList(
      {Key key,
      this.contactList,
      this.contactListLength,
      this.favoritesList,
      this.favoritesListLength,
      this.cubit})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 400,
        child: ListView.separated(
            itemBuilder: (context, index) {
              DBUser dbUser;
              //First Separator
              if (index == 0) {
                return getSeparator(
                    favoritesList, favoritesListLength, "Favoriten");
              }
              //Second Separator
              if (index == favoritesListLength + 1) {
                return getSeparator(contactList, contactListLength, "Kontakte");
              }
              //User
              if (index < favoritesListLength + 1) {
                dbUser = favoritesList[index - 1];
              } else {
                dbUser = contactList[index - (favoritesListLength + 2)];
              }
              return ListItem(dbUser, cubit);
            },
            separatorBuilder: (context, index) {
              if (index == 0 ||
                  (index == favoritesListLength + 1) ||
                  index == favoritesListLength) {
                return Container();
              }
              return Container(
                width: double.infinity,
                height: 1,
                color: Colors.grey,
              );
            },
            itemCount: favoritesListLength + contactListLength + 2));
  }

  Widget getSeparator(List<DBUser> list, int listLength, String name) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 30,
          color: Colors.grey.shade200,
          child: Center(
            child: Text(name),
          ),
        ),
        list == null
            ? Container(
                height: 140,
                child: Center(
                  child: SizedBox(
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                    ),
                    height: 30.0,
                    width: 30.0,
                  ),
                ),
              )
            : Container(),
        list != null && listLength == 0
            ? Container(
                child: Center(
                  child: Text(
                    "Keine " + name + " gefunden",
                    textAlign: TextAlign.center,
                  ),
                ),
                padding: EdgeInsets.only(top: 30, bottom: 30),
              )
            : Container(),
      ],
    );
  }
}

class ListItem extends StatelessWidget {
  final DBUser user;
  final LockerDetailCubit lockerDetailCubit;

  ListItem(this.user, this.lockerDetailCubit);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
      return Slidable(
          actionPane: SlidableDrawerActionPane(),
          child: new Builder(builder: (context) {
            return Container(
              child: ListTile(
                contentPadding:
                    EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
                title: Text(user.name),
                subtitle: Text(user.number),
                trailing: IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () => {
                          Slidable.of(context)
                              .open(actionType: SlideActionType.secondary)
                        }),
              ),
            );
          }),
          secondaryActions: user.uid == null
              ? <Widget>[
                  IconSlideAction(
                    caption: 'Whatsapp',
                    color: Colors.green,
                    icon: Icons.messenger_outline,
                    onTap: () => {
                      lockerDetailCubit.shareViaWhatsapp(
                          user, (state as AuthAuthenticated).user)
                    },
                  ),
                  IconSlideAction(
                    caption: 'SMS',
                    color: Colors.blue,
                    icon: Icons.sms_outlined,
                    onTap: () => {
                      lockerDetailCubit.shareViaSMS(
                          user, (state as AuthAuthenticated).user)
                    },
                  ),
                ]
              : <Widget>[
                  IconSlideAction(
                    caption: 'Bestätigen',
                    color: Colors.red,
                    icon: Icons.whatshot,
                    onTap: () => {
                      lockerDetailCubit.shareFlexBox(
                          user, (state as AuthAuthenticated).user)
                    },
                  ),
                ]);
    });
  }
}

class ShareViewNumberNotFound extends StatelessWidget {
  final LockerDetailStateShare detailState;
  final LockerDetailCubit cubit;

  const ShareViewNumberNotFound({Key key, this.detailState, this.cubit})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var filterText = detailState.filter;
    var validNumber = checkIfNumberValid(filterText);
    var text;
    if (validNumber) {
      text = "Das Paket an " + filterText + " senden?";
    } else {
      text =
          "Um direkt an eine Nummer zu schicken, geben Sie bitte eine gültige Telefon-Nummer ein";
    }

    return BlocBuilder<AuthCubit, AuthState>(builder: (authContext, authState) {
      return Container(
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 60,
            ),
            Container(
                child: Text(
                  "Es wurde kein passender Kontakt oder Favorit gefunden.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.grey, letterSpacing: .7, height: 1.5),
                ),
                width: 250),
            Container(
              height: 10,
            ),
            FlatButton(
                onPressed: () {
                  var number = detailState.filter;
                  var userTo = DBUser("", number, number, null, []);
                  cubit.shareViaWhatsapp(
                    userTo,
                    (authState as AuthAuthenticated).user,
                  );
                },
                color: validNumber ? Colors.green : Colors.grey,
                child: Text(
                  "Mit WhatsApp senden",
                  style: TextStyle(color: Colors.white),
                )),
            Container(
              height: 5,
            ),
            FlatButton(
                onPressed: () {
                  var number = detailState.filter;
                  var userTo = DBUser("", number, number, null, []);
                  cubit.shareViaSMS(
                    userTo,
                    (authState as AuthAuthenticated).user,
                  );
                },
                color: validNumber ? Colors.lightBlueAccent : Colors.grey,
                child: Text(
                  "Mit SMS senden",
                  style: TextStyle(color: Colors.white),
                )),
            Container(
              height: 10,
            ),
            Container(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.grey, letterSpacing: .7, height: 1.5),
                ),
                width: 250),
          ],
        ),
      );
    });
  }

  bool checkIfNumberValid(String number) {
    var numberWithoutSpaces = number.replaceAll(" ", "");
    var numberWithoutPlus = numberWithoutSpaces.replaceAll("+", "");
    if (!numberWithoutPlus.startsWith("43")) {
      return false;
    }
    if (number.length <= 6) {
      return false;
    }
    return int.tryParse(numberWithoutPlus) != null;
  }
}
