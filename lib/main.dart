

import 'dart:async';
import 'dart:io';
import 'dart:convert' show json;
import "package:http/http.dart" as http;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sportsmate/ItemCollection.dart';
import 'package:sportsmate/sqfLite.dart';
import 'package:sqflite/sqflite.dart';
import 'NewItemPage.dart';
import 'RootPage.dart';
import 'authentication.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(
  // Optional clientId
  // clientId: '479882132969-9i9aqik3jfjd7qhci1nqf0bm2g71rm1u.apps.googleusercontent.com',
  scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
  // runApp(SignInDemo());
}


class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sports Partner Search',
      theme: ThemeData(
        primarySwatch: Colors.lime,
      ),
      home: FutureBuilder(
        // Initialize FlutterFire:
        future: _initialization,
        builder: (context, snapshot) {
          // Check for errors
          if (snapshot.hasError) {
            return Text("Something Went Wrong");
          }

          // Once complete, show your application
          if (snapshot.connectionState == ConnectionState.done) {
            return RootPage(auth: new Auth(),);
          }

          // Otherwise, show something whilst waiting for initialization to complete
          return Text("Loading");
        },
      ),
      initialRoute: '/',
      routes:{
         '/newItem':(context) => NewItemPage(),
        '/home':(context)=>MyHomePage(),
      },
    );
  }
}


class MyHomePage extends StatefulWidget {

  MyHomePage({Key key, this.title, this.auth, this.userId, this.logoutCallback}) : super(key: key);
  // final CameraDescription camera;
  final String title;
  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  GoogleSignInAccount _currentUser;
  String _contactText = '';


  List<Events> _todoList;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  StreamSubscription<Event> _onTodoAddedSubscription;
  StreamSubscription<Event> _onTodoChangedSubscription;
  Query _todoQuery;


  @override
  void initState() {
    super.initState();

    _todoList = new List();
    _todoQuery = _database
        .reference()
        .child("event")
        .orderByChild("id")
        .equalTo(widget.userId);
    _onTodoAddedSubscription = _todoQuery.onChildAdded.listen(onEntryAdded);
    _onTodoChangedSubscription =
        _todoQuery.onChildChanged.listen(onEntryChanged);

    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      setState(() {
        _currentUser = account;
      });
      if (_currentUser != null) {
        _handleGetContact(_currentUser);
      }
    });
    _googleSignIn.signInSilently();
  }


  Future<void> _handleGetContact(GoogleSignInAccount user) async {
    setState(() {
      _contactText = "Loading contact info...";
    });
    final http.Response response = await http.get(
      Uri.parse('https://people.googleapis.com/v1/people/me/connections'
          '?requestMask.includeField=person.names'),
      headers: await user.authHeaders,
    );
    if (response.statusCode != 200) {
      setState(() {
        _contactText = "People API gave a ${response.statusCode} "
            "response. Check logs for details.";
      });
      print('People API ${response.statusCode} response: ${response.body}');
      return;
    }
    final Map<String, dynamic> data = json.decode(response.body);
    final String namedContact = _pickFirstNamedContact(data);
    setState(() {
      if (namedContact != null) {
        _contactText = "I see you know $namedContact!";
      } else {
        _contactText = "No contacts to display.";
      }
    });
  }

  String _pickFirstNamedContact(Map<String, dynamic> data) {
    final List<dynamic> connections = data['connections'];
    final Map<String, dynamic> contact = connections?.firstWhere(
          (dynamic contact) => contact['names'] != null,
      orElse: () => null,
    );
    if (contact != null) {
      final Map<String, dynamic> name = contact['names'].firstWhere(
            (dynamic name) => name['displayName'] != null,
        orElse: () => null,
      );
      if (name != null) {
        return name['displayName'];
      }
    }
    return null;
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  Future<void> _handleSignOut() => _googleSignIn.disconnect();

  Widget _buildBody() {
    GoogleSignInAccount user = _currentUser;
    if (user != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          ListTile(
            leading: GoogleUserCircleAvatar(
              identity: user,
            ),
            title: Text(user.displayName ?? ''),
            subtitle: Text(user.email),
          ),
          const Text("Signed in successfully."),
          Text(_contactText),
          ElevatedButton(
            child: const Text('SIGN OUT'),
            onPressed: _handleSignOut,
          ),
          ElevatedButton(
            child: const Text('REFRESH'),
            onPressed: () => _handleGetContact(user),
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          const Text("You are not currently signed in."),
          ElevatedButton(
            child: const Text('SIGN IN'),
            onPressed: _handleSignIn,
          ),
        ],
      );
    }
  }
  @override
  void dispose() {
    _onTodoAddedSubscription.cancel();
    _onTodoChangedSubscription.cancel();
    super.dispose();
  }

  onEntryChanged(Event event) {
    var oldEntry = _todoList.singleWhere((entry) {
      return entry.id == event.snapshot.key;
    });

    setState(() {
      _todoList[_todoList.indexOf(oldEntry)] =
          Events.fromSnapshot(event.snapshot);
    });
  }

  onEntryAdded(Event event) {
    setState(() {
      _todoList.add(Events.fromSnapshot(event.snapshot));
    });
  }

  signOut() async {
    try {
      await widget.auth.signOut();
      widget.logoutCallback();
    } catch (e) {
      print(e);
    }
  }

  addNewTodo(String name, String phone, String postcode, String detail, String sports, String day, String time,
  String img) {
    if (name.length > 0) {
      Events todo = new Events(widget.userId.toString(),name,phone,postcode,detail,sports, day, time, img);
      _database.reference().child("event").push().set(todo.toJson());
    }
  }

  updateTodo(Events todo) {
    //Toggle completed

    if (todo != null) {
      _database.reference().child("event").child(todo.id).set(todo.toJson());
    }
  }

  deleteTodo(String todoId, int index) {
    _database.reference().child("event").child(todoId).remove().then((_) {
      print("Delete $todoId successful");
      setState(() {
        _todoList.removeAt(index);
      });
    });
  }

  // void removeAll(){
  //   EventCollection.removeAll();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text(
                'Side menu',
                style: TextStyle(color: Colors.white, fontSize: 25),
              ),
              decoration: BoxDecoration(
                  color: Colors.lime,
                  image: DecorationImage(
                      fit: BoxFit.fill,
                      image: AssetImage('images/lake.jpg'))),
            ),
            ListTile(
              leading: Icon(Icons.input),
              title: Text('Home Page'),
              onTap: () => { Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>MyHomePage(
              userId: widget.userId,
              auth: widget.auth,
              logoutCallback:widget.logoutCallback,
              ))),},
            ),
            ListTile(
              leading: Icon(Icons.verified_user),
              title: Text('Post an invitation'),
              onTap: () => {Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>NewItemPage(
                    userId: widget.userId,
                    auth: widget.auth,
                    logoutCallback: widget.logoutCallback,

                    )),
              )},
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('My Post History'),
              onTap: () => {Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>ItemCollection(
              userId: widget.userId,
              auth: widget.auth,
              logoutCallback: widget.logoutCallback,
            )),
              ),print(widget.userId)},
            ),

          ],
        ),
      ),
      appBar: AppBar(
        title: Text("Sportsman"),
        actions: <Widget>[
          new FlatButton(
              child: new Text('Logout',
                  style: new TextStyle(fontSize: 17.0, color: Colors.white)),
              onPressed: signOut)
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              'Sport Invitation',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: ()=>{Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>NewItemPage(
              userId: widget.userId,
              auth: widget.auth,
              logoutCallback: widget.logoutCallback
             )),
        )},
        tooltip: 'Add New Invitation',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }


}

