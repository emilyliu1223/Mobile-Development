

import 'dart:async';
import 'dart:io';
import 'dart:convert' show json;
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import "package:http/http.dart" as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sportsmate/AllCollection.dart';
import 'package:sportsmate/FavoriteItems.dart';
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:sportsmate/ItemCollection.dart';
import 'package:sportsmate/LoginSignupPage.dart';
import 'package:sportsmate/sqfLite.dart';
import 'package:sqflite/sqflite.dart';
import 'package:video_player/video_player.dart';
import 'NewItemPage.dart';
import 'RootPage.dart';
import 'authentication.dart';

// GoogleSignIn _googleSignIn = GoogleSignIn(
//   // Optional clientId
//   // clientId: '479882132969-9i9aqik3jfjd7qhci1nqf0bm2g71rm1u.apps.googleusercontent.com',
//   scopes: <String>[
//     'email',
//     'https://www.googleapis.com/auth/contacts.readonly',
//   ],
// );
// GoogleSignIn _googleSignIn = GoogleSignIn(
//   // Optional clientId
//   // clientId: '479882132969-9i9aqik3jfjd7qhci1nqf0bm2g71rm1u.apps.googleusercontent.com',
//   scopes: <String>[
//     'email',
//     'https://www.googleapis.com/auth/contacts.readonly',
//   ],
// );
Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
  // runApp(SignInDemo());
}


class MyApp extends StatelessWidget {
   // final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sports Partner Search',
      theme: ThemeData(
        primarySwatch: Colors.lime,
      ),
      home: RootPage(auth:new Auth()),

      initialRoute: '/',
      routes:{
         '/newItem':(context) => NewItemPage(),
        '/home':(context)=>MyHomePage(),
      },
    );
  }
}


class MyHomePage extends StatefulWidget {

  MyHomePage({Key key, this.title, this.auth, this.userId, this.logoutCallback, this.loginCallback}) : super(key: key);
  // final CameraDescription camera;
  final String title;
  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final VoidCallback loginCallback;
  // final Future<void> googleLogout;
  final String userId;
  // final GoogleSignInAccount googleaccount;


  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  // GoogleSignInAccount _currentUser;
  // String _contactText = '';

  int _selectedValue = 0;
  List<Events> _todoList;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  StreamSubscription<Event> _onTodoAddedSubscription;
  StreamSubscription<Event> _onTodoChangedSubscription;
  Query _todoQuery;
  var locationController=new TextEditingController();
  // GoogleSignInAccount _currentUser;
  VideoPlayerController _controller;
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
    //
    // _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
    //   setState(() {
    //
    //     _currentUser = account;
    //     print("Google set state on main page:");
    //     print(_currentUser);
    //   });
    //   if (_currentUser != null) {
    //     // _handleGetContact(_currentUser);
    //   }
    // });
    // _googleSignIn.signInSilently();

    _controller = VideoPlayerController.asset(
        'video/sports.mp4')
      ..initialize().then((_) {
        _controller.play();
        _controller.setLooping(true);
        // Ensure the first frame is shown after the video is initialized
        setState(() {});
      });
  }


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

   // Future<void> _handleSignOut() => _googleSignIn.disconnect();

  @override
  void dispose() {
    _onTodoAddedSubscription.cancel();
    _onTodoChangedSubscription.cancel();
    super.dispose();
    _controller.dispose();
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

  // signOut() async {
  //   try {
  //     await widget.auth.signOut();
  //     widget.logoutCallback();
  //    Navigator.push(
  //   context,
  //   MaterialPageRoute(builder: (context) =>LoginSignupPage(
  //    auth: widget.auth,
  //    loginCallback: widget.loginCallback,
  //   )),);
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  addNewTodo(String name, String phone, String postcode, String detail, String sports, String day, String time,
  String img,String address,String uuid) {
    if (name.length > 0) {
      Events todo = new Events(widget.userId.toString(),widget.userId.toString(),name,phone,postcode,detail,sports, day, time, img,address,uuid);
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
    // print(widget.googleaccount);
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text(
                'Sportmate',
                style: TextStyle(color: Colors.limeAccent, fontSize: 25),
              ),
              decoration: BoxDecoration(
                  color: Colors.lime,
                  image: DecorationImage(
                      fit: BoxFit.fill,
                      image: AssetImage('images/sports.jpg'))),
            ),
            ListTile(
              leading: Icon(Icons.house_outlined),
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
              leading: Icon(Icons.add_circle_outline),
              title: Text('Post an Invitation'),
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
              leading: Icon(Icons.view_list_outlined),
              title: Text('My Post History'),
              onTap: () => {Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>ItemCollection(
              userId: widget.userId,
              auth: widget.auth,
              logoutCallback: widget.logoutCallback,
            )),
              )},
            ),
            ListTile(
              leading: Icon(Icons.saved_search),
              title: Text('Searh for Events'),
              onTap: () => {Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>AllCollection(
                  userId: widget.userId,
                  auth: widget.auth,
                  logoutCallback: widget.logoutCallback,

                )),
              )},
            ),
            ListTile(
              leading: Icon(Icons.favorite),
              title: Text('My Favorite Events'),
              onTap: () => {Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>FavoriteItems(
                  userId: widget.userId,
                  auth: widget.auth,
                  logoutCallback: widget.logoutCallback,

                )),
              )},
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text("Sportsmate",style: TextStyle(
          color: Colors.white,
        ),),
        iconTheme: IconThemeData(color: Colors.white),
        actions: <Widget>[
          IconButton(
              color: Colors.white,
              onPressed:()=>{
            widget.auth.signOut(),
            widget.logoutCallback(),
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>LoginSignupPage(
                auth: widget.auth,
                loginCallback: widget.loginCallback,
              )),)

          }

              , icon: Icon(Icons.logout)),
          // new FlatButton(
          //     child: new Text('Logout',
          //         style: new TextStyle(fontSize: 17.0, color: Colors.white)),
          //     onPressed:()=>{
          //     widget.auth.signOut(),
          //     widget.logoutCallback(),
          //     Navigator.push(
          //     context,
          //     MaterialPageRoute(builder: (context) =>LoginSignupPage(
          //     auth: widget.auth,
          //     loginCallback: widget.loginCallback,
          //     )),)
          //
          //     }

        ],
      ),
      body: Center(
        child:Stack(
          children: <Widget>[
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size?.width ?? 0,
                  height: _controller.value.size?.height ?? 0,
                  child: VideoPlayer(_controller),
                ),
              ),
            ),
            Center(
                child:Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [Text(
              'Find your sports in the area!',
                    textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.lime, fontSize: 16.0),

            ),Text(
              'Sportsmate',
              // style: Theme.of(context).textTheme.headline4
                      style:TextStyle(color: Colors.lime, fontSize: 24.0),
                    textAlign: TextAlign.center,

            ),Container(
                      padding: EdgeInsets.all(12),
                      width: 300,
                      height: 80,
                      child:
                      TextFormField(
                        keyboardType: TextInputType.streetAddress,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.transparent,
                          labelText: "Insert your City",
                          labelStyle: TextStyle(color: Colors.lime),
                          suffixIcon: IconButton(
                              icon: Icon(Icons.search),
                              onPressed:()=>{
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) =>AllCollection(
                                    userId: widget.userId,
                                    auth: widget.auth,
                                    logoutCallback: widget.logoutCallback,
                                    location:locationController.text

                                  )),
                                )
                              }
                          ),
                          border: new OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(25.0),
                            borderSide: new BorderSide(),
                          ),),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.lime, fontSize: 16.0),
                        controller: locationController,
                        validator: (value){
                          if(value.isEmpty){
                            return 'Please enter City';
                          }
                          return null;
                        },
                      ),

                    )
                    ])),


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
   Widget cupertinopicker(){
    return Container(
      width: 300,
      height: 120,
      child: CupertinoPicker(
        // magnification: 1.5,
        itemExtent: 60,
        scrollController: FixedExtentScrollController(initialItem: 1),
        backgroundColor: Colors.transparent,
        children: <Widget>[

          MaterialButton(
            child: Text(
              "My Post History",
              style: TextStyle(color: Colors.white),
            ),
            // color: Colors.transparent,
            // onPressed: () => {Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) =>NewItemPage(
            //     userId: widget.userId,
            //     auth: widget.auth,
            //     logoutCallback: widget.logoutCallback,
            //     googleaccount: widget.googleaccount,
            //   )),
            // )},
          ),

          IconButton(
            icon: Icon(Icons.home),
            color: Colors.white,
            iconSize: 40,
            onPressed: () => {Navigator.push(
         context,
         MaterialPageRoute(builder: (context) =>NewItemPage(
           userId: widget.userId,
           auth: widget.auth,
           logoutCallback: widget.logoutCallback,
           // googleaccount: widget.googleaccount,
         )),
       )},
          ),
          IconButton(
            icon: Icon(Icons.camera),
            color: Colors.white,
            iconSize: 40,
            onPressed: () {},
          ),  IconButton(
            icon: Icon(Icons.map),
            color: Colors.white,
            iconSize: 40,
            onPressed: () {},
          ),  IconButton(
            icon: Icon(Icons.event),
            color: Colors.white,
            iconSize: 40,
            onPressed: () {},
          )
        ],

        looping: true,
        onSelectedItemChanged: (value) {
          _selectedValue = value;
          print(value);

        },
      ),
    );


   }


}

