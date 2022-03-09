// import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:sportsmate/Google.dart';
import 'package:sportsmate/main.dart';
import 'authentication.dart';
import  'dart:async';
import 'dart:io';
import 'dart:convert' show json;
import "package:http/http.dart" as http;




GoogleSignIn _googleSignIn = GoogleSignIn(
  // Optional clientId
  // clientId: '479882132969-9i9aqik3jfjd7qhci1nqf0bm2g71rm1u.apps.googleusercontent.com',
  scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);
class LoginSignupPage extends StatefulWidget {
  LoginSignupPage({this.auth, this.loginCallback, this.googleCallback, this.googleLogout, this.googleSignIn});

  final BaseAuth auth;
  final VoidCallback loginCallback;
  final VoidCallback googleCallback;
  final Future googleLogout;
  final Future<GoogleSignInAccount> googleSignIn;


  @override
  State<StatefulWidget> createState() => new _LoginSignupPageState();
}

class _LoginSignupPageState extends State<LoginSignupPage> {
  final _formKey = new GlobalKey<FormState>();
  String _email;
  String _password;
  String _errorMessage;
  bool _isLoginForm;
  bool _isLoading;
  String type;
  GoogleSignInAccount _currentUser;
  String _contactText = '';

  // Check if form is valid before perform login or signup
  bool validateAndSave() {
    print("Form Validate");
    final form = _formKey.currentState;
    print(form.validate());

    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }



  // Perform login or signup
  void validateAndSubmit(String type) async {
    setState(() {
      _errorMessage = "";
      print(validateAndSave());
      _isLoading = false;
    });

    if (validateAndSave()) {
      try {
        String userId = "";
        if (type == "Normal") {
          if (_isLoginForm) {
            userId = await widget.auth.signIn(_email, _password);
            print('Signed in: $userId');
          } else {
            userId = await widget.auth.signUp(_email, _password);
            //widget.auth.sendEmailVerification();
            //_showVerifyEmailSentDialog();
            print('Signed up user: $userId');
          }
          setState(() {
            print("Spinning is off?");
            _isLoading = false;
            if (userId.length > 0  && _isLoginForm ) {
              print("1");
              widget.loginCallback();
              print("2");
            }
          });

        }
        else if (type == "Google") {
          print("google");
          GoogleSignInAccount account=await widget.googleSignIn;
          print("google");
          userId=account.id;
          print('Signed in: $userId');
          setState(() {
            // print("Spinning is off2?");
            _isLoading = false;
            if (userId.length > 0 && userId != null && _isLoginForm ) {
              widget.googleCallback();
            }
          });
        }


      } catch (e) {
        print('Error: $e');
        setState(() {
          _isLoading = false;
          // _errorMessage = e.message;
          _formKey.currentState.reset();
        });
      }
    }
  }


  @override
  void initState() {
    _errorMessage = "";
    _isLoading = false;
    _isLoginForm = true;
    super.initState();
    // _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
    //   setState(() {
    //     _currentUser = account;
    //   });
    //   if (_currentUser != null) {
    //     _handleGetContact(_currentUser);
    //
    //   }
    //
    // });
    // _googleSignIn.signInSilently();
  }


  // Future<void> _handleGetContact(GoogleSignInAccount user) async {
  //
  //   final http.Response response = await http.get(
  //     Uri.parse('https://people.googleapis.com/v1/people/me/connections'
  //         '?requestMask.includeField=person.names'),
  //     headers: await user.authHeaders,
  //   );
  //   if (response.statusCode != 200) {
  //
  //     print('People API ${response.statusCode} response: ${response.body}');
  //     return;
  //   }
  //   final Map<String, dynamic> data = json.decode(response.body);
  //   final String namedContact = _pickFirstNamedContact(data);
  //
  // }
  //
  // String _pickFirstNamedContact(Map<String, dynamic> data) {
  //   final List<dynamic> connections = data['connections'];
  //   final Map<String, dynamic> contact = connections?.firstWhere(
  //         (dynamic contact) => contact['names'] != null,
  //     orElse: () => null,
  //   );
  //   if (contact != null) {
  //     final Map<String, dynamic> name = contact['names'].firstWhere(
  //           (dynamic name) => name['displayName'] != null,
  //       orElse: () => null,
  //     );
  //     if (name != null) {
  //       return name['displayName'];
  //     }
  //   }
  //   return null;
  // }
  //
  // Future<GoogleSignInAccount> _handleSignIn() async {
  //   try {
  //     print("run to Signin handler");
  //     return await _googleSignIn.signIn();
  //     print("run to Signin handler");
  //   } catch (error) {
  //     print(error);
  //   }
  //   return null;
  // }
  //  // Future<void> _handleSignOut() => _googleSignIn.disconnect();





  void resetForm() {
    _formKey.currentState.reset();
    _errorMessage = "";
  }

  void toggleFormMode() {
    resetForm();
    setState(() {
      _isLoginForm = !_isLoginForm;
    });
  }



  @override
  Widget build(BuildContext context) {

    return new Scaffold(
        // appBar: new AppBar(
        //   title: new Text('Flutter login demo'),
        // ),
        body:
        Container(
        constraints: BoxConstraints.expand(),
    decoration: BoxDecoration(
    image: DecorationImage(
    image: AssetImage("images/sports.jpg"),
    fit: BoxFit.cover,
    ),
    ),
          child :
            _showForm(),
            // _showCircularProgress(),

        ));
  }



  Widget _showCircularProgress() {
    if (_isLoading) {
      print('spinning');
      return Center(child: CircularProgressIndicator());
    }
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }

//  void _showVerifyEmailSentDialog() {
//    showDialog(
//      context: context,
//      builder: (BuildContext context) {
//        // return object of type Dialog
//        return AlertDialog(
//          title: new Text("Verify your account"),
//          content:
//              new Text("Link to verify account has been sent to your email"),
//          actions: <Widget>[
//            new FlatButton(
//              child: new Text("Dismiss"),
//              onPressed: () {
//                toggleFormMode();
//                Navigator.of(context).pop();
//              },
//            ),
//          ],
//        );
//      },
//    );
//  }

  Widget _showForm() {
    return new Container(
        padding: EdgeInsets.all(16.0),
        child: new Form(
          key: _formKey,
          child: new ListView(
            shrinkWrap: true,
            children: <Widget>[
              showLogo(),
              showEmailInput(),
              showPasswordInput(),
              showPrimaryButton(),
              showSecondaryButton(),
              // showGoogleButton(),
              showErrorMessage(),
            ],
          ),
        ));
  }

  Widget showErrorMessage() {
    if (_errorMessage.length > 0 && _errorMessage != null) {
      return new Text(
        _errorMessage,
        style: TextStyle(
            fontSize: 13.0,
            color: Colors.red,
            height: 1.0,
            fontWeight: FontWeight.w300),
      );
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }

  Widget showLogo() {
    return new Hero(
      tag: 'hero',
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 70.0, 0.0, 0.0),
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 48.0,
          child: Image.asset("images/logo.png")
        ),
      ),
    );
  }

  Widget showEmailInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 100.0, 0.0, 0.0),
      child: new TextFormField(
        style: TextStyle(color: Colors.lime),
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: new InputDecoration(
            fillColor: Colors.lime,
            hintText: 'Email',
            icon: new Icon(
              Icons.mail,
              color: Colors.lime,
            )),
        validator: (value) => value.isEmpty && type=="Normal" ? 'Email can\'t be empty' : null,
        onSaved: (value) => _email = value.trim(),
      ),
    );
  }

  Widget showPasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        style: TextStyle(color: Colors.lime),
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Password',
            icon: new Icon(
              Icons.lock,
              color: Colors.lime,
            )),
        validator: (value) => value.isEmpty && type=="Normal" ? 'Password can\'t be empty' : null,
        onSaved: (value) => _password = value.trim(),
      ),
    );
  }

  Widget showSecondaryButton() {
    return new FlatButton(
        child: new Text(
            _isLoginForm ? 'Create an account' : 'Have an account? Sign in',
            style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300,color: Colors.lime)),
        onPressed: toggleFormMode);
  }


  Widget showPrimaryButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.lime,
            child: new Text(_isLoginForm ? 'Login' : 'Create account',
                style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed:()=> {validateAndSubmit("Normal"),type="Normal"},
          ),
        ));
  }


  //
  Widget showGoogleButton() {
    return OutlineButton(
      splashColor: Colors.grey,
      onPressed: ()=>{
        type="Google",
        validateAndSubmit("Google")
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      highlightElevation: 0,
      borderSide: BorderSide(color: Colors.grey),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset("images/google_logo.png", height: 35.0),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'Sign in with Google',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.lime,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}