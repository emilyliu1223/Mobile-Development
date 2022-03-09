import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert' show json;
import "package:http/http.dart" as http;
import 'HomePage.dart';
import 'LoginSignupPage.dart';
import 'authentication.dart';
import 'main.dart';


enum AuthStatus {
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN,
  LOGGED_IN_GOOGLE,
}


// GoogleSignIn _googleSignIn = GoogleSignIn(
//   // Optional clientId
//   // clientId: '479882132969-9i9aqik3jfjd7qhci1nqf0bm2g71rm1u.apps.googleusercontent.com',
//   scopes: <String>[
//     'email',
//     'https://www.googleapis.com/auth/contacts.readonly',
//   ],
// );
class RootPage extends StatefulWidget {
  RootPage({this.auth});

  final BaseAuth auth;


  @override
  State<StatefulWidget> createState() => new _RootPageState();
}

class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  String _userId="";
  GoogleSignInAccount _currentUser;
  String _contactText = '';

  @override
  void initState() {
    super.initState();
    print(authStatus);
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        if (user != null) {
          _userId = user?.uid;
        }
      });

    });



    if(_userId==""){
      authStatus=AuthStatus.NOT_LOGGED_IN;
    }
    else if(_userId!=""){
      authStatus=AuthStatus.LOGGED_IN;
      print("We are in log_in");
    }
  }

  // Future<void> _handleGetContact(GoogleSignInAccount user) async {
  //   setState(() {
  //     _contactText = "Loading contact info...";
  //   });
  //   final http.Response response = await http.get(
  //     Uri.parse('https://people.googleapis.com/v1/people/me/connections'
  //         '?requestMask.includeField=person.names'),
  //     headers: await user.authHeaders,
  //   );
  //   if (response.statusCode != 200) {
  //     setState(() {
  //       _contactText = "People API gave a ${response.statusCode} "
  //           "response. Check logs for details.";
  //     });
  //     print('People API ${response.statusCode} response: ${response.body}');
  //     return;
  //   }
  //   final Map<String, dynamic> data = json.decode(response.body);
  //   final String namedContact = _pickFirstNamedContact(data);
  //   setState(() {
  //     if (namedContact != null) {
  //       _contactText = "I see you know $namedContact!";
  //     } else {
  //       _contactText = "No contacts to display.";
  //     }
  //   });
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

  // Future<GoogleSignInAccount> _handleSignIn() async {
  //   try {
  //  return await _googleSignIn.signIn();
  //
  //   } catch (error) {
  //     print(error);
  //   }
  // return null;
  // }
  //
  // Future<void> _handleSignOut() => _googleSignIn.disconnect();



  void loginCallback() {

     widget.auth.getCurrentUser().then((user) {
      setState(() {
        _userId = user.uid.toString();
        print(_userId+"in RootPage");
      });
    });
    setState(() {
      authStatus = AuthStatus.LOGGED_IN;
    });
  }

  // }


  void logoutCallback() async {
    setState(() {
      authStatus = AuthStatus.NOT_LOGGED_IN;
      _userId = "";
       // _currentUser=null;
    });
  }

  Widget buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.NOT_DETERMINED:
        return buildWaitingScreen();
        break;
      case AuthStatus.NOT_LOGGED_IN:
        print("IN logged out AuthStatus");
        print(_currentUser);
        return LoginSignupPage(
          auth: widget.auth,
          loginCallback: loginCallback,
        );
        break;
      case AuthStatus.LOGGED_IN:
        if (_userId.length > 0 && _userId != null) {
          return new MyHomePage(
            userId: _userId,
            auth: widget.auth,
            logoutCallback: logoutCallback,
            loginCallback: loginCallback
          );
        } else
          return buildWaitingScreen();
        break;
      default:
        return buildWaitingScreen();
    }
  }
}