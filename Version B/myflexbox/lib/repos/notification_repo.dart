import 'package:firebase_database/firebase_database.dart';
import 'package:myflexbox/repos/models/user.dart';
import 'models/notification.dart';
import 'models/booking.dart';

class NotificationRepo {
  FirebaseDatabase database;
  DatabaseReference userDb;


  NotificationRepo() {
    database = FirebaseDatabase();
    userDb = database.reference().child('Users');
  }

  Future<void> notifyLockerShared(DBUser from, String toId, Booking booking) async {
    Messages messageFriend = new Messages(from.name, "hat dir einen Locker geteilt", "shared");
    database.reference().child('Notifications').child(toId).push().set(messageFriend.toJson());
  }

}