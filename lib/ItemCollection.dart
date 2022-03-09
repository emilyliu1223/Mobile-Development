
import 'dart:async';
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sportsmate/ItemDetail.dart';
import 'package:sportsmate/main.dart';
import 'package:sportsmate/sqfLite.dart';
import 'AllCollection.dart';
import 'FavoriteItems.dart';
import 'NewItemPage.dart';
import 'authentication.dart';


class ItemCollection extends StatefulWidget{
 // static const routeName = '/mypostPage';
  // List<Event> event;
  // List<String> sports;
  // final Future signout;
  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
 // final GoogleSignInAccount googleaccount;
  // static const routeName = '/mypostPage';
 ItemCollection({Key key,this.auth, this.userId, this.logoutCallback}) : super(key:key);


  @override
 _ItemCollectionState createState()=>_ItemCollectionState();

}

class _ItemCollectionState  extends State<ItemCollection> {

  List<Events> _todoList;
  List<Favorite> _favList;

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();


  StreamSubscription<Event> _onTodoAddedSubscription;
  StreamSubscription<Event> _onTodoChangedSubscription;

  StreamSubscription<Event> _onFavAddedSubscription;
  StreamSubscription<Event> _onFavChangedSubscription;

  Query _todoQuery;
  Query _favQuery;
  String UUID;
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

    _onFavAddedSubscription.cancel();
    _onFavChangedSubscription.cancel();
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

  onFavEntryAdded(Event event) {
    setState(() {
      _favList.add(Favorite.fromSnapshot(event.snapshot));
    });
  }
  onFavEntryChanged(Event event) {
    var oldEntry = _favList.singleWhere((entry) {
      return entry.id == event.snapshot.key;
    });

    setState(() {
      _favList[_favList.indexOf(oldEntry)] =
          Favorite.fromSnapshot(event.snapshot);
    });
  }
  getUUID(String uuid){
    _favList = new List();
    _favQuery = _database
        .reference()
        .child("fav")
        .orderByChild("uuid")
        .equalTo(uuid);
    _onFavAddedSubscription = _favQuery.onChildAdded.listen(onFavEntryAdded);
    _onFavChangedSubscription =
        _favQuery.onChildChanged.listen(onFavEntryChanged) ;
     print(_favList.where((element) => element.uuid==UUID).length);
    _favList.where((element) => element.uuid==UUID).map((e) => _database.reference().child('fav').child(e.id).remove().then((_){
    }));
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
      String img,String address,String uuid) {
    if (name.length > 0) {
      Events todo = new Events(
          widget.userId.toString(),widget.userId.toString(), name, phone, postcode, detail, sports, day, time, img,address,uuid);
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
                  'Sportsmate',
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
                onTap: () => {Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>MyHomePage(
                    userId: widget.userId,
                    auth: widget.auth,
                    logoutCallback: widget.logoutCallback,
                    // googleaccount: widget.googleaccount,
                      // signout:widget.signout
                  )),
                ),print("User id in collection on call of home page:"+widget.userId)},
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
                    // googleaccount: widget.googleaccount,
                    //   signout:widget.signout

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
                    // googleaccount: widget.googleaccount,
                    // signout:widget.signout
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
                    // googleaccount: widget.googleaccount,
                    // signout:signOut()
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
          // actions: <Widget>[
          //   new FlatButton(
          //       child: new Text('Logout',
          //           style: new TextStyle(fontSize: 17.0, color: Colors.white)),
          //       onPressed: signOut)
          // ],
        ),
        body:
        _todoList.length > 0 ? (
            ListView.builder(
            shrinkWrap: true,
            itemCount: _todoList.length,
            itemBuilder: (BuildContext context, int index) {
              String Id = _todoList[index].id;
              String user=_todoList[index].user;
              String detail = _todoList[index].detail;
              String sports = _todoList[index].sports;
              String name = _todoList[index].name;
              String postcode = _todoList[index].postcode;
              String phone = _todoList[index].phone;
              String date=_todoList[index].day;
              String time=_todoList[index].time;
              String img=_todoList[index].img;
              String uuid=_todoList[index].uuid;
              bool favored=false;
              bool ismypost=true;
              var imglist=img.split(",");
              img=imglist[0];
              String address=_todoList[index].address;
              // String img1=_todoList[index].img1;
              // String img2=_todoList[index].img2;
              // String img3=_todoList[index].img3;

              return Dismissible(
                   key: Key(Id),
                  background: Container(color: Colors.lime),
                  onDismissed: (direction) async {
                    deleteTodo(Id, index);
                    UUID=uuid;
                    getUUID(UUID);
                  },
                child:Card(
                elevation: 8.0,
                  margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                  // child:
                  //   Container(
                      // height:200,
                      child: ListTile(
                           contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                          // leading: Container(
                          //    padding: EdgeInsets.only(right: 12.0),
                          //   decoration: new BoxDecoration(
                          //       border: new Border(
                          //           right: new BorderSide(width: 1.0, color: Colors.lime))),
                          //   child: FittedBox(
                          //     fit: BoxFit.fitHeight,
                          //       child: Text(date),
                          //   ),
                          // ),
                          // leading: new Image.network(
                          //  img,
                          //   fit: BoxFit.cover,
                          //   height: 200.0,
                          //
                          // ),
                          title: Text(
                            name,
                            style: TextStyle(fontSize: 18.0),
                          ),
                          subtitle: Row(
                            children: <Widget>[
                              Icon(Icons.search, color: Colors.black26),
                              Text(sports, style: TextStyle(color: Colors.black26))
                            ],
                          ),
                          trailing:
                          IconButton(icon:Icon(Icons.keyboard_arrow_right), color: Colors.black26,  onPressed: ()  {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) =>
                                    ItemDetail(
                                      id: Id,
                                      user:user,
                                      name: name,
                                      phone: phone,
                                      postcode: postcode,
                                      detail: detail,
                                      sports: sports,
                                      date: date,
                                      time: time,
                                      address:address,
                                      uuid:uuid,
                                      img: _todoList[index].img,
                                      userId: widget.userId,
                                      auth: widget.auth,
                                      favored: favored,
                                      ismypost:true,
                                      logoutCallback: widget.logoutCallback,
                                      // signout:widget.signout

                                    ))
                            );
                          },)),
                    ),

                // Container(
                //   decoration: BoxDecoration(color: Colors.white),
                //   child: ListTile(
                //     contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                //     leading: Container(
                //        padding: EdgeInsets.only(right: 12.0),
                //       decoration: new BoxDecoration(
                //           border: new Border(
                //               right: new BorderSide(width: 1.0, color: Colors.lime))),
                //       child: Image.network(img),
                //     ),
                //     title: Text(
                //       name,
                //       style: TextStyle(fontSize: 20.0),
                //     ),
                //       subtitle: Row(
                //         children: <Widget>[
                //           Icon(Icons.search, color: Colors.black26),
                //           Text(sports, style: TextStyle(color: Colors.black26))
                //         ],
                //       ),
                //       trailing:
                //       IconButton(icon:Icon(Icons.keyboard_arrow_right), color: Colors.black26,  onPressed: ()  {
                //         Navigator.push(context,
                //             MaterialPageRoute(builder: (context) =>
                //                 ItemDetail(
                //                   id: Id,
                //                   name: name,
                //                   phone: phone,
                //                   postcode: postcode,
                //                   detail: detail,
                //                   sports: sports,
                //                   date: date,
                //                   time: time,
                //                   img: _todoList[index].img,
                //                   userId: widget.userId,
                //                   auth: widget.auth,
                //                   logoutCallback: widget.logoutCallback,
                //                   // signout:widget.signout
                //
                //                 ))
                //         );
                //       },)),
                //
                //
                //
                //   ),




                  );



            }
            )
        ) : (Center(
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





