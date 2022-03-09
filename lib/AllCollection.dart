
import 'dart:async';
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sportsmate/ItemDetail.dart';
import 'package:sportsmate/main.dart';
import 'package:sportsmate/sqfLite.dart';
import 'FavoriteItems.dart';
import 'ItemCollection.dart';
import 'NewItemPage.dart';
import 'authentication.dart';
import 'package:location/location.dart' as LocationManager;



class AllCollection extends StatefulWidget{
  // static const routeName = '/mypostPage';
  // List<Event> event;
  // List<String> sports;
  // final Future signout;
  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
  final String location;
  // final GoogleSignInAccount googleaccount;
  // static const routeName = '/mypostPage';
  AllCollection({Key key,this.auth, this.userId, this.logoutCallback, this.location}) : super(key:key);


  @override
  _AllCollectionState createState()=>_AllCollectionState();

}

class _AllCollectionState  extends State<AllCollection> {

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

  final locationController=TextEditingController();
  //bool _isEmailVerified = false;

  @override
  void initState() {
    super.initState();

    //_checkEmailVerification();
    _todoList = new List();
    _todoQuery = _database
        .reference()
        .child("event")
        .orderByChild("postcode")
        .equalTo(widget.location!=null?widget.location:locationController.text);
    _onTodoAddedSubscription = _todoQuery.onChildAdded.listen(onEntryAdded);
    _onTodoChangedSubscription =
        _todoQuery.onChildChanged.listen(onEntryChanged);


    _favList = new List();
    _favQuery = _database
        .reference()
        .child("fav")
        .orderByChild("favby")
        .equalTo(widget.userId);
    _onFavAddedSubscription = _favQuery.onChildAdded.listen(onFavEntryAdded);
    _onFavChangedSubscription =
    _favQuery.onChildChanged.listen(onFavEntryChanged) ;

    print(locationController.text);
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
      return entry.postcode == event.snapshot.key  ;
    });

    setState(() {
      _todoList[_todoList.indexOf(oldEntry)] =
          Events.fromSnapshot(event.snapshot);
    });
  }

  onEntryAdded(Event event) {
    final datetime=Events.fromSnapshot(event.snapshot).day.split("-")[1].trim();
    final date = DateTime(int.parse(datetime.split("/")[0].trim()), int.parse(datetime.split("/")[1].trim()), int.parse(datetime.split("/")[2].trim()));
    setState(() {
       if(date.isAfter(DateTime.now())){
        _todoList.add(Events.fromSnapshot(event.snapshot));}
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

  onFavEntryAdded(Event event) {
    setState(() {
        _favList.add(Favorite.fromSnapshot(event.snapshot));
    });
  }
  // signOut() async {
  //   try {
  //     await widget.auth.signOut();
  //     widget.logoutCallback();
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  bool badminton=false;
  bool basketball=false;
  bool baseball=false;
  bool table_tennis=false;
  bool tennis=false;

  addNewTodo(String name, String phone, String postcode, String detail,
      String sports, String day, String time,
      String img,String address,String uuid) {
    if (name.length > 0) {
      Events todo = new Events(
          widget.userId.toString(),widget.userId.toString(), name, phone, postcode, detail, sports, day, time, img, address,uuid);
      _database.reference().child("event").push().set(todo.toJson());
    }
  }

  // updateTodo(Events todo) {
  //   //Toggle completed
  //
  //   if (todo != null) {
  //     _database.reference().child("event").child(todo.id).set(todo.toJson());
  //   }
  // }
  getList(String city){
    // _todoList = new List();
    setState(() {
      _todoList = new List();
      _todoQuery = _database
          .reference()
          .child("event")
          .orderByChild("postcode")
          .equalTo(city);
      _onTodoAddedSubscription = _todoQuery.onChildAdded.listen(onEntryAdded);
      _onTodoChangedSubscription = _todoQuery.onChildChanged.listen(onEntryChanged);
    });

  }



  // deleteTodo(String todoId, int index) {
  //   _database.reference().child("event").child(todoId).equalTo("value").remove().then((_) {
  //     print("Delete $todoId successful");
  //     setState(() {
  //       _todoList.removeAt(index);
  //     });
  //   });
  // }



  Widget myfuturewidget;

  // showAlertDialog(BuildContext context) {
  //
  //   // set up the button
  //   Widget okButton = FlatButton(
  //     child: Text("OK"),
  //     onPressed: () { },
  //   );
  //
  //   // set up the AlertDialog
  //   AlertDialog alert = AlertDialog(
  //     title: Text("mm"),
  //     content: Text("This is my message."),
  //     actions: [
  //       okButton,
  //     ],
  //   );
  //
  //
  //   // show the dialog
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return alert;
  //     },
  //   );
  // }


  @override
  Widget build(BuildContext context) {
    // print(widget.userId.toString()+"userid of collection from homepage");
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
                leading: Icon(Icons.add_circle_outline),
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
            Column(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  width: 300,
                  height: 80,
                  child:
                    TextFormField(
                      keyboardType: TextInputType.streetAddress,
                      decoration: InputDecoration(
                        labelText: "Insert your City",
                        labelStyle: TextStyle(color: Colors.lime),
                        suffixIcon: IconButton(
                            icon: Icon(Icons.search),
                            onPressed:()=>{
                              getList(locationController.text),
                              print(_todoList.length)
                            }
                        ),
                        border: new OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(25.0),
                          borderSide: new BorderSide(),
                        ),),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black26, fontSize: 16.0),
                      controller: locationController,
                      validator: (value){
                        if(value.isEmpty){
                          return 'Please enter City';
                        }
                        return null;
                      },
                    ),
                    // IconButton(onPressed:()=>{
                    //   showAlertDialog
                    // }
                    //
                    // , icon:Icon(Icons.settings))

                ),
                _todoList.length > 0 ? (
                Flexible(
                  child:
                    ListView.builder(
                        shrinkWrap: true,
                        itemCount: _todoList.length,
                        itemBuilder: (BuildContext context, int index) {
                          String id = _todoList[index].id;
                          String detail = _todoList[index].detail;
                          String sports = _todoList[index].sports;
                          String name = _todoList[index].name;
                          String postcode = _todoList[index].postcode;
                          String phone = _todoList[index].phone;
                          String date=_todoList[index].day;
                          String time=_todoList[index].time;
                          String address=_todoList[index].address;
                          String uuid=_todoList[index].uuid;
                          bool favored=_favList.where((e)=>e.uuid==uuid).length>0;
                          // DateTime dt=DateTime.parse(date.split("-")[1].trim());

                          // return Dismissible(
                          //
                          //   key: Key(id),
                          //   background: Container(color: Colors.lime),
                          //   // onDismissed: (direction) async {
                          //   //   deleteTodo(id, index);
                          //   // },
                          //   child:
                          return
                                   Card(
                                   elevation: 8.0,
                                       margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),

                                child:
                                // Column(
                                //    mainAxisSize: MainAxisSize.min,
                                //    //  shrinkWrap:true,
                                //   children: <Widget>[
                                   // Container(
                                   //    // height:200,
                                   //    child:
                                      ListTile(
                                          contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
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
                                            print("In all collection page:"+id);
                                            Navigator.push(context,
                                                MaterialPageRoute(builder: (context) =>
                                                    ItemDetail(
                                                      id: id,
                                                      name: name,
                                                      phone: phone,
                                                      postcode: postcode,
                                                      detail: detail,
                                                      sports: sports,
                                                      date: date,
                                                      time: time,
                                                      address: address,
                                                      uuid:uuid,
                                                      favored:favored,
                                                      img: _todoList[index].img,
                                                      userId: widget.userId,
                                                      auth: widget.auth,
                                                      logoutCallback: widget.logoutCallback,
                                                      // signout:widget.signout

                                                    ))
                                            );
                                          },)),
                                    // ),




                          );


                        }
                    )
                    )
                ) : (Center(
                    child: Text(
                      "No Match",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 30.0),
                    )
                )
                )
              ],
            )

    );
  }
}





