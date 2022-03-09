

import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sportsmate/sqfLite.dart';
import 'ItemCollection.dart';
import 'NewItemPage.dart';
import 'authentication.dart';
import 'main.dart';

class ItemDetail extends StatefulWidget{
  String name;
  String phone;
  String postcode;
  // List<String> sports=[];
   String detail;
   String id;
   String sports;
   BaseAuth auth;
   VoidCallback logoutCallback;
  String userId;
  String date;
  String time;
  String img;




  ItemDetail({Key key,this.id,this.name,this.phone,this.postcode,
    this.sports,this.detail,this.auth, this.userId, this.logoutCallback,
    this.date,this.time,this.img
  }):super(key:key);
 // static const routeName = '/detailPage';
  @override
  _ItemDetailState createState()=>_ItemDetailState();

}
class _ItemDetailState extends State<ItemDetail>{
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

  @override

  Widget build(BuildContext context) {

    List<String>sportlist=widget.sports.split(',');
    widget.img.replaceAll("[[", "");
    widget.img.replaceAll("]]", "");
    widget.img.trimLeft();
    widget.img.trimRight();
    List<String> imagelist= widget.img.split(',');

    Widget titleSection = Container(
      padding: const EdgeInsets.all(32),
      child: Row(
        children: [
          Expanded(
            /*1*/
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /*2*/
                Container(
                    padding: const EdgeInsets.only(bottom: 8),
                    //
                    child:
                    Wrap(
                      direction: Axis.horizontal,
                      alignment: WrapAlignment.center,
                      spacing: 5.0,
                      runSpacing: 6.0,

                      children:sportlist.map((s)=>Chip(
                        // avatar: CircleAvatar(
                        //   backgroundColor: Colors.grey.shade800,
                        //   child: Text('AB'),
                        // ),
                        backgroundColor: Colors.lightGreen,
                        shadowColor: Colors.black26,

                        label: Text(s),
                        labelStyle: TextStyle(color: Colors.white),
                      )).toList().cast<Widget>(),
                    )

                ),
                Text(
                  "Phone Number:  " +widget.phone,
                  style: TextStyle(
                    color: Colors.grey[500],
                  ),
                ),
                Text(
                  "Availability:  "+widget.date+"  "+widget.time
                )
              ],
            ),
          ),
          /*3*/
          // Icon(
          //   Icons.star,
          //   color: Colors.red[500],
          // ),
          // Text('41'),
        ],
      ),
    );

    Color color = Theme.of(context).primaryColor;

    Widget buttonSection = Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildButtonColumn(color, Icons.call, 'CALL'),
          _buildButtonColumn(color, Icons.near_me, 'ROUTE'),
          _buildButtonColumn(color, Icons.share, 'SHARE'),
        ],
      ),
    );
    Widget pictureSection=new Container(
        height: 200.0,
        child: new ListView(
          scrollDirection: Axis.horizontal,
          children: new List.generate(imagelist.length, (int index) {
            return new Card(
              // color: Colors.blue[index * 100],
              child: new Container(
                width: 150.0,
                height: 200.0,
                child: new Image.network(imagelist[index]),
              ),
            );
          }),
        ),
      );


    Widget textSection = Container(
        padding: const EdgeInsets.all(32),
        child: Text(
          widget.detail,
          softWrap: true,

        ));

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
                )))}
              ),
              ListTile(
                leading: Icon(Icons.verified_user),
                title: Text('Post an invitation'),
                onTap: () => {
                  print("Post from ItemDetail:"+widget.userId),
                  Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>NewItemPage(
                      userId: widget.userId,
                      auth: widget.auth,
                      logoutCallback:widget.logoutCallback,
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
                      logoutCallback:widget.logoutCallback)),
                )},
              ),

            ],
          ),
        ),
        appBar: AppBar(
          backgroundColor: Colors.lime,
          title: Text('Post Detail'),
        ),
        body:
        Container(
            child:
            new ListView(
                shrinkWrap: true,
            children:[
              Column(
              mainAxisSize: MainAxisSize.min,
              children:<Widget> [

                imagelist.length>0?
                Container(child:Image.network(
                  imagelist[0].toString().replaceAll('[', '').replaceAll(']', '').trimLeft().trimRight(),
                  width: 600,
                  height: 240,
                  fit: BoxFit.cover,
                ))
                    : Container(
                  child: Image.asset("images/default.png",
                      width: 600,
                      height: 240,
                      fit: BoxFit.cover),
                ),
                titleSection,
                buttonSection,

                textSection,
                pictureSection,


              ]

      )
          ]
      )
    )
);
  }
  Column _buildButtonColumn(Color color, IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color),
        Container(
          margin: const EdgeInsets.only(top: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: color,
            ),
          ),

    )
    ]
    );

}
}

