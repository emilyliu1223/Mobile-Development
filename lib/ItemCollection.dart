
import 'dart:async';
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sportsmate/ItemDetail.dart';
import 'package:sportsmate/main.dart';
import 'package:sportsmate/sqfLite.dart';
import 'NewItemPage.dart';
import 'authentication.dart';


class ItemCollection extends StatefulWidget{
 // static const routeName = '/mypostPage';
  // List<Event> event;
  // List<String> sports;
  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;

  // static const routeName = '/mypostPage';
 ItemCollection({Key key,this.auth, this.userId, this.logoutCallback}) : super(key:key);


  @override
 _ItemCollectionState createState()=>_ItemCollectionState();

}

class _ItemCollectionState  extends State<ItemCollection> {

  List<Events> _todoList;

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();


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

  addNewTodo(String name, String phone, String postcode, String detail,
      String sports, String day, String time,
      String img) {
    if (name.length > 0) {
      Events todo = new Events(
          widget.userId.toString(), name, phone, postcode, detail, sports, day, time, img);
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

  Widget myfuturewidget;

  @override
  Widget build(BuildContext context) {
    print(widget.userId.toString()+"userid of collection from homepage");
    // final ItemCollection args = ModalRoute.of(context).settings.arguments;
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
                onTap: () => {Navigator.pushNamed(context, '/home')},
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
        body:
        _todoList.length > 0 ? (ListView.builder(
            shrinkWrap: true,
            itemCount: _todoList.length,
            itemBuilder: (BuildContext context, int index) {
              String Id = _todoList[index].id;
              String detail = _todoList[index].detail;
              String sports = _todoList[index].sports;
              String name = _todoList[index].name;
              String postcode = _todoList[index].postcode;
              String phone = _todoList[index].phone;
              String date=_todoList[index].day;
              String time=_todoList[index].time;
              // String img=_todoList[index].img;
              // String img1=_todoList[index].img1;
              // String img2=_todoList[index].img2;
              // String img3=_todoList[index].img3;

              return Dismissible(

                  key: Key(Id),
                  background: Container(color: Colors.lime),
                  onDismissed: (direction) async {
                    deleteTodo(Id, index);
                  },
                  child: ListTile(
                    title: Text(
                      name,
                      style: TextStyle(fontSize: 20.0),
                    ),
                    trailing: RaisedButton(
                      // icon: (completed)
                      //     ? Icon(
                      //   Icons.done_outline,
                      //   color: Colors.green,
                      //   size: 20.0,
                      // )
                      //     : Icon(Icons.done, color: Colors.grey, size: 20.0),
                        onPressed: () {
                          updateTodo(_todoList[index]);
                        }),
                    onTap: () =>
                    {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) =>
                              ItemDetail(
                                  id: Id,
                                  name: name,
                                  phone: phone,
                                  postcode: postcode,
                                  detail: detail,
                                  sports: sports,
                                  date: date,
                                  time: time,
                                  img: _todoList[index].img,
                                  userId: widget.userId,
                                  auth: widget.auth,
                                  logoutCallback: widget.logoutCallback,

                              )))
                    },
                  )

              );
            })) : (Center(
            child: Text(
              "Welcome. Your list is empty",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 30.0),
            )
        )
        )
    );
  }
}





