enum ErrorType{PasswordError, EmailError, UsernameError}

//Email FormData class
//Stores the email text and the error.
//Has a function for validation which sets the error, when its called
class Email {
  String text;
  String error;

  Email({this.text, this.error});

  Email.clone(Email email): this(text: email.text, error: email.error);

  void validate() {
      bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(text);
      if(!emailValid) {
        error = "Gültiges Emailformat eingeben";
      } else {
        error = null;
      }
  }
}

//Password FormData class
//Stores the password text and the error.
//Has a function for validation which sets the error, when its called
class Password {
  String text;
  String error;

  Password({this.text, this.error});

  Password.clone(Password password): this(text: password.text, error: password.error);

  void validate() {
    if(text.length <= 6) {
      error = "Passwort muss mindestens 6 Zeichen lang sein";
    } else {
      error = null;
    }
  }
}

//Username FormData class
//Stores the username text and the error.
//Has a function for validation which sets the error, when its called
class Username {
  String text;
  String error;

  Username({this.text, this.error});

  Username.clone(Username username): this(text: username.text, error: username.error);

  void validate() {
    if(text.length <= 3) {
      error = "Benutzername muss länger als 3 Zeichen sein";
    } else {
      error = null;
    }
  }
}

class Telephone {
  String number;
  String error;

  Telephone({this.number, this.error});

  Telephone.clone(Telephone telephone): this(number: telephone.number, error: telephone.error);

  void validate() {
    if(number.length <= 6) {
      error = "Telefonnummer muss mindestens 7 Zeichen lang sein";
    } else {
      error = null;
    }
  }
}