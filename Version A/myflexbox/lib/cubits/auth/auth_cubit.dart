library globals;
import 'package:bloc/bloc.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:myflexbox/config/constants.dart';
import 'package:myflexbox/repos/models/form_data.dart';
import 'package:myflexbox/repos/models/user.dart';
import 'package:myflexbox/repos/user_repo.dart';
import 'auth_state.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Handles the authentication of the user
// Is available in all widgets of the app
class AuthCubit extends Cubit<AuthState> {
  final UserRepository userRepository;

  // final FirebaseA3uth _firebaseAuth;

  // UserRepository is passed in the constructor
  AuthCubit(this.userRepository) : super(AuthUninitialized());

  // Checks if the user is already logged in or not.
  // Emits the AuthLoading State at the start.
  // Emits a different state depending on the result.
  Future<void> authenticate() async {
    await Firebase.initializeApp();
    emit(AuthLoading());
    //get user with FirebaseAuth.instance.currentUser
    var firebaseUser = await FirebaseAuth.instance.currentUser;
    // instantiate Firebase Analytics
    analyticsService = await FirebaseAnalytics.instance;

    if (firebaseUser != null) {
      // set the User ID to the uid when the user is logged in
      if(analyticsService != null){
          analyticsService.setUserId(id: firebaseUser.uid);
          analyticsService.setUserProperty(name: "Version_A_or_B", value: "A");
          print("ANALYTICS: SET ID " + firebaseUser.uid);
          print("ANALYTICS: setUserProperty: A");
      }

      //get token with fireBaseUser.getIdToken(refresh: true)
      //get user name from firebase
      var user = await userRepository.getUserFromDB(firebaseUser.uid);

      if(user != null) {
        userRepository.getFavouriteUsers(user.uid);
        emit(AuthAuthenticated(user));
      } else {
        logout();
      }
    } else {
      emit(AuthUnauthenticated());
    }
  }

  // Tries login with email and password
  // If successful:
  // get the token, get the user name, create user object,
  // emit AuthAuthenticated
  // If unsuccessful:
  // Catches Exceptions thrown by firebase and returns error messages
  Future<List> loginWithEmail(String email, String password) async {
    try {
      await Future.delayed(Duration(seconds: 1));
      var firebaseUser = (await FirebaseAuth.instance
              .signInWithEmailAndPassword(email: email, password: password))
          .user;
      if (!firebaseUser.emailVerified) {
        await FirebaseAuth.instance.signOut();
        return [ErrorType.EmailError, "Email nicht verifiziert"];
      } else {
        var user = await userRepository.getUserFromDB(firebaseUser.uid);
        userRepository.getFavouriteUsers(user.uid);
        emit(AuthAuthenticated(user));
      }
    } on FirebaseAuthException catch (e) {
      print(e.toString());
      switch (e.code) {
        case "wrong-password":
          return [ErrorType.PasswordError, "Passwort ist falsch"];
        case "user-not-found":
          return [ErrorType.EmailError, "Email wurde nicht gefunden"];
        default:
          return [ErrorType.EmailError, "Es gab ein Problem beim Login"];
      }
    }
  }

  // Tries registration with email and password
  // If successful:
  // get the token, create user in the database,
  // return null
  // If unsuccessful:
  // Catches Exceptions thrown by firebase and returns error messages
  Future<List> registerWithEmail(
      String email, String password, String username, String telephone) async {
    try {
      var user = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      user.user.sendEmailVerification();

      var userDb = DBUser(email, username, telephone, user.user.uid, []);
      var success = await userRepository.addUserToDB(userDb);
      userRepository.addFavouritesToUser(userDb);
      if (success) {
        await FirebaseAuth.instance.signOut();
        return null;
      } else {
        return [ErrorType.EmailError, "Es gab ein Problem mit der Datenbank"];
      }
    } catch (e) {
      print(e.toString());
      switch (e.code) {
        case "email-already-in-use":
          return [ErrorType.EmailError, "Email wird bereits verwendet"];
        default:
          return [
            ErrorType.UsernameError,
            "Es gab ein Problem bei der Registrierung"
          ];
      }
    }
  }

  Future<void> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a new credential
    final GoogleAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    var firebaseUser =
        (await FirebaseAuth.instance.signInWithCredential(credential)).user;

    //Get user from Db, if null -> create new user
    var userDb = await userRepository.getUserFromDB(firebaseUser.uid);
    if(userDb == null) {
      userDb = DBUser(firebaseUser.email, firebaseUser.email, firebaseUser.phoneNumber, firebaseUser.uid, []);
      var success = await userRepository.addUserToDB(userDb);
      userRepository.addFavouritesToUser(userDb);
      emit(AuthAuthenticated(userDb));
    } else {
      userRepository.getFavouriteUsers(userDb.uid);
      emit(AuthAuthenticated(userDb));
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    emit(AuthUnauthenticated());
  }
}
