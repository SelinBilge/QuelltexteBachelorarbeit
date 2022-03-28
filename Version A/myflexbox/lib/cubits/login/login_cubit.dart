import 'package:bloc/bloc.dart';
import 'package:myflexbox/cubits/auth/auth_cubit.dart';
import 'package:myflexbox/repos/models/form_data.dart';
import 'package:myflexbox/repos/user_repo.dart';
import 'login_state.dart';

// Responsible for the LoginForm and the login procedure with the
// help of the userRepository.
class LoginCubit extends Cubit<LoginState> {
  final UserRepository userRepository;
  final AuthCubit authCubit;

  // UserRepository and the authCubit are passed as arguments.
  // The authCubit can be used to change the state of the AuthCubit after a
  // successful login.
  // THe initial state is emitted with empty email and password objects.
  LoginCubit({this.userRepository, this.authCubit}) : super(LoginInitial(email: Email(), password: Password()));

  // Gets the email and the password from the current state.
  // Emits the LoadingState.
  // Calls the login method from the authCubit trying to log in.
  // If successful, the AuthState is changed via the authCubit (the login_screen
  // has a listener and pushes the HomeViewRoute)
  // If unsuccessful, the error is stored in the password or email object, and
  // a failure state is emitted.
  Future<void> login() async {
    print("try login");
    String emailText = state.email.text;
    String passwordText = state.password.text;
    emit(LoadingLoginState());

    List error = await authCubit.loginWithEmail(emailText, passwordText);
    if(error != null) {
      ErrorType errorType = error[0];
      String errorText = error[1];
      if(errorType == ErrorType.EmailError)  {
        emit(LoginFailure(
          email: Email(error: errorText, text: emailText),
          password: Password(error: null, text: passwordText),
        ));
      } else {
        emit(LoginFailure(
          email: Email(error: null, text: emailText),
          password: Password(error: errorText, text: passwordText),
        ));
      }

    }
  }

  //Is called when the email is changed.
  // Password and email are cloned from the current state.
  // The text of the email object is updated with the parameter and the email
  // object is validated (sets the error in the object).
  // Then a new LoginInitial state is emitted.
  void changedEmail(String emailText) {
    Password password = Password.clone(state.password);
    Email email = Email.clone(state.email);
    email.text = emailText;
    email.validate();
    emit(LoginInitial(
        email: email,
        password: password));
  }

  //Is called when the email is changed.
  // Password and email are cloned from the current state.
  // The text of the password object is updated with the parameter and the
  // password object is validated (sets the error in the object).
  // Then a new LoginInitial state is emitted.
  void changedPassword(String passwordText) {
    Password password = Password.clone(state.password);
    Email email = Email.clone(state.email);
    password.text = passwordText;
    password.validate();
    emit(LoginInitial(
        email: email,
        password: password));
  }

  // Is called, if the email or password objects have an error or are not filled.
  // If the text is empty, the error is set accordingly (otherwise, the error
  // remains the same)
  // A LoginFailure State is emitted with the new email and password.
  void invalidInput() {
    print("invalid input");
    Email email = Email.clone(state.email);
    if(email.text == null) {
      email.error = "Bitte gib deine Email Adresse an";
    }
    Password password = Password.clone(state.password);
    if(password.text == null) {
      password.error = "Bitte Passwort eingeben";
    }
    emit(LoginFailure(
      email: email,
      password: password,
    ));
  }
}