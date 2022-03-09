

import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sportsmate/sqfLite.dart';
import 'ItemCollection.dart';
import 'NewItemForm.dart';
import 'authentication.dart';
import 'main.dart';

class NewItemPage extends StatefulWidget{

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
  // static const routeName = '/newItem';

  NewItemPage({Key key,this.auth, this.userId, this.logoutCallback}):super(key: key);

  final String title="New Sport Page";

  @override
  NewItemPageState createState()=>NewItemPageState();


}

class NewItemPageState extends State<NewItemPage>{


  List<Events> _todoList;

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final _textEditingController = TextEditingController();
  StreamSubscription<Event> _onTodoAddedSubscription;
  StreamSubscription<Event> _onTodoChangedSubscription;

  Query _todoQuery;

  //bool _isEmailVerified = false;

  @override
  void initState() {
    super.initState();

    //_checkEmailVerification();

    _todoList = new List();
    _todoQuery = _database
        .reference()
        .child("event")
        .orderByChild("id")
        .equalTo(widget.userId);
    _onTodoAddedSubscription = _todoQuery.onChildAdded.listen(onEntryAdded);
    _onTodoChangedSubscription =
        _todoQuery.onChildChanged.listen(onEntryChanged);


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

  @override
  Widget build(BuildContext context) {

    // final NewItemPage args = ModalRoute.of(context).settings.arguments;
    return
      Scaffold(
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
                  onTap: () => {{Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>NewItemPage(
                        userId: widget.userId,
                        auth: widget.auth,
                        logoutCallback: widget.logoutCallback
                        )),
                  )}},
                ),
                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('My Post History'),
                  onTap: () => {Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>ItemCollection(
                        userId: widget.userId,
                        auth: widget.auth,
                        logoutCallback: widget.logoutCallback)),
                  )},
                ),
              ],
            ),
          ),
          appBar: AppBar(
            title: Text("Sportsman"),
            // actions: <Widget>[
            //   new FlatButton(
            //       child: new Text('Logout',
            //           style: new TextStyle(fontSize: 17.0, color: Colors.white)),
            //       onPressed: signOut)
            // ],
          ),
          body:NewItemForm(
              userId: widget.userId,
              auth: widget.auth,
              logoutCallback: widget.logoutCallback
              ));

  }

}